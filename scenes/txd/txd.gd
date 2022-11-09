extends Control


var txd: RWTextureDict


func _ready() -> void:
	var file := FileAccess.open(GameManager.gta_path + "models/menu.txd", FileAccess.READ)
	assert(file != null)
	
	txd = RWTextureDict.new(file)
	for raster in txd.textures:
		$VBoxContainer/OptionButton.add_item(raster.name)
	
	_load_image(0)


func _load_image(index: int):
	$VBoxContainer/TextureRect.texture = null
	$VBoxContainer/TextureRect.texture = ImageTexture.create_from_image(txd.textures[index].image)
