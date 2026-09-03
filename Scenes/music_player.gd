extends AudioStreamPlayer

func _process(_delta: float) -> void:
	self.volume_linear = (Globals.current_settings["audio"]["bgm_volume"] * Globals.current_settings["audio"]["master_volume"])

func play_music(id: String, speed: float = 1.0):
	self.stop()
	self.stream = load("res://Audio/BGM/{name}.ogg".format({"name": id}))
	self.pitch_scale = speed
	self.play()
