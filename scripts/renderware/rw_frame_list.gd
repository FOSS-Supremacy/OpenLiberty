class_name RWFrameList
extends RWChunk


var frame_count: int


func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.FRAME_LIST)
	
	frame_count = file.get_32()
	
	skip(file)
