@tool
class_name CollisionInstance
extends StaticBody3D

@export var collision_model: CollisionModel:
	set(value):
		if value == collision_model:
			return
		collision_model = value
		_rebuild()


func _init() -> void:
	_rebuild()


func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.free()

	if collision_model == null:
		return

	for sphere in collision_model.spheres:
		var node := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = sphere.radius
		node.shape = shape
		node.position = sphere.center
		add_child(node)

	for box in collision_model.boxes:
		var size := (box.maximum - box.minimum).abs()
		if size.x <= 0.0 or size.y <= 0.0 or size.z <= 0.0:
			continue
		var node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		node.shape = shape
		node.position = (box.minimum + box.maximum) * 0.5
		add_child(node)

	if collision_model.mesh_faces.is_empty():
		return

	var node := CollisionShape3D.new()
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(collision_model.mesh_faces)
	node.shape = shape
	add_child(node)
