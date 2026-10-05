extends Control

func _ready() -> void:
	print("Awesome Stickman Venture")
	print("(c) OdSoft")
	$CanvasLayer/SplashPlayer.stream = load("res://odsoft-splash.ogv")
	$CanvasLayer/SplashPlayer.play()


func _on_splash_player_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
