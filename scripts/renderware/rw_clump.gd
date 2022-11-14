class_name RWClump
extends RWChunk


var atomic_count: int
var light_count: int
var camera_count: int

var geometry_list: RWGeometryList


func _init(file: FileAccess):
	super(file)
	assert(type == 0x10)
	
	RWChunk.new(file)
	var atomic_count = file.get_32()
	if version > 0x33000:
		light_count = file.get_32()
		camera_count = file.get_32()
	RWChunk.new(file).skip(file) # Skip frame list
	geometry_list = RWGeometryList.new(file)
