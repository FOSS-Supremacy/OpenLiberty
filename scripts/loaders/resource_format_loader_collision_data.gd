class_name ResourceFormatLoaderCollisionData
extends ResourceFormatLoader


const MODEL_HEADER_SIZE := 8 + 22 + 2 + 40
const MAX_COLLECTION_COUNT := 1_000_000


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["col"])


func _handles_type(type: StringName) -> bool:
	return type == &"Resource" or type == &"CollisionData"


func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ERR_FILE_NOT_FOUND

	var data := CollisionData.new()
	while file.get_position() < file.get_length():
		var model := _read_model(file)
		if model == null:
			return ERR_INVALID_DATA
		data.models[model.name.to_lower()] = model

	data.resource_name = path.get_file()
	return data


func _read_model(file: FileAccess) -> CollisionData.CollisionModel:
	if file.get_length() - file.get_position() < MODEL_HEADER_SIZE:
		return null

	var magic := file.get_buffer(4)
	if magic != PackedByteArray([0x43, 0x4f, 0x4c, 0x4c]):
		push_error("Unsupported collision version")
		return null

	var model_size: int = file.get_32()
	if model_size < 0:
		return null
	var model_end: int = file.get_position() + model_size
	if model_end > file.get_length():
		push_error("Collision model extends past the end of the file")
		return null

	var model := CollisionData.CollisionModel.new()
	model.name = _read_name(file, 22)
	if model.name.is_empty():
		push_error("Collision model has an invalid name")
		return null
	model.id = file.get_16()
	if model.id < 0:
		model.id &= 0xffff
	model.bounds = _read_bounds(file)

	var sphere_count := _read_count(file, model_end, 20)
	if sphere_count < 0:
		return null
	for i in sphere_count:
		var sphere := CollisionData.CollisionSphere.new()
		sphere.radius = file.get_float()
		sphere.center = _read_vector3(file)
		sphere.surface = _read_surface(file)
		model.spheres.append(sphere)

	# GTA III stores an unused count between spheres and boxes.
	var unused_count := _read_count(file, model_end, 0)
	if unused_count != 0:
		return null

	var box_count := _read_count(file, model_end, 28)
	if box_count < 0:
		return null
	for i in box_count:
		var box := CollisionData.CollisionBox.new()
		box.minimum = _read_vector3(file)
		box.maximum = _read_vector3(file)
		box.surface = _read_surface(file)
		model.boxes.append(box)

	var vertex_count := _read_count(file, model_end, 12)
	if vertex_count < 0:
		return null
	model.vertices.resize(vertex_count)
	for i in vertex_count:
		model.vertices[i] = _read_vector3(file)

	var face_count := _read_count(file, model_end, 16)
	if face_count < 0:
		return null
	for i in face_count:
		var face := CollisionData.CollisionFace.new()
		face.a = file.get_32()
		face.b = file.get_32()
		face.c = file.get_32()
		if face.a < 0 or face.b < 0 or face.c < 0:
			return null
		face.surface = _read_surface(file)
		if face.a >= vertex_count or face.b >= vertex_count or face.c >= vertex_count:
			push_error("Collision face references a missing vertex")
			return null
		model.faces.append(face)
		model.mesh_faces.append(model.vertices[face.a])
		model.mesh_faces.append(model.vertices[face.b])
		model.mesh_faces.append(model.vertices[face.c])

	if file.get_position() != model_end:
		push_error("Collision model '%s' has unexpected trailing data" % model.name)
		return null
	return model


func _read_count(file: FileAccess, model_end: int, element_size: int) -> int:
	if file.get_position() + 4 > model_end:
		return -1
	var count: int = file.get_32()
	if count < 0:
		return -1
	if count > MAX_COLLECTION_COUNT:
		return -1
	if element_size > 0 and count > (model_end - file.get_position()) / element_size:
		return -1
	return count


func _read_name(file: FileAccess, length: int) -> String:
	var bytes := file.get_buffer(length)
	var terminator := bytes.find(0)
	if terminator >= 0:
		bytes = bytes.slice(0, terminator)
	return bytes.get_string_from_ascii()


func _read_vector3(file: FileAccess) -> Vector3:
	return Vector3(file.get_float(), file.get_float(), file.get_float())


func _read_bounds(file: FileAccess) -> CollisionData.CollisionBounds:
	var bounds := CollisionData.CollisionBounds.new()
	bounds.radius = file.get_float()
	bounds.center = _read_vector3(file)
	bounds.minimum = _read_vector3(file)
	bounds.maximum = _read_vector3(file)
	return bounds


func _read_surface(file: FileAccess) -> CollisionData.CollisionSurface:
	var surface := CollisionData.CollisionSurface.new()
	surface.material = file.get_8() & 0xff
	surface.flag = file.get_8() & 0xff
	surface.brightness = file.get_8() & 0xff
	surface.light = file.get_8() & 0xff
	return surface
