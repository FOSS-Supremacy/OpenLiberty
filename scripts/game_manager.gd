extends Node


var gta_path: String
var world: Node3D

var _objects: Dictionary


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
	world = Node3D.new()
	
	while not file.eof_reached():
		var line := file.get_line()
		if not line.begins_with("#"):
			var tokens := line.split(" ", false)
			if tokens.size() > 0:
				match tokens[0]:
					"IDE", "IPL":
						parse_map_data(tokens[1].replace("\\", "/"))
					_:
						push_warning("implement %s" % tokens[0])


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


func parse_map_data(path: String) -> void:
	var file := open_file(path, FileAccess.READ)
	assert(file != null, "%d" % FileAccess.get_open_error())
	
	var section: String
	while not file.eof_reached():
		var tokens := file.get_line().replace(" ", "").split(",", false)
		
		if tokens.size() > 0:
			if tokens[0].begins_with("#"):
				continue
			if tokens.size() == 1:
				section = tokens[0]
			elif tokens.size() > 1:
				match section:
					"objs", "tobj":
						var id := tokens[0].to_int()
						var odata := ObjectData.new()
						odata.model_name = tokens[1]
						odata.txd_name = tokens[2]
						_objects[id] = odata
					"inst":
						var obj := _objects[tokens[0].to_int()] as ObjectData
						var mesh := MeshInstance3D.new()
						
						mesh.mesh = BoxMesh.new()
						mesh.mesh.size = Vector3(6.0, 6.0, 6.0)
						mesh.position = Vector3(
							tokens[2].to_float(),
							-tokens[4].to_float(),
							tokens[3].to_float()
						)
						
						world.add_child(mesh)
