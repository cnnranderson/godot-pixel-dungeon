extends Actor
class_name Player

const ANIM = {
	"idle": "idle",
	"walk": "walk"
}

export var move_speed = 4
export var fast_travel_speed = 140
export var crit_chance = 30

onready var ray: RayCast2D = $MoveRay
onready var tween = $Tween
onready var sprite = $AnimSprite
onready var stats = GameState.player.stats
onready var inventory = GameState.player.inventory
onready var backpack = GameState.player.backpack

func _ready():
	sprite.animation = ANIM.idle
	sprite.playing = true
	is_awake = true
	Events.connect("player_wait", self, "_on_player_wait")
	Events.connect("player_search", self, "_on_player_search")
	Events.connect("player_equip", self, "_on_player_equip")
	Events.connect("player_unequip_weapon", self, "_on_player_unequip_weapon")
	Events.connect("player_unequip_armor", self, "_on_player_unequip_armor")

func _init_character(spawn: Vector2):
	position = GameState.world.spawn * Constants.TILE_SIZE - (Constants.TILE_V / 2)
	visible = true

func _input(event):
	if GameState.inventory_open \
			or $ActionCooldown.time_left > 0 \
			or tween.is_active():
		return
	
	# Attempt an action or movement
	for dir in Constants.INPUTS.keys():
		if event.is_action(dir):
			move(dir)

func can_act():
	return .can_act() and GameState.player_turn

func move(dir):
	ray.cast_to = Constants.INPUTS[dir] * Constants.TILE_SIZE
	ray.force_raycast_update()
	var new_pos = position + Constants.INPUTS[dir] * Constants.TILE_SIZE
	
	var tpos = GameState.level.world_to_map(new_pos)
	var blocked = false
	var attacking = false
	var interacted = false
	
	# Check for walls/blocking tiles
	if not blocked and GameState.level.is_blocking(tpos):
		blocked = true
	
	# Check for doors
	if not blocked and GameState.level.is_door(tpos):
		if GameState.level.is_locked_door(tpos):
			blocked = true
			interacted = can_unlock(tpos)
		else:
			GameState.level.open_door(tpos)
	
	# Try to move
	$ActionCooldown.start()
	if not interacted:
		# Pick up items
		if ray.is_colliding():
			# Check for Items
			if ray.get_collider() is WorldItem:
				var item = ray.get_collider() as WorldItem
				item.collect()
				
			# Check for Enemies
			elif ray.get_collider() is Actor:
				var actor = ray.get_collider() as Actor
				if actor.mob and actor.mob.type == Mob.Type.ENEMY:
					attack(actor)
					attacking = true
					blocked = true
		
		# Otherwise, move
		move_tween(dir, blocked, attacking)
		
	yield(tween, "tween_all_completed")
	sprite.animation = ANIM.idle
	
	yield($ActionCooldown, "timeout")
	Events.emit_signal("player_acted")

func attack(actor: Actor):
	var damage = 1 if not GameState.player.equipped.weapon else GameState.player.equipped.weapon.calc_damage()
	var crit = false
	if Helpers.chance_luck(crit_chance):
		crit = true
		damage = ceil(damage * 1.5)
	
	actor.take_damage(damage, crit)
	Sounds.play_hit()

func take_damage(damage: int, crit = false, heal = false):
	.take_damage(damage, crit, heal)
	Events.emit_signal("player_hit")

func die():
	pass

func can_unlock(tpos: Vector2):
	if inventory.keys > 0:
		inventory.keys -= 1
		GameState.level.unlock_door(tpos, true)
		Events.emit_signal("player_interact", Item.Category.KEY)
		Events.emit_signal("log_message", "Door unlocked!")
		return true
	else:
		Events.emit_signal("log_message", "You do not have any keys...")
		return false

func move_tween(dir, blocked = false, attacking = false):
	if not blocked:
		Sounds.play_step()
		var new_pos = position + Constants.INPUTS[dir] * Constants.TILE_SIZE
		var tile_pos = GameState.level.world_to_map(new_pos)
		# print("Moving: ", GameState.level.world_to_map(new_pos), ", Tile: ", GameState.level.get_tile(tile_pos))
		tween.interpolate_property(self, "position",
			position, new_pos,
			1.0 / move_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	else:
		var origin_pos = position
		var bump_pos = position + Constants.INPUTS[dir] * Constants.TILE_SIZE / 4
		Events.emit_signal("camera_shake", 0.15, 0.6)
		
		if not attacking:
			Sounds.play_collision()
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

func tpos():
	return GameState.level.world_to_map(position)

func _on_player_equip(item: Item):
	if item is Weapon:
		Events.emit_signal("log_message", "You equipped the %s" % item.name)
		GameState.player.equipped.weapon = item
		Events.emit_signal("refresh_backpack")

func _on_player_unequip_weapon():
	Events.emit_signal("log_message", "You put away the %s" % GameState.player.equipped.weapon.name)
	GameState.player.equipped.weapon = null
	Events.emit_signal("refresh_backpack")

func _on_player_unequip_armor():
	GameState.player.equipped.armor = null
	Events.emit_signal("refresh_backpack")
	Events.emit_signal("log_message", "You're naked now, ya dummy!")

func _on_player_wait():
	if can_act() \
			and not GameState.inventory_open \
			and $ActionCooldown.time_left <= 0 \
			and not tween.is_active():
		Events.emit_signal("player_acted")

func _on_player_search():
	pass
