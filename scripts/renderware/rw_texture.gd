class_name RWTexture
extends RWChunk

var texture_name: String
var mask_name: String

func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.TEXTURE)
	RWChunk.new(file).skip(file)
	texture_name = RWString.new(file).string
	mask_name = RWString.new(file).string
	skip(file)
