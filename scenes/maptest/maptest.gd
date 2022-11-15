extends Node


func _ready() -> void:
	MapBuilder.load_map_data()
	MapBuilder.clear_map()
	
	var start := Time.get_ticks_msec()
	var target = MapBuilder.instances.size()
	var count := 0
	
	for inst in MapBuilder.instances:
		MapBuilder.spawn_instance(inst)
		count += 1
		print("%f" % (float(count) / float(target)))
		
		if Time.get_ticks_msec() - start > (1.0 / 60.0) * 1000:
			start = Time.get_ticks_msec()
			await get_tree().physics_frame
	
	add_child(MapBuilder.map)
