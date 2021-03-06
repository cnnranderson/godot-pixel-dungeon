extends Actor
class_name Player

const ANIM = {
	"idle": "idle",
	"walk": "walk"
}

export var move_speed = 8
export var fast_travel_speed = 140
export var crit_chance = 30
export var base_damage = "1d3"

onready var sprite = $AnimSprite
onready var stats = GameState.player.stats
onready var inventory = GameState.player.inventory
onready var backpack = GameState.player.backpack

var interrupted_actions = []

func _ready():
	sprite.animation = ANIM.idle
	sprite.playing = true
	Events.connect("player_wait", self, "_on_player_wait")
	Events.connect("player_search", self, "_on_player_search")
	Events.connect("player_continue", self, "_on_player_continue")
	Events.connect("player_equip", self, "_on_player_equip")
	Events.connect("player_use_item", self, "_on_player_use_item")
	Events.connect("player_unequip_weapon", self, "_on_player_unequip_weapon")
	Events.connect("player_unequip_armor", self, "_on_player_unequip_armor")
	Events.connect("enemy_died", self, "_on_enemy_died")
	Events.connect("next_stage", self, "_on_next_stage")

func _unhandled_input(event):
	if not _can_act(): return
	
	# Attempt an action or movement
	if event.is_action_pressed("select"):
		# Handle mouse input
		var p_tpos = tpos()
		var m_tpos = GameState.level.world_to_map(get_global_mouse_position())
		var travel = GameState.level.get_travel_path(p_tpos, m_tpos)
		interrupted_actions.clear()
		if travel.size() == 0:
			if m_tpos in GameState.level.blocked:
				var dist = (m_tpos - tpos()).length()
				if dist < 2 or GameState.player_any_dist_hit:
					queue_attack(m_tpos)
			else:
				Events.emit_signal("log_message", "Something blocks your path...")
		else:
			for point in travel:
				var action = ActionBuilder.new().move(point)
				action_queue.append(action)
	else:
		# Handle controller inputs
		for dir in Constants.INPUTS.keys():
			if event.is_action(dir):
				var target = tpos() + Constants.INPUTS[dir]
				if target in GameState.level.blocked:
					queue_attack(target)
				else:
					if GameState.level.can_move_to(target):
						var action = ActionBuilder.new().move(target)
						action_queue.append(action)
					else:
						var action = ActionBuilder.new().move(target, 0)
						action_queue.append(action)
	
	if not action_queue.empty():
		Events.emit_signal("player_acted")

func _can_act() -> bool:
	return GameState.is_player_turn \
			and not GameState.inventory_open \
			and not tween.is_active() \
			and action_queue.empty()

func act():
	if action_queue.empty(): return
	var action = .act()
	if action:
		GameState.is_player_turn = false
	return action

func queue_attack(tpos: Vector2):
	var actor = GameState.world.get_actor_at_tpos(tpos)
	var attack = ActionBuilder.new().attack(tpos, actor)
	action_queue.append(attack)

func interrupt():
	sprite.animation = ANIM.idle
	interrupted_actions.append_array(action_queue)
	action_queue.clear()
	Events.emit_signal("player_interrupted")

func move(tpos):
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
	if GameState.level.is_stair_down(tpos):
		Events.emit_signal("next_stage")
	
	if not GameState.level.can_move_to(tpos):
		var actor = GameState.world.get_actor_at_tpos(tpos)
		if actor:
			attack(actor)
			return
	
	# Try to move
	move_tween(tpos, blocked)
	
	yield(tween, "tween_all_completed")
	if action_queue.size() == 0:
		sprite.animation = ANIM.idle

