extends Area2D

export(int) var t_width = 3
export(int) var t_height = 3

onready var collision_shape = $CollisionShape2D
onready var wake_sprite = $Waking
onready var sleep_sprite = $Sleeping

func _ready():
	collision_shape.shape.extents = Vector2(t_width, t_height) * Constants.TILE_SIZE

func _animate():
	$Tween.interpolate_property(wake_sprite, "scale",
			wake_sprite.scale, 2, 0.8, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "modulate:a",
			modulate.a, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.0)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

func _on_WakeArea_area_entered(actor):
	if actor is Player:
		var parent = get_parent()
		sleep_sprite.visible = false
		wake_sprite.visible = true
		
		if parent is Actor:
			_animate()
			parent.should_wake = true
			parent.act_time = actor.act_time + 1
