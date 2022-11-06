extends Node


var gta_path: String


func _ready() -> void:
	if OS.has_feature("editor"):
		gta_path = ProjectSettings.globalize_path("res://gta/")
	else:
		# TODO: Standalone path
		get_tree().quit()
	
	print("GTA path: %s" % gta_path)
	
	var err := get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	assert(err == OK, "failed to load main menu")
