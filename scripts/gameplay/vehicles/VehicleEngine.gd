extends Node
class_name VehicleEngine

@export var Vehicle: VehicleBody3D

@export_group("Speed Settings")
@export var MAX_SPEED = 100
@export var MIN_SPEED_REVERSE_GEAR = 10 

@export_group("Engine Settings")
@export var engine_power = 100.0 ## Potência Máxima do Motor
@export var max_rpm = 50 ## Este valor pode ser usado como base para o primeiro valor da array 'gears'
@export var engine_brake = 50 ## Define a força de frenagem aplicada automaticamente quando o jogador não está acelerando.

var current_rpm: int = 0
var engine_force = 0.0

@export_group("Broadcast Settings")
@export var gears: Array[int] ## Array consta o numero de marchas disponiveis no veiculo. Cada marcha você armazena o valor do RPM maximo para a troca da marcha.
@export var shift_speed = 0.5 ## O tempo que leva para trocar de marcha, em segundos.
@export var auto_gearbox: bool = true ## Troca automática de marchas.

var current_gear: int = 0
var last_gear_change_time: float = 0.0
var changing_gear: bool = false

@export_group("Braking Settings")
@export var brake_force = 0  ## Define a força aplicada aos freios. Afeta a eficiência da frenagem.
@export var handbrake_force = 0  ## Define a força aplicada pelo freio de mão, geralmente usada para travar as rodas traseiras.

@export_group("Debug")
@export var CurrentSpeed: Label
@export var CurrentGear: Label
@export var CurrentRPM: Label

var current_speed: int

# Entrada do jogador.
var throttle_input: float = Input.get_action_strength("car_run") - Input.get_action_strength("car_break")
var brake_input: float = Input.get_action_strength("car_break")

func _ready() -> void:
	last_gear_change_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	VehicleDebug()
	throttle_input = Input.get_action_strength("car_run") - Input.get_action_strength("car_break")
	brake_input = Input.get_action_strength("car_break")

func EngineController():
	EngineForce()
	GearController()
	
	current_rpm = (Vehicle.linear_velocity.length() * 60) / (2 * PI)
	current_rpm = min(current_rpm, gears[current_gear])
	
	# Calcula a força do motor
	engine_force = throttle_input * engine_power

	# Aplica a força de frenagem do motor se o veículo estiver desacelerando
	if brake_input > 0.0:
		engine_force -= engine_brake * brake_input
	
	var total_brake_force: float = brake_force * brake_input + handbrake_force
	Vehicle.brake_force = total_brake_force

func EngineForce():
	if current_rpm >= gears[current_gear]:
		Vehicle.engine_force = 0
	else:
		Vehicle.engine_force = engine_force
		
func EngineBrake():
	if Vehicle.state == Vehicle.VehicleState.STOPPED:
		Vehicle.engine_force = engine_force * 0.5

func GearController():
	# Aumenta a marcha
	if throttle_input:
		if current_rpm >= gears[current_gear] and current_gear < gears.size() - 1:
			changing_gear = true
			if (Time.get_ticks_msec() - last_gear_change_time) / 1000.0 > shift_speed:
				apply_gear()
				current_gear += 1
				print("Marcha aumentada para: ", current_gear)
				last_gear_change_time = Time.get_ticks_msec()
	else:
		# Diminui a marcha
		if current_rpm < gears[current_gear] * 0.8 and current_gear > 0 and (Time.get_ticks_msec() - last_gear_change_time) / 1000.0 > shift_speed:
			changing_gear = true
			apply_gear()
			current_gear -= 1
			print("Marcha diminuída para: ", current_gear)
			last_gear_change_time = Time.get_ticks_msec()

func apply_gear():
	changing_gear = false

func VehicleDebug():
	if CurrentSpeed != null:
		current_speed = Vehicle.linear_velocity.length() * 3.6
		CurrentSpeed.text = "CurrentSpeed: " + str(current_speed)
	if CurrentGear != null:
		CurrentGear.text = "CurrentGear: " + str(current_gear)
	if CurrentRPM != null:
		CurrentRPM.text = "CurrentRPM: " + str(current_rpm)
