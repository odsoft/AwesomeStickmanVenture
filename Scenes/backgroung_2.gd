extends ColorRect

func _ready() -> void:
	while true:
		var blue = 0.4
		var blue_step = blue / 100
		var blue_current = 0
		for i in range(100):
			self.color = Color(0, 0, blue_current, 1)
			blue_current += blue_step
			await get_tree().create_timer(0.01).timeout
		await get_tree().create_timer(1.0).timeout
		for i in range(100):
			self.color = Color(0, 0, blue_current, 1)
			blue_current -= blue_step
			await get_tree().create_timer(0.01).timeout
