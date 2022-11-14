extends Node


func _ready() -> void:
	GameManager.load_map()
	add_child(GameManager.world)
