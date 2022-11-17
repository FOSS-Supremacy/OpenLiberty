class_name StreamedMesh
extends MeshInstance3D


var _idef: ItemDef
var _loading := false

var _mesh_buf: Mesh


func _init(idef: ItemDef):
	_idef = idef


func _process(delta: float) -> void:
	if _loading == false:
		var dist := get_viewport().get_camera_3d().global_transform.origin.distance_to(global_transform.origin)
		if dist < visibility_range_end and mesh == null:
			_loading = true
			
			var thread := Thread.new()
			thread.start(_load_mesh)
			while thread.is_alive():
				await get_tree().process_frame
			thread.wait_to_finish()
			mesh = _mesh_buf
			
			_loading = false
		elif dist > visibility_range_end and mesh != null:
			mesh = null


func _load_mesh() -> void:
	AssetLoader.mutex.lock()
	if _idef.flags & 0x40:
		return
	
	var access := AssetLoader.open_img()
	access.seek(AssetLoader.assets[_idef.model_name.to_lower() + ".dff"].offset)
	var glist := RWClump.new(access).geometry_list
	
	for geometry in glist.geometries:
		_mesh_buf = geometry.mesh
		for surf_id in _mesh_buf.get_surface_count():
			var material := _mesh_buf.surface_get_material(surf_id)
			
			if _idef.flags & 0x04:
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
				material.cull_mode = BaseMaterial3D.CULL_DISABLED
			
			if material.has_meta("texture_name"):
				var txd: RWTextureDict
				var texture_name = material.get_meta("texture_name")
				
				if _idef.txd_name == "generic":
					txd = RWTextureDict.new(AssetLoader.open("models/generic.txd"))
				else:
					access.seek(AssetLoader.assets[_idef.txd_name.to_lower() + ".txd"].offset)
					txd = RWTextureDict.new(access)
				
				for raster in txd.textures:
					if texture_name.matchn(raster.name):
						material.albedo_texture = ImageTexture.create_from_image(raster.image)
						break
			
			_mesh_buf.surface_set_material(surf_id, material)
	
	AssetLoader.mutex.unlock()
