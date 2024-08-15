extends Control

var txd: RWTextureDict

func _load_image(index: int):
	$VBoxContainer/TextureRect.texture = null
	$VBoxContainer/TextureRect.texture = ImageTexture.create_from_image(txd.textures[index].image)

func _select_file():
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.current_dir = GameManager.gta_path
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.txd", "Texture Dictionary")
	add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))
	var file_path := (await dialog.file_selected) as String
	remove_child(dialog)
	var file := FileAccess.open(file_path, FileAccess.READ)
	assert(file_path != null)
	txd = RWTextureDict.new(file)
	$VBoxContainer/HBoxContainer/OptionButton.clear()
	for raster in txd.textures:
		$VBoxContainer/HBoxContainer/OptionButton.add_item(raster.name)
	_load_image(0)
