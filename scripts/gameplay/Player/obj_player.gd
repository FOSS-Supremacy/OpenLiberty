extends CharacterBody3D

var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

# <--------------------------->
@onready var mesh = $mesh
@onready var cam_pivot: Node3D = $cameraPivot
@onready var spring_arm_3d: SpringArm3D = $cameraPivot/SpringArm

# <--------------------------->
@export var sensitivity = 0.02
@export var gravity:float = 9.8

@export_group("Player")
@export var SPEED_WALK = 4
@export var SPEED_RUN = 6
var SPEED_ACCEL = 30

@export_group("Flags")
@export var CAN_MOVE:bool = true
@export var CAN_RUN = true
@export var GRAVITY_ON:bool = false


var rotation_speed = 10.0 # for player rotation.

# <--------------------------->
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_pivot.rotate_y(-event.relative.x * sensitivity/2)
		spring_arm_3d.rotate_x(-event.relative.y * sensitivity/2)
		spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, -PI/3, PI/5)

func _physics_process(delta: float) -> void:
	movement_behavior(delta)
	
func movement_behavior(delta):
	if CAN_MOVE:
		# Direction of movement based on player direction
		move_dir = Vector3(
			Input.get_action_strength("player_m_right") - Input.get_action_strength("player_m_left"),
			0.0,
			Input.get_action_strength("player_m_backward") - Input.get_action_strength("player_m_forward")
		).normalized()
		
		move_dir = move_dir.rotated(Vector3.UP, cam_pivot.rotation.y)
		
		# Rotates the mesh in the direction of movement with a smooth transition
		if move_dir.length() > 0.1:
			var target_rotation = mesh.global_transform.basis.get_euler().y
			var move_direction_rotation = atan2(-move_dir.x, -move_dir.z)
			target_rotation = lerp_angle(target_rotation, move_direction_rotation, rotation_speed * delta)
			
			mesh.rotation.y = target_rotation
		
		# Player Movement
		if Input.get_action_strength("player_m_run") && Input.get_action_strength("player_m_forward") && CAN_RUN:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_RUN, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_RUN, SPEED_ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_WALK, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_WALK, SPEED_ACCEL * delta)
				
		move_and_slide()

		# Applie Gravity
		if GRAVITY_ON and not is_on_floor():
			velocity.y -= gravity * delta
