extends Control

func _ready() -> void:
	print("Awesome Stickman Venture")
	print("(c) OdSoft")
	await get_tree().create_timer(0.5).timeout
	$CanvasLayer/PresentsLabel.visible = true
	await get_tree().create_timer(1.5).timeout
	$CanvasLayer/PresentsLabel.visible = false
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
