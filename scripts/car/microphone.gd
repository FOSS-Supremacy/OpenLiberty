extends AudioStreamPlayer3D

func _input(event):
	if Input.is_action_pressed("switch_microphone"):
		self.playing = not self.playing
		self.stream_paused = not self.stream_paused
