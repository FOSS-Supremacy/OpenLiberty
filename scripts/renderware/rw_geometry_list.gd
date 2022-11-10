class_name RWGeometryList
extends RWChunk


var geometry_count: int


func _init(file: FileAccess):
	super(file)
	assert(type == 0x1a)
	
	RWChunk.new(file)
	geometry_count = file.get_32()
	breakpoint
