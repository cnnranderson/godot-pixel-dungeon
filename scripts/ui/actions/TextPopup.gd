extends Control

@onready var label = $Label

var tween: Tween
var text = "..."

func _ready():
	label.text = text
	
	# Animate the text
	display()

func display():
	var time = 0.6
	modulate.a = 1.0
	
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 8, time) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, time) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT)
		
	await tween.finished
	queue_free()
