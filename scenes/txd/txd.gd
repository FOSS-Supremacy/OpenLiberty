extends Control


func _ready() -> void:
	var file := FileAccess.open(GameManager.gta_path + "models/hud.txd", FileAccess.READ)
	assert(file != null)
	
	var txd := RWChunk.new(file)
	breakpoint
	
