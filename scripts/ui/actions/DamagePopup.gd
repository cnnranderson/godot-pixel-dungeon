extends Control

onready var label = $Label
onready var tween = $Tween
var amount = 0
var is_crit = false

func _ready():
	label.text = "%d" % amount
	
	# Animate the hit
	crit_hit() if is_crit else normal_hit()

func normal_hit():
	tween.interpolate_property(self, 'rect_scale', rect_scale, Vector2(0.2, 0.2), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'rect_position:x', rect_position.x, rect_position.x + randi() % 20 - 10, 0.8, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'rect_position:y', rect_position.y, rect_position.y - randi() % 4, 0.8, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	queue_free()

func crit_hit():
	label.text += "!!"
	label.modulate = Color.red
	rect_scale = Vector2.ONE * 2
	tween.interpolate_property(self, 'rect_scale', rect_scale, Vector2(0.2, 0.2), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'rect_position:x', rect_position.x, rect_position.x + randi() % 20 - 10, 0.8, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'rect_position:y', rect_position.y, rect_position.y - randi() % 4, 0.8, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	queue_free()
