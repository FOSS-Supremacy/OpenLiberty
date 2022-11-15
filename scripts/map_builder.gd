extends Node


var objects: Dictionary
var instances: Array[IPLInstance]

var map: Node3D

@onready var _assetfile := GameManager.get_asset_fileaccess() as FileAccess


func load_map_data() -> void:
	var file := FileAccess.open(GameManager.gta_path + "data/gta3.dat", FileAccess.READ)
	assert(file != null, "%d" % FileAccess.get_open_error())
	
	while not file.eof_reached():
		var line := file.get_line()
		if not line.begins_with("#"):
			var tokens := line.split(" ", false)
			if tokens.size() > 0:
				match tokens[0]:
					"IDE":
						_read_map_data(tokens[1], _read_ide_line)
					"IPL":
						_read_map_data(tokens[1], _read_ipl_line)
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
			
			MapBuilder.objects[id] = obj
		"tobj":
			# TODO: Timed objects
			var id := tokens[0].to_int()
			var obj := IDEObject.new()
			
			obj.model_name = tokens[1]
			obj.txd_name = tokens[2]
			
			MapBuilder.objects[id] = obj


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
			
			instances.append(instance)


func _read_map_data(path: String, line_handler: Callable) -> void:
	var file := GameManager.open_file(path.replace("\\", "/"), FileAccess.READ) as FileAccess
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


func clear_map() -> void:
	map = Node3D.new()
	map.rotation.x = deg_to_rad(-90.0)


func spawn_instance(ipl_inst: IPLInstance):
	_assetfile.seek(GameManager.assets[ipl_inst.model_name + ".dff"].offset)
	var glist := RWClump.new(_assetfile).geometry_list
	
	
	if glist.geometries.size() > 0:
		var instance := MeshInstance3D.new()
		instance.mesh = glist.geometries[0].mesh
		
		instance.position = ipl_inst.position
		instance.scale = ipl_inst.scale
		instance.quaternion = ipl_inst.rotation
		
		map.add_child(instance)