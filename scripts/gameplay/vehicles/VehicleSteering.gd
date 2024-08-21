extends Node
class_name VehicleSteering

@export var Vehicle: VehicleBody3D

@export_group("Direction Settings")
@export var max_steering_angle: float = 30.0  # Ângulo máximo das rodas em graus
@export var steering_speed: float = 10.0  # Velocidade com a qual o veículo alcança o ângulo máximo


func SteerVehicle(delta):
	# Captura a entrada de direção do jogador
	Vehicle.steering = move_toward(Vehicle.steering, Input.get_axis("car_right", "car_left") * 1, delta * 2.5)
