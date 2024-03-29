extends Actor
class_name Player

const ANIM = {
	"idle": "idle",
	"walk": "walk"
}

@export var crit_chance = 30
@export var base_damage = "1d3"

@onready var sprite = $AnimSprite
@onready var stats = GameState.player.stats
@onready var inventory = GameState.player.inventory
@onready var backpack = GameState.player.backpack

var interrupted_actions = []

func _ready():
	super()
	sprite.animation = ANIM.idle
	sprite.play()
	
	Events.player_wait.connect(_on_player_wait)
	Events.player_search.connect(_on_player_search)
	Events.player_continue.connect(_on_player_continue)
	Events.player_equip.connect(_on_player_equip)
	Events.player_use_item.connect(_on_player_use_item)
	Events.player_unequip_weapon.connect(_on_player_unequip_weapon)
	Events.player_unequip_armor.connect(_on_player_unequip_armor)
	Events.enemy_died.connect(_on_enemy_died)

func _unhandled_input(event):
	if not _can_act(): return
	
	# Attempt an action or movement
	if event.is_action_pressed("select"):
		# Get click location
		var m_tpos = GameState.level.local_to_map(get_global_mouse_position())
		
		if m_tpos == tpos():
			# Check if we clicked ourselves - wait
			action_queue.append(ActionBuilder.new().wait())
		elif GameState.world.get_actor_at_tpos(m_tpos):
			# Check if we clicked an enemy - attack
			var dist = (m_tpos - tpos()).length()
			if dist < 2 or GameState.dev_player_any_dist_hit:
				queue_attack(m_tpos)
			else:
				Events.log_message.emit("You can't reach that far!")
		else:
			# Check if we clicked an empty location - move towards it
			var travel = GameState.level.get_travel_path(tpos(), m_tpos)
			if travel.size() > 1 and not GameState.world.get_actor_at_tpos(travel[1]):
				travel.pop_front()
				for point in travel:
					var action = ActionBuilder.new().move(point)
					action_queue.append(action)
			else:
				Events.log_message.emit("Something blocks your path...")
	else:
		# Handle controller inputs
		for dir in Constants.INPUTS.keys():
			if event.is_action(dir):
				var target = tpos() + Constants.INPUTS[dir]
				if GameState.world.get_actor_at_tpos(target):
					print("attack")
					queue_attack(target)
				else:
					if GameState.level.can_move_to(target):
						var action = ActionBuilder.new().move(target)
						action_queue.append(action)
					else:
						var action = ActionBuilder.new().move(target, 0)
						action_queue.append(action)
	
	if not action_queue.is_empty():
		Events.player_acted.emit()

func _can_act() -> bool:
	return GameState.is_player_turn \
			and action_queue.is_empty() \
			and not GameState.inventory_open \
			and not tween.is_running()

func act():
	if action_queue.is_empty(): return
	var action = super()
	if action:
		GameState.is_player_turn = false
	return action

func queue_attack(tpos: Vector2i):
	var actor = GameState.world.get_actor_at_tpos(tpos)
	if not actor: return
	var attack = ActionBuilder.new().attack(tpos, actor)
	action_queue.append(attack)

func interrupt():
	sprite.animation = ANIM.idle
	interrupted_actions.append_array(action_queue)
	action_queue.clear()
	Events.player_interrupted.emit()

# TODO: What the heck was I doing with this? This all needs a rework
# There are serious complexity issues going on here that feel like
# they're sidestepping the action queue.
func move(tpos: Vector2i):
	var blocked = false
	var interacted = false
	
	# Check for walls/blocking tiles
	if GameState.level.is_blocking(tpos):
		blocked = true
	
	# Check for doors
	# TODO: Rework this into a* pathfinding?
	if not blocked and GameState.level.is_door(tpos):
		if GameState.level.is_locked_door(tpos):
			blocked = true
			interacted = can_unlock(tpos)
		else:
			GameState.level.open_door(tpos)
	
	# TODO: Make an interact button (similar to picking up items)
	if GameState.level.is_stair_down(tpos) and not GameState.world_generating:
		GameState.world_generating = true
		GameState.depth += 1
		Events.next_stage.emit()
	
	if not GameState.level.can_move_to(tpos):
		var actor = GameState.world.get_actor_at_tpos(tpos)
		if actor:
			attack(actor)
			return
	
	# Try to move
	move_tween(tpos, blocked)
	
	await tween.finished
	
	if action_queue.size() == 0:
		sprite.animation = ANIM.idle

