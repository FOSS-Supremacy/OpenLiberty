extends Node


@onready var spinbox: SpinBox = $GUI/VBoxContainer/HBoxContainer/SpinBox
@onready var meshinstance: MeshInstance3D = $mesh
var dff: RWClump


func _ready() -> void:
	spinbox.rounded = true
	spinbox.max_value = 0


func _ld_dff() -> void:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.current_dir = GameManager.gta_path
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.dff")
	
	add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))
	var file_path := (await dialog.file_selected) as String
	remove_child(dialog)
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	dff = RWClump.new(file)
	
	spinbox.value = 0
	spinbox.max_value = dff.geometry_list.geometry_count - 1
	
	_ld_model(0)


func _ld_model(value: float) -> void:
	var geometry := dff.geometry_list.geometries[int(value)]
	var morph_t := geometry.morph_targets[0]
	if geometry.morph_targets[0].has_vertices == false:
		return
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for tri in geometry.tris:
		for i in [3,2,1]:
			if morph_t.has_normals:
				st.set_normal(morph_t.normals[tri["vertex_%d" % i]])
			st.add_vertex(morph_t.vertices[tri["vertex_%d" % i]])
	
	if geometry.format & RWGeometry.rpGEOMETRYTRISTRIP == 0:
		st.generate_normals()
	meshinstance.mesh = st.commit()
