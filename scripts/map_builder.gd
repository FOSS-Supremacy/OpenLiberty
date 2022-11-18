extends Node


var items: Dictionary
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


func _read_ide_line(section: String, tokens: Array[String]):
	match section:
		"objs":
			var id := tokens[0].to_int()
			var item := ItemDef.new()
			
			item.model_name = tokens[1]
			item.txd_name = tokens[2]
			item.render_distance = tokens[4].to_float()
			item.flags = tokens[tokens.size() - 1].to_int()
			
			items[id] = item
		"tobj":
			# TODO: Timed objects
			var id := tokens[0].to_int()
			var item := ItemDef.new()
			
			item.model_name = tokens[1]
			item.txd_name = tokens[2]
			
			items[id] = item


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


func spawn_placement(ipl: ItemPlacement):
	spawn(ipl.id, ipl.model_name, ipl.position, ipl.scale, ipl.rotation)


func spawn(id: int, model_name: String, position: Vector3, scale: Vector3, rotation: Quaternion):
	var item := items[id] as ItemDef
	if item.flags & 0x40:
		return
	
	var access := AssetLoader.open_asset(model_name + ".dff")
	var glist := RWClump.new(access).geometry_list
	
	for geometry in glist.geometries:
		var instance := StreamedMesh.new(item)
		
		instance.visibility_range_end = item.render_distance
		instance.position = position
		instance.scale = scale
		instance.quaternion = rotation
		
		map.add_child(instance)
		return
		
		var mesh := geometry.mesh
		for surf_id in mesh.get_surface_count():
			var material := mesh.surface_get_material(surf_id)
			
			if item.flags & 0x04:
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
				material.cull_mode = BaseMaterial3D.CULL_DISABLED
			
			if material.has_meta("texture_name"):
				var txd := RWTextureDict.new(AssetLoader.open_asset(item.txd_name + ".txd"))
				var texture_name = material.get_meta("texture_name")
				
				for raster in txd.textures:
					if texture_name.matchn(raster.name):
						material.albedo_texture = ImageTexture.create_from_image(raster.image)
						break
			
			mesh.surface_set_material(surf_id, material)
		
		instance.mesh = mesh
		map.add_child(instance)
