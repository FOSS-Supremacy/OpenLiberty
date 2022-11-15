class_name RWTexture
extends RWChunk


var texture_name: RWString
var mask_name: RWString


func _init(file: FileAccess):
	super(file)
	assert(type == 0x06)
	
	RWChunk.new(file).skip(file)
	texture_name = RWString.new(file)
	mask_name = RWString.new(file)
	skip(file)
