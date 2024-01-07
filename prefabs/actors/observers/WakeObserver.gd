extends Area2D

@export var t_width: int = 3
@export var t_height: int = 3

@onready var collision_shape = $CollisionShape2D
@onready var wake_sprite = $Waking
@onready var sleep_sprite = $Sleeping

var tween: Tween

func _ready():
	collision_shape.shape.size = Vector2i(t_width, t_height) * Constants.TILE_SIZE

func _animate():
	tween = create_tween()
	tween.tween_property(self, "scale", wake_sprite.scale * 1.5, 0.6) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0, 0.5) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_OUT).set_delay(0.6)
	await tween.finished
	queue_free()

func _on_WakeArea_area_entered(actor):
	if actor is Player:
		var parent = get_parent()
		sleep_sprite.visible = false
		wake_sprite.visible = true
		
		if parent is Actor:
			parent.should_wake = true
			_animate()
