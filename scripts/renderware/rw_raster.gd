class_name RWRaster
extends RWChunk


enum {
	FORMAT_DEFAULT         = 0x0000,
	FORMAT_1555            = 0x0100,
	FORMAT_565             = 0x0200,
	FORMAT_4444            = 0x0300,
	FORMAT_LUM8            = 0x0400,
	FORMAT_8888            = 0x0500,
	FORMAT_888             = 0x0600,
	FORMAT_555             = 0x0A00,

	FORMAT_EXT_AUTO_MIPMAP = 0x1000,
	FORMAT_EXT_PAL8        = 0x2000,
	FORMAT_EXT_PAL4        = 0x4000,
	FORMAT_EXT_MIPMAP      = 0x8000
}

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

var image: Image


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
	
	# Image loading starts here
	image = Image.create(width, height, false, Image.FORMAT_RGB8)
	image.fill(Color(1.0, 0.0, 1.0)) # Dummy image
	
	if raster_format & (FORMAT_EXT_PAL8 | FORMAT_EXT_PAL4):
		var format: int
		var bpc: int
		match raster_format & 0x0f00:
			FORMAT_8888:
				format = Image.FORMAT_RGBA8
				bpc = 4
			FORMAT_888:
				format = Image.FORMAT_RGB8
				bpc = 3
			_:
				assert(false, "unknown raster format")
		image = Image.create(width, height, false, format)
		
		if raster_format & FORMAT_EXT_PAL8:
			var palette := Image.create_from_data(256, 1, false, format, file.get_buffer(256 * bpc))
			var raster_size := file.get_32()
			for i in raster_size:
				var x := int(i % width)
				var y := int(i / width)
				var color := palette.get_pixel(file.get_8(), 0)
				image.set_pixel(x, y, color)
	else:
		# Honestly, idk wtf is going on. I thought the non-paletted format
		# depends on the raster format but nope. Apparently they all use RGBA8.
		var raster_size := file.get_32()
		image = Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, file.get_buffer(raster_size))
	
	skip(file)
