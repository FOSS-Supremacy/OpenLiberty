# Code still under development and there may still be small bugs.
# Don't try to ask me how this works, because even I don't know.
# by: a6xdev, ...

# <-- This script will undergo a reformulation and will become a global camera. Do not make unnecessary additions. -->

extends Node3D

@export var Vehicle: VehicleBody3D
@export var VehicleEngineNode:VehicleEngine

@export_group("Camera Settings")
@export var FreeCamera:bool = false ## Camera livre para ajudar na analise e perfomace do Veiculo.
@export var ControllerState: CameraState

enum CameraState {
	ACTIVE,
	DISABLE
}

@export var forward_rotation: Vector3 = Vector3(-15, 0, 0) ## Rotation prioritizing the rear of the car.
@export var reverse_rotation: Vector3 = Vector3(-15, 180, 0) ## Rotation prioritizing the front of the car.
@export var smooth_time: float = 0.07 ## Camera transition time.
@export var mouse_sens: float = 0.4  ## Mouse sensitivity
@export var max_steering_rotation: float = 10.0 ## Maximum camera rotation based on direction

var car_is_moving: bool = false
var pivot: Node3D
var camera3d: Camera3D
var spring_arm3d: SpringArm3D

func _ready():
	pivot = $Pivot
	camera3d = $Pivot/SpringArm3D/Camera3D
	spring_arm3d = $Pivot/SpringArm3D

func _input(event):
	if event is InputEventMouseMotion and ControllerState == CameraState.ACTIVE and not car_is_moving:
		# Rotate CameraPivot based on mouse movement
		pivot.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		pivot.rotation.z = 0  # Resets Z rotation to avoid tilt

func _process(delta):
	var target_rotation = forward_rotation
	
	if not FreeCamera:
		if is_reversing():  # If you are reversing, the camera rotates in reverse, prioritizing the front of the car.
			target_rotation = reverse_rotation
			car_is_moving = true
		elif Vehicle.linear_velocity.length() > 2: # If you are going forward, the camera prioritizes the rear of the car.
			car_is_moving = true
		else:
			car_is_moving = false

	# Smooths camera rotation forward or backward
	if car_is_moving:
		pivot.rotation_degrees = lerp(pivot.rotation_degrees, target_rotation, smooth_time)
	
	# Adds rotation based on the car's steering to show more of the side
	if not FreeCamera:
		var steering_rotation = Vehicle.steering * max_steering_rotation * smooth_time
		pivot.rotation_degrees.y += steering_rotation  # Adiciona a rotação lateral
	
	# Enable or disable the camera based on the controller state
	match ControllerState:
		CameraState.ACTIVE:
			camera3d.current = true
		CameraState.DISABLE:
			camera3d.current = false

# Checks if the car is reversing.
# Still doesn't work very well.
func is_reversing() -> bool:
	if Vehicle.linear_velocity.length() > 2:
		var test = Vehicle.linear_velocity.dot(Vehicle.global_transform.basis.z)
		if test < 0:
			return true
		else:
			return false
	else:
		return false
