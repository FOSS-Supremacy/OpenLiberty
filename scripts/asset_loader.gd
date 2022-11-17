extends Node


var assets: Dictionary


func _ready() -> void:
	print("Caching gta3.img directory...")
	var file := open("models/gta3.dir")
	assert(file != null, "%d" % FileAccess.get_open_error())
	
	while not file.eof_reached():
		var entry := DirEntry.new()
		entry.offset = file.get_32() * 2048
		entry.size = file.get_32() * 2048
		assets[file.get_buffer(24).get_string_from_ascii().to_lower()] = entry


func open(path: String) -> FileAccess:
	var diraccess := DirAccess.open(GameManager.gta_path)
	var parts := path.split("/")
	
	for part in parts:
		if part == parts[parts.size() - 1]:
			for file in diraccess.get_files():
				if file.matchn(part):
					return FileAccess.open(diraccess.get_current_dir() + "/" + file, FileAccess.READ)
		else:
			for dir in diraccess.get_directories():
				if dir.matchn(part):
					diraccess.change_dir(dir)
					break
	
	return null



func open_img() -> FileAccess:
	return open("models/gta3.img")


class DirEntry:
	var offset: int
	var size: int
