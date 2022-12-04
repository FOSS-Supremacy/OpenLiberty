extends Node


func _ready() -> void:
	var file := AssetLoader.open_asset("player.dff")
	var dff := RWClump.new(file)
	
	for geometry in dff.geometry_list.geometries:
		var mesh := geometry.mesh
		
		for surf_id in mesh.get_surface_count():
			var bmpf := AssetLoader.open("models/generic/player.bmp")
			var material := mesh.surface_get_material(surf_id) as StandardMaterial3D
			
			
			material.albedo_texture = ImageTexture.create_from_image(Image.load_from_file(bmpf.get_path_absolute()))
			mesh.surface_set_material(surf_id, material)
		
		var instance := MeshInstance3D.new()
		instance.mesh = mesh
		add_child(instance)
