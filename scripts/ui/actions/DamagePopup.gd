extends Control

onready var label = $Label
onready var tween = $Tween
var amount = 0
var is_crit = false
var is_heal = false

func _ready():
	if is_heal:
		set_heal()
	elif is_crit:
		set_crit()
	
	label.text = "%d" % amount
	
	# Animate the hit
	display()

func set_heal():
	label.modulate = Color.green
	amount *= -1

func set_crit():
	label.text += "!!"
	label.modulate = Color.red
	rect_scale = Vector2.ONE * 2

func display():
	tween.interpolate_property(self, 'rect_scale', Vector2(0.8, 0.8), Vector2(1.5, 1.5), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'modulate:a', modulate.a, 0.0, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self, 'rect_position:x', rect_position.x, rect_position.x + randi() % 20 - 10, 0.8, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'rect_position:y', rect_position.y, rect_position.y - randi() % 4, 0.8, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	queue_free()
