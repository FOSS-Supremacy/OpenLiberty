class_name RWFrameList
extends RWChunk

var frame_count: int
var frames: Array[Frame]

func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.FRAME_LIST)
	frame_count = file.get_32()
	frames.resize(frame_count)
	for frame_i in frame_count:
		var frame := Frame.new()
		frame.rotation_matrix.resize(3)
		for vec_i in 3:
			var x := file.get_float()
			var y := file.get_float()
			var z := file.get_float()
			frame.rotation_matrix[vec_i] = Vector3(x, y, z)
		var x := file.get_float()
		var y := file.get_float()
		var z := file.get_float()
		frame.position.x = x
		frame.position.y = y
		frame.position.z = z
		frame.index = file.get_32()
		frame.flags = file.get_32()
		frames[frame.index] = frame
	skip(file)

class Frame:
	var rotation_matrix: Array[Vector3]
	var position: Vector3
	var index: int
	var flags: int
