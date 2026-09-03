extends AudioStreamPlayer


func play_effect(id: String):
	self.stop()
	self.volume_linear = (Globals.current_settings["audio"]["sfx_volume"] * Globals.current_settings["audio"]["master_volume"])
	self.stream = load("res://Audio/SFX/{name}.wav".format({"name": id}))
	self.play()

func test_sound():
	self.stop()
	self.volume_linear = (Globals.current_settings["audio"]["sfx_volume"] * Globals.current_settings["audio"]["master_volume"])
	self.stream = load("res://Audio/SFX/test.wav")
	self.play()

func test_music():
	self.stop()
	self.volume_linear = (Globals.current_settings["audio"]["bgm_volume"] * Globals.current_settings["audio"]["master_volume"])
	self.stream = load("res://Audio/SFX/test.wav")
	self.play()
