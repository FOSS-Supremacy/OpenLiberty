extends Node
class_name VehicleSteering

@export var Vehicle: VehicleBody3D

@export_group("Direction Settings")
@export var max_steering_angle: float = 30.0  ## Ângulo máximo das rodas em graus
@export var steering_speed: float = 10.0  ## Velocidade com a qual o veículo alcança o ângulo máximo
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

func SteerVehicle(delta):
	# Captura a entrada de direção do jogador
	Vehicle.steering = move_toward(Vehicle.steering, Input.get_axis("car_right", "car_left") * 1, delta * 2.5)
