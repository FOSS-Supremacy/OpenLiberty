class_name StreamedMesh
extends MeshInstance3D


var _idef: ItemDef
var _thread := Thread.new()

var _mesh_buf: Mesh


func _init(idef: ItemDef):
	_idef = idef


func _exit_tree():
	if _thread.is_alive():
		_thread.wait_to_finish()


func _process(delta: float) -> void:
	if _thread.is_started() == false:
		var dist := get_viewport().get_camera_3d().global_transform.origin.distance_to(global_transform.origin)
		if dist < visibility_range_end and mesh == null:
			_thread.start(_load_mesh)
			while _thread.is_alive():
				await get_tree().process_frame
			_thread.wait_to_finish()
			mesh = _mesh_buf
		elif dist > visibility_range_end and mesh != null:
			mesh = null


func _load_mesh() -> void:
	AssetLoader.mutex.lock()
	if _idef.flags & 0x40:
		return
	
	var access := AssetLoader.open_asset(_idef.model_name + ".dff")
	var glist := RWClump.new(access).geometry_list
	
	for geometry in glist.geometries:
		_mesh_buf = geometry.mesh
		for surf_id in _mesh_buf.get_surface_count():
			var material := _mesh_buf.surface_get_material(surf_id) as StandardMaterial3D
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
			
			if material.has_meta("texture_name"):
				var txd := RWTextureDict.new(AssetLoader.open_asset(_idef.txd_name + ".txd"))
				var texture_name = material.get_meta("texture_name")
				
				for raster in txd.textures:
					if texture_name.matchn(raster.name):
						material.albedo_texture = ImageTexture.create_from_image(raster.image)
						if raster.has_alpha:
							material.transparency = (
								BaseMaterial3D.TRANSPARENCY_ALPHA_HASH if _idef.flags & 0x04
								else BaseMaterial3D.TRANSPARENCY_ALPHA
							)
							
						break
			
			_mesh_buf.surface_set_material(surf_id, material)
	
	AssetLoader.mutex.unlock()
