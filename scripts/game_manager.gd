extends Node


var gta_path: String
var assets: Dictionary


func _ready() -> void:
	if OS.has_feature("editor"):
		gta_path = ProjectSettings.globalize_path("res://gta/")
	else:
		gta_path = OS.get_executable_path().get_base_dir() + "/"
	
	print("GTA path: %s" % gta_path)
	
	print("Caching gta3.img assets...")
	_read_gta3_dir()
	print("Caching map data...")
	MapBuilder.load_map_data()
	
	print("Done")
	var err := get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	assert(err == OK, "failed to load main menu")


func _read_gta3_dir() -> void:
	var file := open_file("models/gta3.dir", FileAccess.READ)
	assert(file != null, "%d" % FileAccess.get_open_error())
	
	while not file.eof_reached():
		var entry := DirEntry.new()
		entry.offset = file.get_32() * 2048
		entry.size = file.get_32() * 2048
		assets[file.get_buffer(24).get_string_from_ascii().to_lower()] = entry


func get_asset_fileaccess() -> FileAccess:
	return open_file("models/gta3.img", FileAccess.READ)


## Open a file with case-insensitive path
func open_file(path: String, mode: FileAccess.ModeFlags) -> FileAccess:
	var diraccess := DirAccess.open(gta_path)
	var parts := path.split("/")
	
	for part in parts:
		if part == parts[parts.size() - 1]:
			for file in diraccess.get_files():
				if file.matchn(part):
					return FileAccess.open(diraccess.get_current_dir() + "/" + file, mode)
		else:
			for dir in diraccess.get_directories():
				if dir.matchn(part):
					diraccess.change_dir(dir)
					break
	
	return null
