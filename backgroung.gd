extends ColorRect

func _ready() -> void:
	while true:
		var red = snapped(randf_range(0.0, 0.3), 0.01)
		var green = snapped(randf_range(0.0, 0.3), 0.01)
		var blue = snapped(randf_range(0.0, 0.3), 0.01)
		var red_step = red / 100
		var green_step = green / 100
		var blue_step = blue / 100
		var red_current = 0
		var green_current = 0
		var blue_current = 0
		for i in range(100):
			self.color = Color(red_current, green_current, blue_current, 1)
			red_current += red_step
			green_current += green_step
			blue_current += blue_step
			await get_tree().create_timer(0.01).timeout
		await get_tree().create_timer(1.0).timeout
		for i in range(100):
			self.color = Color(red_current, green_current, blue_current, 1)
			red_current -= red_step
			green_current -= green_step
			blue_current -= blue_step
			await get_tree().create_timer(0.01).timeout
