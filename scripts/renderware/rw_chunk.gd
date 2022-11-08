class_name RWChunk
extends RefCounted
## Base class for RenderWare chunks


var type: int
var size: int
var library_id: int


func _init(file: FileAccess):
	type = file.get_32()
	size = file.get_32()
	library_id = file.get_32()
	assert(library_id == 0x0c02ffff) # TODO: Other versions