func move_tween(tpos: Vector2, blocked = false):
	if tpos.x > curr_tpos.x:
		sprite.flip_h = false
	if tpos.x < curr_tpos.x:
		sprite.flip_h = true
	
	if not blocked:
		var new_pos = GameState.level.map_to_world(tpos) + Vector2(8, 8)
		curr_tpos = tpos
		Sounds.play_step()
		tween.interpolate_property(self, "position",
			position, new_pos,
			MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		var origin_pos = position
		var hit_position = position + (GameState.level.map_to_world(tpos - tpos()) / 2)
		Events.emit_signal("camera_shake", 0.15, 0.6)
		Sounds.play_collision()
		tween.interpolate_property(self, "position",
			position, hit_position,
			MOVE_TIME / 2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(self, "position",
			hit_position, origin_pos,
			MOVE_TIME / 2, Tween.TRANS_SINE, Tween.EASE_IN, MOVE_TIME / 2)
		
	sprite.animation = ANIM.walk
	tween.start()

func attack(actor: Actor):
	# Determine hit damage
	var damage = 0
	if GameState.player.equipped.weapon:
		damage = GameState.player.equipped.weapon.calc_damage()
	else:
		damage = Helpers.dice_roll(max(stats.str, 3), 4)
	
	# Calc critical hit chance
	var crit = false
	if Helpers.chance_luck(crit_chance):
		crit = true
		damage = ceil(damage * 1.5)
	
	actor.take_damage(damage, crit)
	Events.emit_signal("camera_shake", 0.2, 0.6)
	var origin_pos = position
	var attack_pos = actor.position + Vector2(8, 8)
	Sounds.play_hit()

func take_damage(damage: int, crit = false, heal = false):
	var was_hit = .take_damage(damage, crit, heal)
	if was_hit or true:
		interrupt()
		Events.emit_signal("player_hit")

func teleport(tpos: Vector2):
	.teleport(tpos)
	Events.emit_signal("log_message", "You've been teleported!")

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

func die():
	pass

func _on_player_equip(item: Item):
	if item is Weapon:
		GameState.player.equipped.weapon = item
		action_queue.append(ActionBuilder.new().equip(3))
		Events.emit_signal("log_message", "You equipped the %s" % item.name)
		Events.emit_signal("refresh_backpack")
	if item is Armor:
		GameState.player.equipped.armor = item
		action_queue.append(ActionBuilder.new().equip(3))
		Events.emit_signal("log_message", "You equipped the %s" % item.name)
		Events.emit_signal("refresh_backpack")
	Events.emit_signal("player_acted")
	# TODO: Equip rings

func _on_player_unequip_weapon():
	action_queue.append(ActionBuilder.new().unequip(3))
	Events.emit_signal("log_message", "You put away the %s" % GameState.player.equipped.weapon.name)
	GameState.player.equipped.weapon = null
	Events.emit_signal("refresh_backpack")
	Events.emit_signal("player_acted")

func _on_player_unequip_armor():
	action_queue.append(ActionBuilder.new().unequip(3))
	Events.emit_signal("log_message", "You're naked now, ya dummy!")
	GameState.player.equipped.armor = null
	Events.emit_signal("refresh_backpack")
	Events.emit_signal("player_acted")

func _on_player_use_item():
	action_queue.append(ActionBuilder.new().use_item())
	Events.emit_signal("player_acted")

func _on_player_wait():
	if _can_act():
		action_queue.append(ActionBuilder.new().wait())
		talk("...")
		Events.emit_signal("player_acted")

func _on_player_search():
	if _can_act():
		action_queue.append(ActionBuilder.new().search(2))
		talk("search")
		Events.emit_signal("player_acted")

func _on_player_continue():
	if _can_act() and not interrupted_actions.empty():
		var final_dest = interrupted_actions.back().dest
		var adjusted_travel_path = GameState.level.get_travel_path(tpos(), final_dest)
		for point in adjusted_travel_path:
			var action = ActionBuilder.new().move(point)
			action_queue.append(action)
		interrupted_actions.clear()
		Events.emit_signal("player_acted")

func _on_enemy_died(xp: int):
	stats.xp += xp
	if stats.xp >= stats.xp_next:
		stats.xp = stats.xp % stats.xp_next
		stats.xp_next = int(stats.xp_next * 1.8)
		stats.level += 1
		max_hp += 2 * stats.level
		hp = max(hp + 4, max_hp)
	Events.emit_signal("player_gain_xp")
	pass

func _on_Player_area_entered(area):
	if area is WorldItem and area.has_method("collect"):
		area.collect()
