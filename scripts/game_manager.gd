extends Node


var gta_path: String
var world: Node3D

var _gta3_dir: Dictionary
var _gta3_img: FileAccess

var _objects: Dictionary
var _instances: Array[IPLInstance]


func _ready() -> void:
	if OS.has_feature("editor"):
		gta_path = ProjectSettings.globalize_path("res://gta/")
	else:
		gta_path = OS.get_executable_path().get_base_dir() + "/"
	
	print("GTA path: %s" % gta_path)
	
	print("Caching gta3.img file entries...")
	_read_gta3_dir()
	_gta3_img = open_file("models/gta3.img", FileAccess.READ)
	
	print("Caching map data...")
	_load_map_data()
	
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
		_gta3_dir[file.get_buffer(24).get_string_from_ascii().to_lower()] = entry


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


func load_map() -> void:
	world = Node3D.new()
	world.rotation.x = deg_to_rad(-90.0)
	
	for instance in _instances:
		spawn_instance(instance)


func _load_map_data() -> void:
	var file := FileAccess.open(gta_path + "data/gta3.dat", FileAccess.READ)
	assert(file != null, "%d" % FileAccess.get_open_error())
	
	while not file.eof_reached():
		var line := file.get_line()
		if not line.begins_with("#"):
			var tokens := line.split(" ", false)
			if tokens.size() > 0:
				match tokens[0]:
					"IDE":
						read_map_data(tokens[1], _read_ide_line)
					"IPL":
						read_map_data(tokens[1], _read_ipl_line)
					_:
						push_warning("implement %s" % tokens[0])


func _read_ide_line(section: String, tokens: Array[String]):
	match section:
		"objs":
			var id := tokens[0].to_int()
			var obj := IDEObject.new()
			
			obj.model_name = tokens[1]
			obj.txd_name = tokens[2]
			obj.flags = tokens[tokens.size() - 1].to_int()
			
			_objects[id] = obj
		"tobj":
			# TODO: Timed objects
			var id := tokens[0].to_int()
			var obj := IDEObject.new()
			
			obj.model_name = tokens[1]
			obj.txd_name = tokens[2]
			
			_objects[id] = obj


func _read_ipl_line(section: String, tokens: Array[String]):
	match section:
		"inst":
			var instance := IPLInstance.new()
			instance.model_name = tokens[1].to_lower()
			
			instance.position = Vector3(
				tokens[2].to_float(),
				tokens[3].to_float(),
				tokens[4].to_float(),
			)
			
			instance.scale = Vector3(
				tokens[5].to_float(),
				tokens[6].to_float(),
				tokens[7].to_float(),
			)
			
			instance.rotation = Quaternion(
				tokens[8].to_float(),
				tokens[9].to_float(),
				tokens[10].to_float(),
				tokens[11].to_float(),
			)
			
			_instances.append(instance)


func read_map_data(path: String, line_handler: Callable) -> void:
	var file := open_file(path.replace("\\", "/"), FileAccess.READ)
	assert(file != null, "%d" % FileAccess.get_open_error())
	
	var section: String
	while not file.eof_reached():
		var line := file.get_line()
		if line.length() == 0 or line.begins_with("#"):
			continue
		
		var tokens := line.replace(" ", "").split(",", false)
		if tokens.size() == 1:
			section = tokens[0]
		else:
			line_handler.call(section, tokens)


func spawn_instance(ipl_inst: IPLInstance):
	_gta3_img.seek(_gta3_dir[ipl_inst.model_name + ".dff"].offset)
	var glist := RWClump.new(_gta3_img).geometry_list
	
	if glist.geometries.size() > 0:
		var instance := MeshInstance3D.new()
		instance.mesh = glist.geometries[0].mesh
		
		instance.position = ipl_inst.position
		instance.scale = ipl_inst.scale
		instance.quaternion = ipl_inst.rotation
		
		world.add_child(instance)
