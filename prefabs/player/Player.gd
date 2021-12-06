extends Area2D

const ANIM = {
	"idle": "idle",
	"walk": "walk"
}

onready var ray = $MoveRay
onready var tween = $Tween
onready var sprite = $AnimSprite

export var move_speed = 3

func _ready():
	position = position.snapped(Vector2.ONE * Global.TILE_SIZE)
	position += Vector2.ONE * Global.TILE_SIZE / 2
	sprite.animation = ANIM.idle
	sprite.playing = true

func _unhandled_input(event):
	if tween.is_active():
		return
	for dir in Global.INPUTS.keys():
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	ray.cast_to = Global.INPUTS[dir] * Global.TILE_SIZE
	ray.force_raycast_update()
	if !ray.is_colliding():
		# position += Global.INPUTS[dir] * Global.TILE_SIZE
		move_tween(dir)

func move_tween(dir):
	tween.interpolate_property(self, "position",
		position, position + Global.INPUTS[dir] * Global.TILE_SIZE,
		1.0/move_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	sprite.animation = ANIM.walk
	sprite.playing = true
	if Global.INPUTS[dir] == Global.INPUTS.move_right:
		sprite.flip_h = false
	if Global.INPUTS[dir] == Global.INPUTS.move_left:
		sprite.flip_h = true
	tween.start()

func _on_Tween_tween_all_completed():
	sprite.animation = ANIM.idle
	sprite.playing = true
