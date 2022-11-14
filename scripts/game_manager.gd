extends Node


var gta_path: String


func _ready() -> void:
	if OS.has_feature("editor"):
		gta_path = ProjectSettings.globalize_path("res://gta/")
	else:
		gta_path = OS.get_executable_path().get_base_dir() + "/"
	
	print("GTA path: %s" % gta_path)
	
	var err := get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	assert(err == OK, "failed to load main menu")


func load_map_data() -> void:
	var file := FileAccess.open(gta_path + "data/gta3.dat", FileAccess.READ)
	assert(file != null, "%d" % FileAccess.get_open_error())
	
	while not file.eof_reached():
		var line := file.get_line()
		if not line.begins_with("#"):
			var tokens := line.split(" ", false)
			if tokens.size() > 0:
				match tokens[0]:
					"IDE":
						load_itemdef(tokens[1].replace("\\", "/").to_lower())
					_:
						push_warning("implement %s" % tokens[0])


func load_itemdef(path: String) -> void:
	var file := FileAccess.open(gta_path + path, FileAccess.READ)
	assert(file != null, "%d" % FileAccess.get_open_error())
	
	breakpoint
