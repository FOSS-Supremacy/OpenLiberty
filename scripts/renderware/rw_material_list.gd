class_name RWMaterialList
extends RWChunk

var material_count: int
var indices: Array[int]
var materials: Array[RWMaterial]

func _init(file: FileAccess):
	super(file)
	assert(type == ChunkType.MATERIAL_LIST)
	RWChunk.new(file)
	material_count = file.get_32()
	for i in material_count:
		# For fuck's sake, someone PR a code to do this into Godot.
		indices.append((file.get_32() + (1 << 31)) % (1 << 32) - (1 << 31) )
	for i in indices:
		if i == -1:
			materials.append(RWMaterial.new(file))
		else:
			assert(false, "implement")
	skip(file)
