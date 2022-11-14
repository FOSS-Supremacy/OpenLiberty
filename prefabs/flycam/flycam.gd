extends Node3D


@export var sensitivity := 1.0
@export var speed := 2.0

var _mouselook: bool


func _process(delta: float) -> void:
	if _mouselook:
		var hvec := Input.get_vector("movement_left", "movement_right", "movement_backward", "movement_forward")
		var vvec := Input.get_axis("movement_down", "movement_up")
		var mmult := (
			(delta * speed) * 2 if Input.is_key_pressed(KEY_SHIFT)
			else delta * speed
		)
		
		position += (
			hvec.x * transform.basis.x +
			vvec * transform.basis.y +
			hvec.y * -transform.basis.z
		) * mmult


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_mouselook = event.pressed
			
			if _mouselook:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			speed += 1.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			speed = clampf(speed - 1.0, 0.0, INF)
	elif event is InputEventMouseMotion && _mouselook:
		rotation.x = clampf(rotation.x - deg_to_rad(event.relative.y * sensitivity), -90.0, 90.0)
		rotation.y -= deg_to_rad(event.relative.x * sensitivity)
