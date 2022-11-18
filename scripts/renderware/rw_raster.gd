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

var _file: FileAccess
var _image_start: int
var image: Image: get = _load_image


func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.RASTER)
	
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
	
	_file = file
	_image_start = file.get_position()
	skip(file)

func _load_image():
	_file.seek(_image_start)
	var result: Image
	var format: Image.Format
	var read: int
	
	match raster_format & 0x0f00:
#		FORMAT_1555:
#			format = FORMAT_1555
#			read = 2
#		FORMAT_565:
#			format = Image.FORMAT_RGB565
#			read = 2
#		FORMAT_4444:
#			format = Image.FORMAT_RGBA4444
#			read = 2
		FORMAT_8888:
			format = Image.FORMAT_RGBA8
			read = 4
		FORMAT_888:
			format = Image.FORMAT_RGB8
			read = 3
		_:
			assert(false)
	
	if raster_format & (FORMAT_EXT_PAL8 | FORMAT_EXT_PAL4):
		var psize := (16 if raster_format & FORMAT_EXT_PAL4 else 256)
		var palette := Image.create_from_data(psize, 1, false, format, _unpad(psize, read))
		
		result = Image.create(width, height, raster_format & 0x8000, format)
		_file.get_32()
		for i in width * height:
			var x := int(i % width)
			var y := int(i / width)
			var color := palette.get_pixel(_file.get_8(), 0)
			result.set_pixel(x, y, color)
#	elif format == FORMAT_1555:
#		result = Image.create(width, height, raster_format & 0x8000, Image.FORMAT_RGBA8)
#		_file.get_32()
#		var unpadded := _unpad(width * height, read)
#		var data := PackedInt32Array()
#
#		for i in unpadded.size() / 2:
#			var x := int(i % width)
#			var y := int(i / width)
#
#			var pixel := unpadded[i] | unpadded[i + 1] << 16
#			var a := (pixel & 0x8000) >> 15
#			var r := (pixel & 0x7c00) >> 10
#			var g := (pixel & 0x03e0) >> 5
#			var b := pixel & 0x001f
#
#			result.set_pixel(
#				x, y, Color(
#					r / 0x1f,
#					g / 0x1f,
#					b / 0x1f,
#					a
#				)
#			)
	else:
		var data := PackedByteArray()
		
		var mip_width := width
		var mip_height := height
		for i in num_levels:
			var raster_size := _file.get_32()
			data.append_array(_unpad(mip_width * mip_height, read))
			mip_width /= 2
			mip_height /= 2
		
		result = Image.create_from_data(width, height, raster_format & FORMAT_EXT_MIPMAP, format, data)
		if raster_format & FORMAT_EXT_AUTO_MIPMAP:
			image.generate_mipmaps()
		
		# Perform color conversion
		for i in width * height:
				var x := int(i % width)
				var y := int(i / width)
				var old := result.get_pixel(x, y)
				result.set_pixel(x, y, Color(old.b, old.g, old.r, old.a))
	
	return result


func _unpad(length: int, read: int) -> PackedByteArray:
	var result := PackedByteArray()
	
	for i in length:
		for j in read:
			result.append(_file.get_8())
		for j in 4 - read:
			_file.get_8()
	
	return result
