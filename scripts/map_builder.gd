extends Node


var items: Dictionary
var placements: Array[ItemPlacement]

var map: Node3D

@onready var _assetfile := AssetLoader.open_img()


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
			var item := ItemDef.new()
			
			item.model_name = tokens[1]
			item.txd_name = tokens[2]
			item.render_distance = tokens[3].to_float()
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
				tokens[8].to_float(),
				tokens[9].to_float(),
				tokens[10].to_float(),
				tokens[11].to_float(),
			)
			
			placements.append(placement)


func _read_map_data(path: String, line_handler: Callable) -> void:
	var file := AssetLoader.open(path.replace("\\", "/"))
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
	_assetfile.seek(AssetLoader.assets[item.model_name.to_lower() + ".dff"].offset)
	var glist := RWClump.new(_assetfile).geometry_list
	
	if glist.geometries.size() > 0:
		var instance := MeshInstance3D.new()
		var geometry := glist.geometries[0] as RWGeometry
		
		instance.mesh = geometry.mesh
		instance.visibility_range_end = item.render_distance
		instance.position = position
		instance.scale = scale
		instance.quaternion = rotation
		
		var material := geometry.material_list.materials[0] as RWMaterial
		instance.material_override = material.material
		
		if material.is_textured:
			var txd: RWTextureDict
			
			if item.txd_name == "generic":
				txd = RWTextureDict.new(AssetLoader.open("models/generic.txd"))
			else:
				_assetfile.seek(AssetLoader.assets[item.txd_name.to_lower() + ".txd"].offset)
				txd = RWTextureDict.new(_assetfile)
			
			for raster in txd.textures:
				if material.texture.texture_name.string.to_lower() == raster.name:
					instance.material_override.albedo_texture = ImageTexture.create_from_image(raster.image)
		
		map.add_child(instance)


class ItemDef:
	var model_name: String
	var txd_name: String
	var render_distance: float
	var flags: int

class ItemPlacement:
	var id: int
	var model_name: String
	var position: Vector3
	var scale: Vector3
	var rotation: Quaternion
