extends Area2D

@export var t_width: int = 3
@export var t_height: int = 3

@onready var collision_shape = $CollisionShape2D
@onready var wake_sprite = $Waking
@onready var sleep_sprite = $Sleeping

func _ready():
	collision_shape.shape.size = Vector2(t_width, t_height) * Constants.TILE_SIZE

func _animate():
	#$Tween.interpolate_property(wake_sprite, "scale",
			#wake_sprite.scale, wake_sprite.scale * 1.5, 0.6, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	#$Tween.interpolate_property(self, "modulate:a",
			#modulate.a, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.6)
	#$Tween.start()
	#await $Tween.tween_all_completed
	queue_free()

func _on_WakeArea_area_entered(actor):
	if actor is Player:
		var parent = get_parent()
		sleep_sprite.visible = false
		wake_sprite.visible = true
		
		if parent is Actor:
			parent.should_wake = true
			_animate()
