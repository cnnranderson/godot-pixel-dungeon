extends Control

@onready var label = $Label

var amount = 0
var is_crit = false
var is_heal = false
var tween: Tween

func _ready():
	label.text = "%d" % amount
	
	if is_heal:
		set_heal()
	elif is_crit:
		set_crit()
	
	# Animate the hit
	display()

func set_heal():
	label.modulate = Color.GREEN
	amount *= -1

func set_crit():
	label.text += "!"
	label.modulate = Color.RED
	scale = Vector2.ONE * 2

func display():
	var scale_time = .6
	var move_time = .8
	scale = Vector2(0.8, 0.8)
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), scale_time) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0, move_time) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:x", position.x + randi() % 20 - 10, move_time) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - randi() % 12 - 2, move_time) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()
