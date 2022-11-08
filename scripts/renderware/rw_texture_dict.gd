class_name RWTextureDict
extends RWChunk
## RenderWare texture dictionary


var texture_count: int
var device_id: int


func _init(file: FileAccess):
	super(file)
	assert(type == 0x16)
	assert(library_id == 0x1803ffff) # TODO: Other versions
	
	RWChunk.new(file)
	texture_count = file.get_16()
	device_id = file.get_16()
	breakpoint
