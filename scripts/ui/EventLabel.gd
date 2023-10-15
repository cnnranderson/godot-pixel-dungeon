extends Label

@export var fade_in_time = 0.25
@export var hold_time = 2
@export var fade_out_time = 1.5

var display_text: String
var tween: Tween
var count = 1

func show_event(event: String):
	display_text = event
	text = event
	modulate.a = 0
	
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, fade_in_time) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN)

func add_event_count():
	count += 1
	text = "%s (x%d)" % [display_text, count]
