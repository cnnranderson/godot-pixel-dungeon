extends Area2D

const ANIM = {
	"idle": "idle",
	"walk": "walk"
}

const SOUND = {
	"bump": "res://assets/pd_import/sounds/snd_puff.mp3",
	"step": "res://assets/pd_import/sounds/snd_step.mp3"
}

onready var ray = $MoveRay
onready var tween = $Tween
onready var sprite = $AnimSprite

export var move_speed = 4

func _ready():
	position = position.snapped(Vector2.ONE * Global.TILE_SIZE * 2)
	position += Vector2.ONE * Global.TILE_SIZE / 2
	sprite.animation = ANIM.idle
	sprite.playing = true

func _input(event):
	if tween.is_active():
		return
	for dir in Global.INPUTS.keys():
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	ray.cast_to = Global.INPUTS[dir] * Global.TILE_SIZE
	ray.force_raycast_update()
	if !ray.is_colliding():
		move_tween(dir)
	else:
		move_tween(dir, true)

func move_tween(dir, collides = false):
	if not collides:
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.step)
		tween.interpolate_property(self, "position",
			position, position + Global.INPUTS[dir] * Global.TILE_SIZE,
			1.0 / move_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	else:
		var origin_pos = position
		var bump_pos = position + Global.INPUTS[dir] * Global.TILE_SIZE / 4
		GameState.shake(0.15, 0.6)
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.bump)
		tween.interpolate_property(self, "position",
			position, bump_pos,
			1.0 / move_speed / 2.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(self, "position",
			bump_pos, origin_pos,
			1.0 / move_speed / 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0 / move_speed / 2.0)
		
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
