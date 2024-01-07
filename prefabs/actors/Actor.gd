@tool
extends Area2D
class_name Actor

const DamagePopup = preload("res://ui/actions/DamagePopup.tscn")
const TextPopup = preload("res://ui/actions/TextPopup.tscn")

const MOVE_TIME = 0.1
const ATTACK_TIME = 0.2

@export var mob: Mob = null
@export var npc: Resource = null
@export var turn_speed: int = 20
@export var max_hp: int = 20
@export var hp: int = 20

@onready var hp_bar = $HpBar

var act_time = 0
var action_queue: Array[Action] = []
var curr_tpos: Vector2i
var unstable_teleport = 0
var should_teleport = false
var should_wake = false
var asleep = false
var tween: Tween

func _ready():
	# FIXME: Stupid way to do this but oh well - need to bind to self, then immediately stop
	# otherwise it thinks it's running.. This breaks _can_act() function
	tween = create_tween()
	tween.stop()
	
	curr_tpos = GameState.level.local_to_map(position)
	if mob:
		asleep = false if GameState.enemies_start_awake else true
		max_hp = mob.max_hp
		hp = mob.hp
		
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		
		if has_node("Sprite2D"):
			$Sprite2D.texture = mob.texture

func _init_hp_bar():
	if mob:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
	hp_bar.visible = false

func tpos() -> Vector2i:
	return curr_tpos

func act():
	# Mob AI
	if mob and action_queue.is_empty():
		var path = GameState.level.get_travel_path(tpos(), GameState.hero.tpos())
		
		if path.size() > 2 and not GameState.world.get_actor_at_tpos(path[1]):
			action_queue.append(ActionBuilder.new().move(path[1]))
		elif path.size() == 2:
			var dist_to_player = (tpos() - GameState.hero.tpos()).length()
			var nearby_actor_dir = get_close_actor()
			var new_pos = tpos() - nearby_actor_dir
			# This condition is for corner-piling - this adds difficulty to hallway management
			# TODO: Make this a chance decision
			if nearby_actor_dir != Vector2i.ZERO and dist_to_player > 1 and dist_to_player < 2 \
					and GameState.level.can_move_to(new_pos) \
					and (new_pos - GameState.hero.tpos()).length() < dist_to_player \
					and not GameState.world.get_actor_at_tpos(new_pos):
				action_queue.append(ActionBuilder.new().move(new_pos))
			else:
				action_queue.append(ActionBuilder.new().attack(GameState.hero.tpos(), GameState.hero))
		else:
			action_queue.append(ActionBuilder.new().wait())
	
	# Sleeping mechanic
	if asleep:
		if should_wake:
			asleep = false
			should_wake = false
		else:
			action_queue.clear()
			action_queue.append(ActionBuilder.new().wait())
	
	# Teleportation rules - can override sleep
	if should_teleport:
		unstable_teleport -= 1
		if unstable_teleport <= 0:
			should_teleport = false
			action_queue.clear()
			
			# Setup teleport location
			# TODO: Fix teleport location - could land on spot with enemy
			var t_location = GameState.level.get_random_empty_tile()
			action_queue.append(ActionBuilder.new().teleport(t_location))
	
	var action: Action
	if action_queue.size() > 0:
		action = action_queue.pop_front()
	
	if action:
		act_time += action.cost
		match action.type:
			Action.ActionType.MOVE:
				move(action.dest)
			Action.ActionType.ATTACK:
				attack(action.target)
			Action.ActionType.TELEPORT:
				teleport(action.dest)
	return action

func move(tpos: Vector2i):
	var new_pos = GameState.level.map_to_local(tpos)
	GameState.level.free_tile(curr_tpos)
	curr_tpos = tpos
	GameState.level.occupy_tile(tpos)
	
	tween = create_tween()
	tween.tween_property(self, "position", new_pos, MOVE_TIME) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN_OUT)

func talk(message: String):
	var message_text = TextPopup.instantiate()
	message_text.text = message
	message_text.global_position = position + Vector2(0, -8)
	GameState.world.get_node("Effects").add_child(message_text)

func attack(actor: Actor):
	Sounds.play_enemy_hit()
	actor.take_damage(mob.strength)

# TODO: might need to rename this to "attempt damage" or something
func take_damage(damage: int, crit = false, heal = false):
	# 5% + (5% * lvl) + (5% * monster AC) + (5% * DEX)
	var chance_to_hit = 5 + (5 * GameState.player.stats.level) + (5 * GameState.player.stats.dex)
	
	if (GameState.dev_player_guaranteed_hit and mob) or Helpers.chance_luck(chance_to_hit):
		var damage_text = DamagePopup.instantiate()
		damage_text.amount = damage
		damage_text.is_crit = crit
		damage_text.is_heal = heal
		damage_text.global_position = position
		GameState.world.get_node("Effects").add_child(damage_text)
		
		hp -= damage
		hp = clamp(hp, 0, max_hp)
		
		if hp_bar:
			hp_bar.visible = true
			hp_bar.value = hp
		
		if mob:
			if mob.is_unique:
				Events.log_message.emit("%s hits you for %d damage" % [mob.name, mob.strength])
			else:
				Events.log_message.emit("The %s hits you for %d damage" % [mob.name, mob.strength])
		
		if hp <= 0:
			die()
		return true
	else:
		talk("Dodged")
		
		if mob:
			if mob.is_unique:
				Events.log_message.emit("%s attacks but misses you!" % [mob.name, mob.strength])
			else:
				Events.log_message.emit("The %s attacks but misses you!" % [mob.name, mob.strength])
		return false

func heal(amount: int):
	take_damage(-amount, false, true)

func teleport(tpos: Vector2i):
	var new_pos = GameState.level.map_to_local(tpos)
	curr_tpos = tpos
	
	tween = create_tween()
	tween.tween_property(self, "position", new_pos, MOVE_TIME) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN_OUT)

func die():
	GameState.level.free_tile(tpos())
	if mob and mob.type == Mob.Type.ENEMY:
		Events.enemy_died.emit(mob.xp_value)
	queue_free()
	
func get_close_actor() -> Vector2i:
	if GameState.world.get_actor_at_tpos(tpos() + Vector2i.DOWN):
		return Vector2i.DOWN
	if GameState.world.get_actor_at_tpos(tpos() + Vector2i.LEFT):
		return Vector2i.LEFT
	if GameState.world.get_actor_at_tpos(tpos() + Vector2i.RIGHT):
		return Vector2i.RIGHT
	if GameState.world.get_actor_at_tpos(tpos() + Vector2i.UP):
		return Vector2i.UP
	return Vector2i.ZERO
