class_name ColFile
extends RefCounted


var fourcc: String
var file_size: int
var model_name: String
var model_id: int
var tbounds: TBounds

var colspheres: Array[TSphere]


func _init(file: FileAccess):
	fourcc = file.get_buffer(4).get_string_from_ascii()
	file_size = file.get_32()
	model_name = file.get_buffer(22).get_string_from_ascii()
	model_id = file.get_16()
	tbounds = TBounds.new(file)
	
	for i in file.get_32():
		colspheres.append(TSphere.new(file))
	
	pass


class TBounds:
	var radius: float
	var center: Vector3
	var min: Vector3
	var max: Vector3
	
	
	func _init(file: FileAccess):
		radius = file.get_float()
		
		center.x = file.get_float()
		center.y = file.get_float()
		center.z = file.get_float()
		
		min.x = file.get_float()
		min.y = file.get_float()
		min.z = file.get_float()
		
		max.x = file.get_float()
		max.y = file.get_float()
		max.z = file.get_float()


class TSurface:
	var material: int
	var flag: int
	var brightness: int
	var light: int
	
	
	func _init(file: FileAccess):
		material = file.get_8()
		flag = file.get_8()
		brightness = file.get_8()
		light = file.get_8()


class TSphere:
	var radius: float
	var center: Vector3
	var surface: TSurface
	
	
	func _init(file: FileAccess):
		radius = file.get_float()
		
		center.x = file.get_float()
		center.y = file.get_float()
		center.z = file.get_float()
		
		surface = TSurface.new(file)
