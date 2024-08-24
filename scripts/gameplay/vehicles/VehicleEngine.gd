# Still with some errors in question of reversing the vehicle and the brake.

extends Node
class_name VehicleEngine

@export var Vehicle: VehicleBody3D

@export_group("Speed Settings")
@export var SPEED_REVERSE_GEAR = 10 ## Sets the maximum speed of the vehicle in reverse.

var vehicle_reversing = false

@export_group("Engine Settings")
@export var engine_power = 100.0 ## Maximum Engine Power
#@export var max_rpm = 50 ## Este valor pode ser usado como base para o primeiro valor da array 'gears'
#@export var engine_brake = 50 ## Sets the braking force automatically applied when the player is not accelerating.

var current_rpm: int = 0
var engine_force = 0.0

@export_group("Broadcast Settings")
@export var gears: Array[int] ## Array contains the number of gears available in the vehicle. For each gear, you store the maximum RPM value for changing gear.
@export var shift_speed = 0.5 ## The time it takes to change gears, in seconds. ( Not sure if it works. )
#@export var auto_gearbox: bool = true ## Troca automática de marchas.

var current_gear: int = 0
var last_gear_change_time: float = 0.0
var changing_gear: bool = false

@export_group("Braking Settings")
@export var brake_force = 10  ## Sets the force applied to the brakes. Affects braking efficiency.
@export var handbrake_force = 0  ## Sets the force applied by the handbrake, generally used to lock the rear wheels.

@export_group("Debug")
@export var CurrentSpeed: Label
@export var CurrentGear: Label
@export var CurrentRPM: Label

var current_speed: int
var forward_velocity

# Entrada do jogador.
var throttle_input
var brake_input

func _ready() -> void:
	last_gear_change_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	VehicleDebug()
	throttle_input = Input.get_action_strength("car_run") - Input.get_action_strength("car_break")
	brake_input = Input.get_action_strength("car_break")

func EngineController():
	EngineForce()
	GearController()
	
	# RPM System
	current_rpm = (Vehicle.linear_velocity.length() * 60) / (2 * PI)
	current_rpm = min(current_rpm, gears[current_gear])
	
	# Calculates motor power
	engine_force = throttle_input * engine_power

	# Applies engine braking force if the vehicle is decelerating
	if brake_input > 0.1:
		engine_force -= brake_force / 2
	
	var total_brake_force: float = brake_force * brake_input + handbrake_force
	#Vehicle.brake = brake_input * brake_force
	
	forward_velocity = Vehicle.linear_velocity.dot(Vehicle.global_transform.basis.z)

func EngineForce():
	if current_rpm >= gears[current_gear]:
		Vehicle.engine_force = 0
	elif forward_velocity < 0 and current_speed >= SPEED_REVERSE_GEAR:
		Vehicle.engine_force = 0
	else:
		Vehicle.engine_force = engine_force
		
func EngineBrake():
	if Vehicle.state == Vehicle.VehicleState.STOPPED:
		Vehicle.engine_force = engine_force * 0.5

func GearController():
	# +1 gear
	if throttle_input:
		if current_rpm >= gears[current_gear] and current_gear < gears.size() - 1:
			changing_gear = true
			if (Time.get_ticks_msec() - last_gear_change_time) / 1000.0 > shift_speed:
				apply_gear()
				current_gear += 1
				last_gear_change_time = Time.get_ticks_msec()
	else:
		# -1 gear
		if current_rpm < gears[current_gear] * 0.8 and current_gear > 0 and (Time.get_ticks_msec() - last_gear_change_time) / 1000.0 > shift_speed:
			changing_gear = true
			apply_gear()
			current_gear -= 1
			last_gear_change_time = Time.get_ticks_msec()

func apply_gear():
	changing_gear = false

# For Debug
func VehicleDebug():
	if CurrentSpeed != null:
		current_speed = Vehicle.linear_velocity.length() * 3.6
		CurrentSpeed.text = "CurrentSpeed: " + str(current_speed)
	if CurrentGear != null:
		CurrentGear.text = "CurrentGear: " + str(current_gear)
	if CurrentRPM != null:
		CurrentRPM.text = "CurrentRPM: " + str(current_rpm)
