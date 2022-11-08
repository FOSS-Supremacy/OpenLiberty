class_name RWRaster
extends RWChunk


var platform_id: int
var filter_mode: int
var u_addressing: int
var v_addressing: int
var name: String
var mask_name: String

var raster_format: int
var has_alpha: bool
var width: int
var height: int
var depth: int
var num_levels: int
var raster_type: int
var compression: int


func _init(file: FileAccess):
	super(file)
	assert(type == 0x15)
	
	RWChunk.new(file)
	platform_id = file.get_32()
	filter_mode = file.get_8()
	
	var uv_addressing = file.get_8()
	u_addressing = uv_addressing >> 4
	v_addressing = uv_addressing & 0xf
	
	file.get_16()
	name = file.get_buffer(32).get_string_from_ascii()
	mask_name = file.get_buffer(32).get_string_from_ascii()
	raster_format = file.get_32()
	has_alpha = (true if file.get_32() > 0 else false)
	width = file.get_16()
	height = file.get_16()
	depth = file.get_8()
	num_levels = file.get_8()
	raster_type = file.get_8()
	compression = file.get_8()
	
	breakpoint
