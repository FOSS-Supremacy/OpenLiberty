class_name RWChunk
extends RefCounted
## Base class for RenderWare chunks
##
## [url]https://gtamods.com/wiki/RenderWare_binary_stream_file[/url]


var type: int
var size: int
var library_id: int

var version: int:
	get:
		if library_id & 0xffff0000:
			return (library_id >> 14 & 0x3ff00) + 0x30000 | (library_id >> 16 & 0x3f)
		return library_id << 8

var build: int:
	get:
		if library_id & 0xffff0000:
			return library_id & 0xffff
		return 0

var _start: int


func _init(file: FileAccess):
	type = file.get_32()
	size = file.get_32()
	library_id = file.get_32()
	_start = file.get_position()


func skip(file: FileAccess) -> void:
	file.seek(_start + size)
