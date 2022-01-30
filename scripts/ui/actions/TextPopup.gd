extends Control

onready var label = $Label
onready var tween = $Tween
var text = "..."

func _ready():
	label.text = text
	
	# Animate the text
	display()

func display():
	var time = 0.6
	tween.interpolate_property(self, 'modulate:a', modulate.a, 0.0, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'rect_position:y', rect_position.y, rect_position.y - 16, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	queue_free()
