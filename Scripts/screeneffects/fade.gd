extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

func fade_out():
	self.visible = true
	
	# Create a tween that handles the animation smoothly
	var tween = create_tween()
	
	# Set the starting color to transparent black
	$FadeColor.color = Color(0, 0, 0, 0)
	
	# Animate the 'color' property to solid black over 1.0 second
	tween.tween_property($FadeColor, "color", Color(0, 0, 0, 1), 1.0)
	
	# Wait cleanly until the tween finishes completely
	await tween.finished
	self.visible = true

func fade_in():
	self.visible = true
	
	var tween = create_tween()
	
	# Set starting color to solid black
	$FadeColor.color = Color(0, 0, 0, 1)
	
	# Animate to transparent black over 1.0 second
	tween.tween_property($FadeColor, "color", Color(0, 0, 0, 0), 1.0)
	
	await tween.finished
	self.visible = false
