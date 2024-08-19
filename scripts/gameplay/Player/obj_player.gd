extends CharacterBody3D
#class_name Player

var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

@export var state:PlayerState
enum PlayerState {
	ENABLE,
	DISABLE
}
# <--------------------------->
@onready var mesh = $mesh # Player Model
@onready var cam_pivot: Node3D = $cameraPivot 
@onready var spring_arm_3d: SpringArm3D = $cameraPivot/SpringArm

# <--------------------------->
@export var sensitivity = 0.02
@export var gravity:float = 9.8

@export_group("Player")
@export var SPEED_WALK = 4
@export var SPEED_RUN = 6
@export var JUMP_FORCE = 5
var SPEED_ACCEL = 30

@export_group("Flags")
@export var CAN_MOVE:bool = true
@export var CAN_RUN = true
@export var GRAVITY_ON:bool = true
@export var SpringLenght:int = 2 # Distance from camera to player


var rotation_speed = 10.0 # for player rotation.

# <--------------------------->
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#cam_pivot.rotate_y(-event.relative.x * sensitivity/2)
		#spring_arm_3d.rotate_x(-event.relative.y * sensitivity/2)
		#spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, -PI/3, PI/5)

func _process(delta: float) -> void:
	spring_arm_3d.spring_length = SpringLenght
	
func _physics_process(delta: float) -> void:
	state_controller()
	movement_controller(delta)

func state_controller():
	match state:
		PlayerState.ENABLE:
			#$collision.disabled = false
			#mesh.visible = true
			pass
		PlayerState.DISABLE:
			#$collision.disabled = true
			#mesh.visible = false
			pass
			
func movement_controller(delta):
	if CAN_MOVE:
		# Direction of movement based on player direction
		move_dir = Vector3(
			Input.get_action_strength("player_right") - Input.get_action_strength("player_left"),
			0.0,
			Input.get_action_strength("player_backward") - Input.get_action_strength("player_forward")
		).normalized()
		
		move_dir = move_dir.rotated(Vector3.UP, cam_pivot.rotation.y)
		
		if Input.is_action_just_pressed("player_jump") && is_on_floor():
			velocity.y += JUMP_FORCE
			
		# Rotates the mesh in the direction of movement with a smooth transition
		if move_dir.length() > 0.1:
			var target_rotation = mesh.global_transform.basis.get_euler().y
			var move_direction_rotation = atan2(-move_dir.x, -move_dir.z)
			target_rotation = lerp_angle(target_rotation, move_direction_rotation, rotation_speed * delta)
			
			mesh.rotation.y = target_rotation
		
		# Player Movement
		if Input.get_action_strength("player_run") && Input.get_action_strength("player_forward") && CAN_RUN:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_RUN, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_RUN, SPEED_ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_WALK, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_WALK, SPEED_ACCEL * delta)
				
		move_and_slide()
		
		# Applie Gravity
		if GRAVITY_ON and not is_on_floor():
			velocity.y -= gravity * delta
