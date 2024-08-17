extends Node

@onready var world := Node3D.new()
@onready var sun = $sun
@onready var moon = $moon
@onready var sky = $WorldEnvironment
var car := preload("res://scenes/car.tscn")

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
	sky.environment = load("res://scenes/world/day.tres")
	moon.visible = not moon.visible

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("spawn"):
			var car_node := car.instantiate()
			add_child(car_node)
			car_node.global_position = get_viewport().get_camera_3d().global_position

func _input(event):
	if Input.is_action_just_pressed("full_screen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#else:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if Input.is_action_just_pressed("night_toggle"):
		sky.environment = load("res://scenes/world/night.tres")
		sun.visible = not sun.visible
		moon.visible = not moon.visible
		#if sun.visible = true
			#sky.environment = load("res://scenes/world/day.tres")
