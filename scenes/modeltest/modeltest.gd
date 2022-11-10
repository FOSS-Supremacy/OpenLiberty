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
	meshinstance.mesh = geometry.mesh
