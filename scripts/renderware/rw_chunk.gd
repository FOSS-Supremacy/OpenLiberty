class_name RWChunk
extends RefCounted


var type: int
var size: int
var library_id: int


func _init(file: FileAccess):
	type = file.get_32()
	size = file.get_32()
	library_id = file.get_32()
