extends Node


func _ready() -> void:
	MapBuilder.load_map_data()
	MapBuilder.clear_map()
	
	var start := Time.get_ticks_msec()
	var target = MapBuilder.placements.size()
	var count := 0
	
	add_child(MapBuilder.map)
	for ipl in MapBuilder.placements:
		MapBuilder.spawn_placement(ipl)
		count += 1
		
		if Time.get_ticks_msec() - start > (1.0 / 30.0) * 1000:
			start = Time.get_ticks_msec()
			print("%f" % (float(count) / float(target)))
			await get_tree().physics_frame
	
#	add_child(MapBuilder.map)
