extends Node

var assets: Dictionary
var mutex := Mutex.new()

func _ready() -> void:
	load_cd_image("models/gta3.img")

func load_cd_image(path: String) -> void:
	var file := open(path.to_lower().trim_suffix(".img") + ".dir")
	assert(file != null, "%d" % FileAccess.get_open_error())
	while not file.eof_reached():
		var entry := DirEntry.new()
		entry.img = path
		entry.offset = int(file.get_32()) * 2048
		entry.size = int(file.get_32()) * 2048
		assets[file.get_buffer(24).get_string_from_ascii().to_lower()] = entry

func open(path: String) -> FileAccess:
	var diraccess := DirAccess.open(GameManager.gta_path)
	var parts := path.replace("\\", "/").split("/")
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

func open_asset(name: String) -> FileAccess:
	if name.to_lower() in assets:
		var asset = assets[name.to_lower()] as DirEntry
		var access := open(assets[name.to_lower()].img)
		access.seek(asset.offset)
		return access
	return open("models/" + name)

class DirEntry:
	var img: String
	var offset: int
	var size: int
