extends Actor
class_name Player

const ANIM = {
	"idle": "idle",
	"walk": "walk"
}

export var move_speed = 8
export var fast_travel_speed = 140
export var crit_chance = 30

onready var tween = $Tween
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
	Events.connect("player_equip", self, "_on_player_equip")
	Events.connect("player_unequip_weapon", self, "_on_player_unequip_weapon")
	Events.connect("player_unequip_armor", self, "_on_player_unequip_armor")
	Events.connect("next_stage", self, "_on_next_stage")

func _unhandled_input(event):
	print(event)
	if not GameState.is_player_turn \
			or GameState.inventory_open \
			or action_timer.time_left > 0 \
			or tween.is_active() \
			or action_queue.size() > 0:
		return
	
	# Attempt an action or movement
	for dir in Constants.INPUTS.keys():
		if event.is_action(dir):
			var target = tpos() + Constants.INPUTS[dir]
			if target in GameState.level.blocked:
				queue_attack(target)
			else:
				var action = ActionBuilder.new().move(target)
				action_queue.append(action)
				action_timer.start(MOVE_TIME)
	
	if event.is_action_pressed("select") and GameState.is_player_turn and action_queue.size() == 0:
		var p_tpos = tpos()
		var m_tpos = GameState.level.world_to_map(get_global_mouse_position())
		var travel = GameState.level.get_travel_path(p_tpos, m_tpos)
		interrupted_actions.clear()
		if travel.size() == 0:
			if m_tpos in GameState.level.blocked:
				queue_attack(m_tpos)
		else:
			for point in travel:
				var action = ActionBuilder.new().move(point)
				action_queue.append(action)
			action_timer.start(MOVE_TIME)

func queue_attack(tpos: Vector2):
	var actor = GameState.world.get_actor_at_tpos(tpos)
	var attack = ActionBuilder.new().attack(tpos, actor)
	action_queue.append(attack)
	action_timer.start(ATTACK_TIME)

func interrupt():
	interrupted_actions.append_array(action_queue)
	action_queue.clear()

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
	
	if GameState.level.is_stair_down(tpos):
		Events.emit_signal("next_stage")
	
	if not GameState.level.can_move_to(tpos):
		var actor = GameState.world.get_actor_at_tpos(tpos)
		if actor:
			attack(actor)
			return
	
	# Try to move
	move_tween(tpos, blocked)
	action_timer.start()
	
	yield(tween, "tween_all_completed")
	if action_queue.size() == 0:
		sprite.animation = ANIM.idle

func attack(actor: Actor):
	var damage = 1 if not GameState.player.equipped.weapon else GameState.player.equipped.weapon.calc_damage()
	var crit = false
	if Helpers.chance_luck(crit_chance):
		crit = true
		damage = ceil(damage * 1.5)
	
	actor.take_damage(damage, crit)
	Events.emit_signal("camera_shake", 0.2, 0.6)
	Sounds.play_hit()
	action_timer.start(ATTACK_TIME)

func take_damage(damage: int, crit = false, heal = false):
	.take_damage(damage, crit, heal)
	interrupt()
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

func move_tween(tpos: Vector2, blocked = false):
	if not blocked:
		var new_pos = GameState.level.map_to_world(tpos) + Vector2(8, 8)
		Sounds.play_step()
		tween.interpolate_property(self, "position",
			position, new_pos,
			action_timer.wait_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		act_time -= 1
		var origin_pos = position
		var hit_position = position + (GameState.level.map_to_world(tpos - tpos()) / 2)
		Events.emit_signal("camera_shake", 0.15, 0.6)
		Sounds.play_collision()
		tween.interpolate_property(self, "position",
			position, hit_position,
			action_timer.wait_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(self, "position",
			hit_position, origin_pos,
			action_timer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN, action_timer.wait_time)
		
	sprite.animation = ANIM.walk
	if tpos.x > tpos().x:
		sprite.flip_h = false
	if tpos.x < tpos().x:
		sprite.flip_h = true
	tween.start()

func _on_player_equip(item: Item):
	if item is Weapon:
		Events.emit_signal("log_message", "You equipped the %s" % item.name)
		GameState.player.equipped.weapon = item
		Events.emit_signal("refresh_backpack")
	# TODO: item is Armor

func _on_player_unequip_weapon():
	Events.emit_signal("log_message", "You put away the %s" % GameState.player.equipped.weapon.name)
	GameState.player.equipped.weapon = null
	Events.emit_signal("refresh_backpack")

func _on_player_unequip_armor():
	GameState.player.equipped.armor = null
	Events.emit_signal("refresh_backpack")
	Events.emit_signal("log_message", "You're naked now, ya dummy!")

func _on_player_wait():
	if GameState.is_player_turn \
			and not GameState.inventory_open \
			and action_timer.time_left <= 0 \
			and not tween.is_active():
		action_queue.append(ActionBuilder.new().wait())
		talk("...")
		action_timer.start(PASS_TIME)

func _on_player_search():
	if GameState.is_player_turn \
			and not GameState.inventory_open \
			and action_timer.time_left <= 0:
		action_queue.append(ActionBuilder.new().search(2))
		talk("search")
		action_timer.start(PASS_TIME)

func _on_Player_area_entered(area):
	if area is WorldItem and area.has_method("collect"):
		area.collect()

func _on_ActionCooldown_timeout():
	Events.emit_signal("player_acted")
