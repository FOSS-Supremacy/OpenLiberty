class_name RWString
extends RWChunk

var string: String

func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.STRING)
	var chars: PackedByteArray
	while true:
		var char := file.get_8()
		if char == 0:
			break
		chars.append(char)
	string = chars.get_string_from_ascii()
	skip(file)
