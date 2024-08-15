class_name RWClump
extends RWChunk

var atomic_count: int
var light_count: int
var camera_count: int
var frame_list: RWFrameList
var geometry_list: RWGeometryList

func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.CLUMP)
	RWChunk.new(file)
	var atomic_count = file.get_32()
	if version > 0x33000:
		light_count = file.get_32()
		camera_count = file.get_32()
	frame_list = RWFrameList.new(file)
	geometry_list = RWGeometryList.new(file)
