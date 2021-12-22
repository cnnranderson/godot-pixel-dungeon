extends Area2D

const ANIM = {
	"idle": "idle",
	"walk": "walk"
}
const SOUND = {
	"bump": "res://assets/pd_import/sounds/snd_puff.mp3",
	"step": "res://assets/pd_import/sounds/snd_step.mp3"
}

export var move_speed = 4
export var fast_travel_speed = 140

onready var ray : RayCast2D = $MoveRay
onready var tween = $Tween
onready var sprite = $AnimSprite
onready var stats = GameState.player.stats
onready var inventory = GameState.player.inventory
onready var equipped_weapon = GameState.player.equipped.weapon
onready var equpped_armor = GameState.player.equipped.armor

var travel_path: PoolVector2Array
var interrupted_movement = false


func _ready():
	sprite.animation = ANIM.idle
	sprite.playing = true
	Events.connect("player_search", self, "_on_player_search")
	Events.connect("player_equip", self, "_on_player_equip")

func _init_character(spawn: Vector2):
	position = GameState.world.spawn * Constants.TILE_SIZE - (Constants.TILE_V / 2)
	visible = true

func _process(delta):
	move_along_path(fast_travel_speed * delta)

func _input(event):
	if not GameState.player_turn \
			or GameState.inventory_open \
			or $ActionCooldown.time_left > 0 \
			or tween.is_active():
		return
	
	# Attempt an action or movement
	for dir in Constants.INPUTS.keys():
		if event.is_action(dir):
			move(dir)

func move(dir):
	ray.cast_to = Constants.INPUTS[dir] * Constants.TILE_SIZE
	ray.force_raycast_update()
	var new_pos = position + Constants.INPUTS[dir] * Constants.TILE_SIZE
	
	var tpos = GameState.level.world_to_map(new_pos)
	var blocked = false
	var interacted = false
	
	# Check for doors
	if GameState.level.is_door(tpos):
		if GameState.level.is_locked_door(tpos):
			blocked = true
			interacted = can_unlock(tpos)
		else:
			GameState.level.open_door(tpos)
	
	# Try to move
	if interacted:
		$ActionCooldown.start()
	else:
		# Pick up items
		if ray.is_colliding():
			if ray.get_collider() is WorldItem:
				var item = ray.get_collider() as WorldItem
				item.collect()
			else:
				blocked = true
		
		# Otherwise, move
		move_tween(dir, blocked)

func can_unlock(tpos: Vector2):
	if inventory.keys > 0:
		inventory.keys -= 1
		GameState.level.unlock_door(tpos, true)
		Events.emit_signal("player_interact", Item.Type.KEY)
		Events.emit_signal("log_message", "Door unlocked!")
		return true
	else:
		Events.emit_signal("log_message", "You do not have any keys...")
		return false

func move_tween(dir, collides = false):
	if not collides:
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.step, clamp((randi() % 25 + 75) / 100.0, 0.75, 1.0))
		var new_pos = position + Constants.INPUTS[dir] * Constants.TILE_SIZE
		var tile_pos = GameState.level.world_to_map(new_pos)
		# print("Moving: ", GameState.level.world_to_map(new_pos), ", Tile: ", GameState.level.get_tile(tile_pos))
		tween.interpolate_property(self, "position",
			position, new_pos,
			1.0 / move_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	else:
		var origin_pos = position
		var bump_pos = position + Constants.INPUTS[dir] * Constants.TILE_SIZE / 4
		GameState.shake(0.15, 0.6)
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.bump)
		tween.interpolate_property(self, "position",
			position, bump_pos,
			1.0 / move_speed / 2.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(self, "position",
			bump_pos, origin_pos,
			1.0 / move_speed / 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0 / move_speed / 2.0)
		
	sprite.animation = ANIM.walk
	if Constants.INPUTS[dir] == Constants.INPUTS.move_right:
		sprite.flip_h = false
	if Constants.INPUTS[dir] == Constants.INPUTS.move_left:
		sprite.flip_h = true
	tween.start()

func _on_player_equip(item: Item):
	if item is Weapon:
		Events.emit_signal("log_message", "You equipped the %s" % item.name)
		equipped_weapon = item
	pass

func gain_xp(amount):
	while stats.xp < stats.xp_next and amount > 0:
		stats.xp
	stats.xp += amount
	
	Events.emit_signal("player_gain_xp", amount)

func _on_player_search():
	pass

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
