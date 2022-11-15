class_name RWMaterial
extends RWChunk


var color: Color
var is_textured: bool
var texture: RWTexture

var ambient: float
var specular: float
var diffuse: float


func _init(file: FileAccess):
	super(file)
	assert(type == 0x07)
	
	RWChunk.new(file)
	file.get_32()
	color.r8 = file.get_8()
	color.g8 = file.get_8()
	color.b8 = file.get_8()
	color.a8 = file.get_8()
	file.get_32()
	
	is_textured = file.get_32() > 0
	
	if version > 0x30400:
		ambient = file.get_float()
		specular = file.get_float()
		diffuse = file.get_float()
	
	texture = RWTexture.new(file)
	skip(file)
