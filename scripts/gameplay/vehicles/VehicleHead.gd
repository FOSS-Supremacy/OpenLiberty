extends VehicleBody3D
@export var state:VehicleState = VehicleState.STOPPED
enum VehicleState {
	PLAYER_DRIVING,
	NPC_DRIVING,
	STOPPED
}

var speed = 0

@export_group("General Properties")
@export var VehicleMass: = 0 ## Define a massa do veículo em quilogramas (kg). 
@export var CenterOfMass = Vector3(0,0,0) ## Define a massa do veículo em quilogramas (kg). 
@export_group("Suspension Settings")
@export var suspension_stiffness = 0 ##  Define quão rígida ou macia é a suspensão. Valores mais altos resultam em uma suspensão mais rígida.
@export_group("Wheel Settings")
@export var tire_grip = 0 ## Define quanta tração os pneus têm na superfície. Valores mais altos resultam em melhor aderência.
@export var wheel_radius = 0 ## Define o tamanho das rodas, o que afeta a altura do veículo e o comportamento de direção.
@export var wheel_friction_slip = 0 ## Controla a quantidade de derrapagem que ocorre durante a direção. Valores mais baixos permitem mais deslizamento.
@export_group("Braking Settings")
@export var brake_force = 0 ## Define a força aplicada aos freios. Afeta a eficiência da frenagem.
@export var handbrake_force = 0 ## Define a força aplicada pelo freio de mão, geralmente usada para travar as rodas traseiras.
@export_group("Other Settings")
@export var downforce = 0 ## Simula a pressão aerodinâmica que empurra o carro para baixo, aumentando a aderência em altas velocidades.
@export var traction_control:bool = false ## Controle de tração, que impede que as rodas patinem durante a aceleração.
@export var abs:bool = false ## Sistema de freio ABS, que impede que as rodas travem durante a frenagem.

@onready var driver: Node3D = $CarView/Driver

# Getting in and out of the car
var player # player ref
var player_can_interact = false
var player_in_area = false

# camera rotation based on direction
var camera_rotation = 0.0

func _physics_process(delta):
	StateController() # Controlador do estado do carro.
	
	match state:
		VehicleState.PLAYER_DRIVING:
			$VehicleNodes/VehicleEngine.EngineController()
			$VehicleNodes/VehicleSteering.SteerVehicle(delta)
		VehicleState.STOPPED:
			$VehicleNodes/VehicleEngine.EngineBrake()
	
	#DriverController(delta) 
	
	EnterAndExit() # Mecanica de entrar e sair do carro.

func StateController(): # Car state controller
	# <--->
	if state == VehicleState.PLAYER_DRIVING: # Por enquanto, controla apenas a camera.
		$VehicleCameraController.ControllerState = $VehicleCameraController.CameraState.ACTIVE
	elif state == VehicleState.NPC_DRIVING:
		$VehicleCameraController.ControllerState = $VehicleCameraController.CameraState.DISABLE
	else:
		$VehicleCameraController.ControllerState = $VehicleCameraController.CameraState.DISABLE
	# <--->
	if state == VehicleState.PLAYER_DRIVING: # Define alguns parametros quando o jogador está ou não no carro.
		driver.show()
		$CarInterface/VBoxContainer.show()
	#else:
		#driver.hide()
		#$CarInterface/VBoxContainer.hide()
	# <--->	
	if player_in_area: # Usado para definir se o jogador pode ou não interagir com o carro.
		if state == VehicleState.STOPPED:
			player_can_interact = true
		elif state == VehicleState.PLAYER_DRIVING:
			player_can_interact = false
	else:
		player_can_interact = false
	# <--->

func DriverController(delta): # Mecanica de dirigir.
	if state == VehicleState.PLAYER_DRIVING:
		pass
		
	elif state == VehicleState.STOPPED:
		pass
		
func EnterAndExit(): # Mecanica de entrar e sair do carro.
	if Input.is_action_just_pressed("enter_car") and player != null:
		if state == VehicleState.STOPPED:
			if player_can_interact:
				state = VehicleState.PLAYER_DRIVING
				player.global_transform.origin = Vector3(0,-200,0)
		elif state == VehicleState.PLAYER_DRIVING:
			state = VehicleState.STOPPED
			state = VehicleState.STOPPED
			player.global_transform.origin = $ExitMarked.global_transform.origin
			
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
