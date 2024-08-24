# Still open for improvements and optimization.
# by: a6xdev, ...

extends Node
class_name VehicleSteering

@export var Vehicle: VehicleBody3D

@export_group("Direction Settings")
#@export var max_steering_angle: float = 30.0  ## Ângulo máximo das rodas em graus
@export var steering_speed: float = 10.0  ## Speed ​​at which the vehicle reaches the maximum angle

@export_group("Suspension Settings")
@export var suspension_damping: float = 2.0 ## Suspension damping
@export var max_suspension_shift: float = 0.05 ## Reduced to soften the effect on the suspension

@export_group("Wheel Settings")
@export var tire_grip = 1.5  ## Sets the tire's grip on the surface. Lower values ​​provide greater traction, improving cornering stability, while higher values ​​result in more slippage and reduced cornering control.
@export var FrontLeftWheel: VehicleWheel3D
@export var FrontRightWheel: VehicleWheel3D
@export var BackLeftWheel: VehicleWheel3D
@export var BackRightWheel: VehicleWheel3D


#@export_group("Other Settings")
#@export var downforce = 0
#@export var traction_control: bool = false
#@export var abs: bool = false

func SteerVehicle(delta):
	adjust_suspension(delta)
	set_tire_grip()

	# Captures player steering input and adjusts vehicle steering
	Vehicle.steering = move_toward(Vehicle.steering, Input.get_axis("car_right", "car_left") * 1, delta * steering_speed)

func adjust_suspension(delta):
	var target_shift = 0.0
	
	if Vehicle.linear_velocity.length() > 3:
		if Input.is_action_pressed("car_right"):
			# Suspension adjustment for right turn
			target_shift = -max_suspension_shift
		elif Input.is_action_pressed("car_left"):
			# Suspension adjustment for left turn
			target_shift = max_suspension_shift

	# Smooth application of suspension change using lerp
	FrontLeftWheel.wheel_rest_length = lerp(FrontLeftWheel.wheel_rest_length, 0.15 + target_shift, delta * suspension_damping)
	FrontRightWheel.wheel_rest_length = lerp(FrontRightWheel.wheel_rest_length, 0.15 - target_shift, delta * suspension_damping)
	BackLeftWheel.wheel_rest_length = lerp(BackLeftWheel.wheel_rest_length, 0.15 + target_shift, delta * suspension_damping)
	BackRightWheel.wheel_rest_length = lerp(BackRightWheel.wheel_rest_length, 0.15 - target_shift, delta * suspension_damping)

func reset_suspension(delta):
	# Reset wheel positions to original state using lerp
	FrontLeftWheel.wheel_rest_length = lerp(FrontLeftWheel.wheel_rest_length, 0.15, delta * suspension_damping)
	FrontRightWheel.wheel_rest_length = lerp(FrontRightWheel.wheel_rest_length, 0.15, delta * suspension_damping)
	BackLeftWheel.wheel_rest_length = lerp(BackLeftWheel.wheel_rest_length, 0.15, delta * suspension_damping)
	BackRightWheel.wheel_rest_length = lerp(BackRightWheel.wheel_rest_length, 0.15, delta * suspension_damping)

func set_tire_grip():
	# Applies the value of 'tire_grip' to all wheels
	FrontLeftWheel.wheel_friction_slip = tire_grip
	FrontRightWheel.wheel_friction_slip = tire_grip
	BackLeftWheel.wheel_friction_slip = tire_grip
	BackRightWheel.wheel_friction_slip = tire_grip
