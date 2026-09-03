extends Control
func _ready() -> void:
	Globals.load_dirs()
	Globals.initialize_settings()
	Globals.load_settings()
	Globals.save_settings()
	Globals.apply_settings()
	print("[INFO] Continuing...")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/splash_screen.tscn")
