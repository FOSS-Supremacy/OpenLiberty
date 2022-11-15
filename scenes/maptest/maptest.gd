extends Node


func _ready() -> void:
	MapBuilder.load_map_data()
	MapBuilder.build_map()
	add_child(MapBuilder.map)