func move_tween(tpos: Vector2i, blocked = false):
	tween = create_tween()
	
	if tpos.x > curr_tpos.x:
		sprite.flip_h = false
	if tpos.x < curr_tpos.x:
		sprite.flip_h = true
	
	if not blocked:
		var new_pos = GameState.level.map_to_local(tpos)
		
		curr_tpos = tpos
		Sounds.play_step()
		
		tween.tween_property(self, "position", new_pos, MOVE_TIME) \
			.set_trans(Tween.TRANS_LINEAR)
	else:
		var origin_pos = position
		var hit_position = position + Vector2(tpos - tpos()) * Constants.TILE_HALF
		
		Events.camera_shake.emit(0.15, 0.6)
		Sounds.play_collision()
		
		tween.tween_property(self, "position", hit_position, MOVE_TIME / 2) \
			.set_trans(Tween.TRANS_CUBIC) \
			.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "position", origin_pos, MOVE_TIME / 2) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN).set_delay(MOVE_TIME / 2)
	sprite.animation = ANIM.walk

func attack(actor: Actor):
	# Determine hit damage
	var damage = 0
	if GameState.player.equipped.weapon:
		damage = GameState.player.equipped.weapon.calc_damage()
	else:
		damage = Utils.dice_roll_composed(base_damage) # Utils.dice_roll(max(stats.str, 3), 4)
	
	# Calc critical hit chance
	var crit = false
	if Utils.chance_luck(crit_chance):
		crit = true
		damage = ceil(damage * 1.25)
	
	actor.take_damage(damage, crit)
	Events.camera_shake.emit(0.2, 0.6)
	var origin_pos = position
	var attack_pos = actor.position
	var hit_position = position + Vector2(actor.tpos() - tpos()) * Constants.TILE_HALF
	Sounds.play_hit()
	
	if actor.mob.is_unique:
		Events.log_message.emit("You attack %s for %d damage" % [actor.mob.name, damage])
	else:
		Events.log_message.emit("You attack the %s for %d damage" % [actor.mob.name, damage])
	
	tween = create_tween()
	tween.tween_property(self, "position", hit_position, MOVE_TIME / 2) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", origin_pos, MOVE_TIME / 2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN).set_delay(MOVE_TIME / 2)

func take_damage(damage: int, crit = false, heal = false):
	var was_hit = super(damage, crit, heal)
	if was_hit or true:
		interrupt()
		Events.player_hit.emit()

func teleport(tpos: Vector2i):
	super(tpos)
	Events.log_message.emit("You've been teleported!")

func can_unlock(tpos: Vector2):
	if inventory.keys > 0:
		inventory.keys -= 1
		GameState.level.unlock_door(tpos, true)
		Events.player_interact.emit(Item.Category.KEY)
		Events.log_message.emit("Door unlocked!")
		return true
	else:
		Events.log_message.emit("You do not have any keys...")
		return false

func die():
	pass

func _on_player_equip(item: Item):
	match item:
		Weapon:
			GameState.player.equipped.weapon = item
			action_queue.append(ActionBuilder.new().equip(3))
			Events.log_message.emit("You equipped the %s" % item.name)
			Events.refresh_backpack.emit()
		Armor:
			GameState.player.equipped.armor = item
			action_queue.append(ActionBuilder.new().equip(3))
			Events.log_message.emit("You equipped the %s" % item.name)
			Events.refresh_backpack.emit()
	Events.player_acted.emit()
	# TODO: Equip rings

func _on_player_unequip_weapon():
	action_queue.append(ActionBuilder.new().unequip(3))
	Events.log_message.emit("You put away the %s" % GameState.player.equipped.weapon.name)
	GameState.player.equipped.weapon = null
	Events.refresh_backpack.emit()
	Events.player_acted.emit()

func _on_player_unequip_armor():
	action_queue.append(ActionBuilder.new().unequip(3))
	Events.log_message.emit("You're naked now, ya dummy!")
	GameState.player.equipped.armor = null
	Events.refresh_backpack.emit()
	Events.player_acted.emit()

func _on_player_use_item():
	action_queue.append(ActionBuilder.new().use_item())
	Events.player_acted.emit()

func _on_player_wait():
	if _can_act():
		action_queue.append(ActionBuilder.new().wait())
		talk("...")
		Events.player_acted.emit()

func _on_player_search():
	if _can_act():
		action_queue.append(ActionBuilder.new().search(2))
		talk("search")
		Events.player_acted.emit()

func _on_player_continue():
	if _can_act() and not interrupted_actions.is_empty():
		var final_dest = interrupted_actions.back().dest
		var adjusted_travel_path = GameState.level.get_travel_path(tpos(), final_dest)
		for point in adjusted_travel_path:
			var action = ActionBuilder.new().move(point)
			action_queue.append(action)
		interrupted_actions.clear()
		Events.player_acted.emit()

func _on_enemy_died(xp: int):
	stats.xp += xp
	if stats.xp >= stats.xp_next:
		stats.xp = stats.xp % stats.xp_next
		stats.xp_next = int(stats.xp_next * 1.8)
		stats.level += 1
		max_hp += 2 * stats.level
		hp = max(hp + 4, max_hp)
	Events.player_gain_xp.emit()

func _on_Player_area_entered(area):
	if area is WorldItem and area.has_method("collect"):
		area.collect()
