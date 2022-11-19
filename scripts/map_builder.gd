extends Node


var items: Dictionary
var itemchilds: Array[TDFX]
var placements: Array[ItemPlacement]

var map: Node3D

var _loaded := false


func _ready() -> void:
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
					"CDIMAGE":
						AssetLoader.load_cd_image(tokens[1])
					_:
						push_warning("implement %s" % tokens[0])
	
	for child in itemchilds:
		items[child.parent].childs.append(child)


func _read_ide_line(section: String, tokens: Array[String]):
	var item := ItemDef.new()
	var id := tokens[0].to_int()
	match section:
		"objs":
			item.model_name = tokens[1]
			item.txd_name = tokens[2]
			item.render_distance = tokens[4].to_float()
			item.flags = tokens[tokens.size() - 1].to_int()
			
			items[id] = item
		"tobj":
			# TODO: Timed objects
			item.model_name = tokens[1]
			item.txd_name = tokens[2]
			
			items[id] = item
		"2dfx":
			match tokens[8].to_int():
				0:
					var lightdef := TDFXLight.new()
					lightdef.parent = tokens[0].to_int()
					
					lightdef.position = Vector3(
						tokens[1].to_float(),
						tokens[2].to_float(),
						tokens[3].to_float()
					)
					
					lightdef.color = Color(
						tokens[4].to_float(),
						tokens[5].to_float(),
						tokens[6].to_float()
					)
					
					itemchilds.append(lightdef)
				var type:
					push_warning("implement 2DFX type %d" % type)


func _read_ipl_line(section: String, tokens: Array[String]):
	match section:
		"inst":
			var placement := ItemPlacement.new()
			placement.id = tokens[0].to_int()
			placement.model_name = tokens[1].to_lower()
			
			placement.position = Vector3(
				tokens[2].to_float(),
				tokens[3].to_float(),
				tokens[4].to_float(),
			)
			
			placement.scale = Vector3(
				tokens[5].to_float(),
				tokens[6].to_float(),
				tokens[7].to_float(),
			)
			
			placement.rotation = Quaternion(
				-tokens[8].to_float(),
				-tokens[9].to_float(),
				-tokens[10].to_float(),
				tokens[11].to_float(),
			)
			
			placements.append(placement)


func _read_map_data(path: String, line_handler: Callable) -> void:
	var file := AssetLoader.open(path)
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


func spawn_placement(ipl: ItemPlacement) -> Node3D:
	return spawn(ipl.id, ipl.model_name, ipl.position, ipl.scale, ipl.rotation)


func spawn(id: int, model_name: String, position: Vector3, scale: Vector3, rotation: Quaternion) -> Node3D:
	var item := items[id] as ItemDef
	if item.flags & 0x40:
		return Node3D.new()
	
	var instance := StreamedMesh.new(item)
	instance.position = position
	instance.scale = scale
	instance.quaternion = rotation
	instance.visibility_range_end = item.render_distance
	
	for child in item.childs:
		if child is TDFXLight:
			continue # Ignored until https://github.com/godotengine/godot/issues/56657 is fixed
			var light := OmniLight3D.new()
			
			light.position = child.position
			
			light.light_color = child.color
			light.omni_range = 5.0
			light.light_energy = 10.0
			
			result.add_child(OmniLight3D.new())
	
	return result
