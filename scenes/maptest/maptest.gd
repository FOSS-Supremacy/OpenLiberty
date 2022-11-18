extends Node


@onready var world := Node3D.new()


func _ready() -> void:
	world.rotation.x = deg_to_rad(-90.0)
	
	var start := Time.get_ticks_msec()
	var target = MapBuilder.placements.size()
	var count := 0
	var start_t := Time.get_ticks_msec()
	
#	add_child(MapBuilder.map)
	for ipl in MapBuilder.placements:
		world.add_child(MapBuilder.spawn_placement(ipl))
		count += 1
		
		if Time.get_ticks_msec() - start > (1.0 / 30.0) * 1000:
			start = Time.get_ticks_msec()
			print("%f" % (float(count) / float(target)))
			await get_tree().physics_frame
	print("Map load completed in %f seconds" % ((Time.get_ticks_msec() - start_t) / 1000))
	add_child(world)
