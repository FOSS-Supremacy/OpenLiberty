class_name CollisionData
extends Resource


var models: Dictionary[String, CollisionModel] = {}


class CollisionModel:
	var name: String
	var id: int
	var bounds: CollisionBounds
	var spheres: Array[CollisionSphere] = []
	var boxes: Array[CollisionBox] = []
	var vertices: PackedVector3Array
	var faces: Array[CollisionFace] = []
	var mesh_faces: PackedVector3Array


class CollisionBounds:
	var radius: float
	var center: Vector3
	var minimum: Vector3
	var maximum: Vector3


class CollisionSphere:
	var radius: float
	var center: Vector3
	var surface: CollisionSurface


class CollisionBox:
	var minimum: Vector3
	var maximum: Vector3
	var surface: CollisionSurface


class CollisionFace:
	var a: int
	var b: int
	var c: int
	var surface: CollisionSurface


class CollisionSurface:
	var material: int
	var flag: int
	var brightness: int
	var light: int
