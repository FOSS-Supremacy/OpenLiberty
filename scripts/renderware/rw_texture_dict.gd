class_name RWTextureDict
extends RWChunk
## RenderWare texture dictionary

var texture_count: int
var device_id: int
var textures: Array[RWRaster]

func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.TEXTURE_DICT)
	RWChunk.new(file)
	texture_count = file.get_16()
	device_id = file.get_16()
	for i in texture_count:
		var raster := RWRaster.new(file)
		textures.append(raster)
	file.seek(_start + size)
