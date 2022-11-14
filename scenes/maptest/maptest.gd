extends Node


func _ready() -> void:
	GameManager.load_map_data()
	add_child(GameManager.world)
