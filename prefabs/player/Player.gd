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
onready var inventory = GameState.player.inventory

export var move_speed = 4
export var fast_travel_speed = 140

var travel_path: PoolVector2Array
var interrupted_movement = false

func _ready():
	sprite.animation = ANIM.idle
	sprite.playing = true

func _init_character(spawn: Vector2):
	position = GameState.world.spawn * Global.TILE_SIZE - (Global.TILE_V / 2)
	visible = true
	
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
	var new_pos = position + Global.INPUTS[dir] * Global.TILE_SIZE
	
	var tpos = GameState.level.world_to_map(new_pos)
	var blocked = false
	# Check for doors
	if GameState.level.is_door(tpos):
		if GameState.level.is_locked_door(tpos):
			can_unlock(tpos)
			blocked = true
		else:
			GameState.level.open_door(tpos)
	
	# Try to move
	if !ray.is_colliding() and not blocked:
		move_tween(dir)
	else:
		move_tween(dir, true)

func can_unlock(tpos: Vector2):
	if inventory.keys > 0:
		GameState.level.unlock_door(tpos, true)
		inventory.keys -= 1
		return true
	return false

func move_tween(dir, collides = false):
	if not collides:
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.step, clamp((randi() % 25 + 75) / 100.0, 0.75, 1.0))
		var new_pos = position + Global.INPUTS[dir] * Global.TILE_SIZE
		var tile_pos = GameState.level.world_to_map(new_pos)
		print("Moving: ", GameState.level.world_to_map(new_pos), ", Tile: ", GameState.level.get_tile(tile_pos))
		tween.interpolate_property(self, "position",
			position, new_pos,
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

# TODO Fix all of this nonsense
func move_along_path(speed):
	if travel_path.size() > 0:
		var final = Helpers.tile_to_world(travel_path[0])
		if abs(position.x - final.x) < 1 and abs(position.y - final.y) < 1:
			position = final
			if interrupted_movement:
				travel_path = []
				interrupted_movement = false
			else:
				travel_path.remove(0)
			if travel_path.size() == 0:
				sprite.animation = ANIM.idle
			else:
				sprite.animation = ANIM.walk
				Sounds.play_sound(Sounds.SoundType.SFX, SOUND.step, clamp((randi() % 25 + 75) / 100.0, 0.75, 1.0))
		else:
			var distance = position.distance_to(Helpers.tile_to_world(travel_path[0]))
			var direction = (Helpers.world_to_tile(position) - travel_path[0]).normalized()
			position = position.linear_interpolate(Helpers.tile_to_world(travel_path[0]), speed / distance)
			if direction == Global.INPUTS.move_right:
				sprite.flip_h = true
			if direction == Global.INPUTS.move_left:
				sprite.flip_h = false
			auto_open_door(travel_path[0])

func auto_open_door(tpos):
	#if GameState.world._get_cell(tpos) == GameWorld.TILE.door_closed:
		#GameState.world.open_door(tpos)
	pass

