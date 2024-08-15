extends Node

@onready var spinbox: SpinBox = $GUI/VBoxContainer/HBoxContainer/SpinBox
@onready var meshinstance: MeshInstance3D = $mesh
var dff: RWClump
var misc: RWTextureDict

func _ready() -> void:
	spinbox.rounded = true
	spinbox.max_value = 0
	misc = RWTextureDict.new(GameManager.open_file("models/misc.txd", FileAccess.READ))
	meshinstance.rotation.x = deg_to_rad(-90.0)

func _ld_dff() -> void:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.current_dir = GameManager.gta_path
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.dff")
	add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))
	var file_path := (await dialog.file_selected) as String
	remove_child(dialog)
	var file := FileAccess.open(file_path, FileAccess.READ)
	dff = RWClump.new(file)
	spinbox.value = 0
	spinbox.max_value = dff.geometry_list.geometry_count - 1
	_ld_model(0)

func _ld_model(value: float) -> void:
	var geometry := dff.geometry_list.geometries[int(value)]
	meshinstance.mesh = geometry.mesh
	var material := geometry.material_list.materials[0] as RWMaterial
	meshinstance.material_override = material.material
	if material.is_textured:
		var texname := material.texture.texture_name.string
		for raster in misc.textures:
			if texname.to_lower() == raster.name:
				meshinstance.material_override.albedo_texture = ImageTexture.create_from_image(raster.image)
				break
