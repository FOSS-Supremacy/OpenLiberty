extends AudioStreamPlayer

func _input(event):
	if Input.is_action_just_pressed("play_pause_music"):
		play()
	if Input.is_action_pressed("decrease_music_volume"):
		volume_db = volume_db - 2
	if Input.is_action_pressed("increase_music_volume"):
		volume_db = volume_db + 2
