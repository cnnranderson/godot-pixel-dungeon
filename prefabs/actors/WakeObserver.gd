extends Area2D

export(int) var t_width = 3
export(int) var t_height = 3

onready var collision_shape = $CollisionShape2D
onready var wake_sprite = $Waking
onready var sleep_sprite = $Sleeping
onready var actor = get_parent()

func _ready():
	collision_shape.shape.extents = Vector2(t_width, t_height) * Constants.TILE_SIZE

func _process(delta):
	if get_parent() is Actor:
		if get_parent().should_wake and not get_parent().is_awake:
			_should_sleep(false)
		if not get_parent().is_awake and not get_parent().should_wake:
			_should_sleep(true)

func _should_sleep(sleeping: bool):
	sleep_sprite.visible = sleeping
	wake_sprite.visible = not sleeping

func _on_WakeArea_area_entered(actor):
	if actor is Player:
		var parent = get_parent()
		if parent is Actor:
			parent.should_wake = true
			parent.act_time = actor.act_time + 1
