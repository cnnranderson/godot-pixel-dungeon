extends Label

export var fade_in_time = 0.25
export var hold_time = 2
export var fade_out_time = 1.5

func show_event(event: String):
	text = event
	modulate.a = 0
	$Tween.interpolate_property(self, "modulate:a", 0.0, 1.0, fade_in_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "modulate:a", 1.0, 0.0, fade_out_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, hold_time + fade_in_time)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()
