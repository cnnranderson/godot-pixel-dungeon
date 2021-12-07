extends Area2D

const ANIM = {
	"idle": "idle",
	"walk": "walk"
}

const SOUND = {
	"bump": "res://assets/pd_import/sounds/snd_puff.mp3",
	"step": "res://assets/pd_import/sounds/snd_step.mp3"
}

onready var ray : RayCast2D = $MoveRay
onready var tween = $Tween
onready var sprite = $AnimSprite

export var move_speed = 4
export var fast_travel_speed = 100

var travel_path: PoolVector2Array

func _ready():
	position = position.snapped(Vector2.ONE * Global.TILE_SIZE * 2)
	position += Vector2.ONE * Global.TILE_SIZE / 2
	sprite.animation = ANIM.idle
	sprite.playing = true

func _process(delta):
	move_along_path(fast_travel_speed * delta)

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
		var collider_tpos = Helpers.world_to_tile(ray.get_collision_point() + Global.INPUTS[dir] * Global.TILE_V / 2)
		if GameState.grid.get_cell(collider_tpos) == Grid.TILE.door_closed:
			GameState.grid.open_door(collider_tpos)
			move_tween(dir)
		else:
			move_tween(dir, true)

func move_tween(dir, collides = false):
	if not collides:
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.step, clamp((randi() % 25 + 75) / 100.0, 0.75, 1.0))
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
	if Global.INPUTS[dir] == Global.INPUTS.move_right:
		sprite.flip_h = false
	if Global.INPUTS[dir] == Global.INPUTS.move_left:
		sprite.flip_h = true
	tween.start()

func _on_Tween_tween_all_completed():
	sprite.animation = ANIM.idle
	sprite.playing = true

func move_along_path(dist):
	if travel_path.size() > 0:
		var final = Helpers.tile_to_world(travel_path[0])
		if abs(position.x - final.x) < 1 and abs(position.y - final.y) < 1:
			position = final
			travel_path.remove(0)
			if travel_path.size() == 0:
				sprite.animation = ANIM.idle
			else:
				sprite.animation = ANIM.walk
				Sounds.play_sound(Sounds.SoundType.SFX, SOUND.step, clamp((randi() % 25 + 75) / 100.0, 0.75, 1.0))
		else:
			var direction = position.distance_to(Helpers.tile_to_world(travel_path[0]))
			position = position.linear_interpolate(Helpers.tile_to_world(travel_path[0]), dist / direction)
