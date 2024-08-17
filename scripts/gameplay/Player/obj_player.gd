extends CharacterBody3D

@onready var mesh: MeshInstance3D = $mesh
@onready var cam_pivot: Node3D = $cameraPivot
@onready var spring_arm_3d: SpringArm3D = $cameraPivot/SpringArm

const SPEED = 2
const LERP_VAL = 0.15

var sensitivity = 0.05

var gravity = get_gravity()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_pivot.rotate_y(-event.relative.x * .005)
		spring_arm_3d.rotate_x(-event.relative.y * .005)
		spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, -PI/4, PI/4)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("player_m_left", "player_m_right", "player_m_forward", "player_m_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, cam_pivot.rotation.y)
	
	if not is_on_floor():
		velocity.y -= 10 * delta
	
	if direction.length() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
