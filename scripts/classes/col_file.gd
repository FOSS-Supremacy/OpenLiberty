class_name ColFile
extends RefCounted


var fourcc: String
var file_size: int
var model_name: String
var model_id: int
var tbounds: TBounds

var collisions: Array[TBase]
var vertices: PackedVector3Array


func _init(file: FileAccess):
	fourcc = file.get_buffer(4).get_string_from_ascii()
	file_size = file.get_32()
	model_name = file.get_buffer(22).get_string_from_ascii()
	model_id = file.get_16()
	tbounds = TBounds.new(file)
	
	for i in file.get_32():
		collisions.append(TSphere.new(file))
	file.get_32()
	
	for i in file.get_32():
		collisions.append(TBox.new(file))
	
	var unsorted := PackedVector3Array()
	
	for i in file.get_32():
		unsorted.append(TVertex.new(file).position)
	
	for i in file.get_32():
		var face := TFace.new(file)
		vertices.append(unsorted[face.a])
		vertices.append(unsorted[face.b])
		vertices.append(unsorted[face.c])


class TBase:
	func read_vector3(file: FileAccess) -> Vector3:
		var result := Vector3()
		result.x = file.get_float()
		result.y = file.get_float()
		result.z = file.get_float()
		return result


class TBounds extends TBase:
	var radius: float
	var center: Vector3
	var min: Vector3
	var max: Vector3
	
	
	func _init(file: FileAccess):
		radius = file.get_float()
		
		center = read_vector3(file)
		min = read_vector3(file)
		max = read_vector3(file)


class TSurface extends TBase:
	var material: int
	var flag: int
	var brightness: int
	var light: int
	
	
	func _init(file: FileAccess):
		material = file.get_8()
		flag = file.get_8()
		brightness = file.get_8()
		light = file.get_8()


class TSphere extends TBase:
	var radius: float
	var center: Vector3
	var surface: TSurface
	
	
	func _init(file: FileAccess):
		radius = file.get_float()
		center = read_vector3(file)
		
		surface = TSurface.new(file)


class TBox extends TBase:
	var min: Vector3
	var max: Vector3
	var surface: TSurface
	
	
	func _init(file: FileAccess):
		min = read_vector3(file)
		max = read_vector3(file)
		surface = TSurface.new(file)


class TVertex extends TBase:
	var position: Vector3
	
	
	func _init(file: FileAccess):
		position = read_vector3(file)


class TFace extends TBase:
	var a: int
	var b: int
	var c: int
	var surface: TSurface
	
	
	func _init(file: FileAccess):
		a = file.get_32()
		b = file.get_32()
		c = file.get_32()
		surface = TSurface.new(file)
