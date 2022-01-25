extends Label

export var fade_in_time = 0.25
export var hold_time = 2
export var fade_out_time = 1.5

onready var tween = $Tween

var display_text: String
var count = 1

func show_event(event: String):
	display_text = event
	text = event
	modulate.a = 0
	$Tween.interpolate_property(self, "modulate:a", 0.0, 1.0, fade_in_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func add_event_count():
	count += 1
	text = "%s (x%d)" % [display_text, count]
