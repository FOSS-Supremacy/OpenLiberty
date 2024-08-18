extends VehicleBody3D

@export var state:VehicleState = VehicleState.STOPPED
enum VehicleState {
	PLAYER_DRIVING,
	NPC_DRIVING,
	STOPPED
}

@export var MAX_STEER = 0.8
@export var ENGINE_POWER = 300
@export var DECELERATION_RATE = 500

@onready var driver: Node3D = $Driver

# Getting in and out of the car
var player # player ref
var player_can_interact = false
var player_in_area = false

func _physics_process(delta):
	StateController()
	DriverController(delta)
	
	if player_in_area:
		if state == VehicleState.STOPPED:
			player_can_interact = true
		elif state == VehicleState.PLAYER_DRIVING:
			player_can_interact = false
	else:
		player_can_interact = false
		
	if Input.is_action_just_pressed("enter_car") and player != null:
		if state == VehicleState.STOPPED:
			if player_can_interact:
				state = VehicleState.PLAYER_DRIVING
				player.global_transform.origin = Vector3(0,-200,0)
		elif state == VehicleState.PLAYER_DRIVING:
			state = VehicleState.STOPPED
			state = VehicleState.STOPPED
			player.global_transform.origin = $ExitMarked.global_transform.origin

#/////////////////////// ///////////////////////
#/////////////// Driving mechanics. I recommend that any update to the way the player drives be done here.
#/////////////////////// ///////////////////////
func DriverController(delta):
	if state == VehicleState.PLAYER_DRIVING:
		steering = move_toward(steering, Input.get_axis("car_right", "car_left") * MAX_STEER, delta * 2.5)
		engine_force = Input.get_axis("car_break", "car_run") * ENGINE_POWER
	elif state == VehicleState.STOPPED:
		if engine_force > 0:
			engine_force = move_toward(engine_force, 0, delta * DECELERATION_RATE)
		else:
			engine_force = 0

#/////////////////////// ///////////////////////
#/////////////// Car State Controller.
#/////////////////////// ///////////////////////
func StateController():
	if state == VehicleState.PLAYER_DRIVING:
		$VehicleCameraController.ControllerState = $VehicleCameraController.CameraState.ACTIVE
		driver.show()
	elif state == VehicleState.NPC_DRIVING:
		$VehicleCameraController.ControllerState = $VehicleCameraController.CameraState.DISABLE
		driver.hide()
	else:
		$VehicleCameraController.ControllerState = $VehicleCameraController.CameraState.DISABLE
		driver.hide()

#/////////////////////// ///////////////////////
#/////////////// Disabled.
#/////////////////////// ///////////////////////
#func NewPlayer(NewPosition): # Instancia um novo player.
	#var PlayerTSCN = preload("res://prefabs/actors/player/obj_player.tscn")
	#var PlayerIN = PlayerTSCN.instantiate()
	#add_child(PlayerIN)
	#PlayerIN.global_transform.origin = NewPosition

func PlayerEnteredInteractArea(body: Node3D) -> void:
	if body is Player:
		player = body
		player_can_interact = true
		player_in_area = true

func PlayerExitedInteractArea(body: Node3D) -> void:
	if body is Player:
		pass
		#player = null
		player_can_interact = false
		player_in_area = false
