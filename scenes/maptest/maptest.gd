extends Node


func _ready() -> void:
	MapBuilder.load_map_data()
	
	var thread := Thread.new()
	thread.start(MapBuilder.build_map)
	
	while thread.is_alive():
		MapBuilder.mutex.lock()
		print("%f" % MapBuilder.progress)
		MapBuilder.mutex.unlock()
		await get_tree().physics_frame
	thread.wait_to_finish()
	
	add_child(MapBuilder.map)
