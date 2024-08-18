extends Node3D

@export var ControllerState: CameraState
enum CameraState {
	ACTIVE,
	DISABLE
}
var mouse_sens = 0.4

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion && ControllerState == CameraState.ACTIVE:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		rotation.z = 0

func _process(delta: float) -> void:
	match ControllerState:
		CameraState.ACTIVE:
			$SpringArm3D/Camera3D.current = true
		CameraState.DISABLE:
			$SpringArm3D/Camera3D.current = false
