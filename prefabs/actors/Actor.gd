@tool
extends Area2D
class_name Actor

const DamagePopup = preload("res://ui/actions/DamagePopup.tscn")
const TextPopup = preload("res://ui/actions/TextPopup.tscn")

const MOVE_TIME = 0.1
const ATTACK_TIME = 0.2
const PASS_TIME = 0.3

@export var mob: Resource = null
@export var turn_speed: int = 20
@export var max_hp: int = 20
@export var hp: int = 20

@onready var hp_bar = $HpBar

var act_time = 0
var action_queue = []
var curr_tpos: Vector2
var unstable_teleport = 0
var should_teleport = false
var should_wake = false
var asleep = false

func _ready():
	curr_tpos = GameState.level.local_to_map(position)
	if mob:
		asleep = false if GameState.enemies_start_awake else true
		mob.max_hp = Helpers.dice_roll(mob.hd, 8)
		hp = mob.max_hp
		if has_node("Sprite2D"):
			$Sprite2D.texture = mob.texture
	
	if hp_bar:
		_init_hp_bar()

func _init_hp_bar():
	if mob:
		hp_bar.max_value = mob.max_hp
		hp_bar.value = mob.max_hp
	hp_bar.visible = false

func tpos():
	return curr_tpos

func act():
	# Mob AI
	if mob and action_queue.is_empty():
		var path = GameState.level.get_travel_path(tpos(), GameState.hero.tpos())
		if path.size() > 1:
			action_queue.append(ActionBuilder.new().move(path[0]))
		elif path.size() == 1:
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
			var t_location = GameState.level.get_random_empty_tile()
			action_queue.append(ActionBuilder.new().teleport(t_location))
	
	var action
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

func move(tpos: Vector2):
	var new_pos = GameState.level.map_to_local(tpos)
	GameState.level.free_tile(curr_tpos)
	curr_tpos = tpos
	GameState.level.occupy_tile(tpos)
	#tween.interpolate_property(self, "position",
		#position, new_pos,
		#MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#tween.start()

func talk(message: String):
	var message_text = TextPopup.instantiate()
	message_text.text = message
	message_text.global_position = position
	if mob:
		message_text.global_position += Vector2(8, 0)
	else:
		message_text.global_position += Vector2(0, -8)
	GameState.world.get_node("Effects").add_child(message_text)

func attack(actor: Actor):
	await get_tree().create_timer(0.1).timeout
	Sounds.play_enemy_hit()
	actor.take_damage(mob.strength)

func take_damage(damage: int, crit = false, heal = false):
	# 5% + (5% * lvl) + (5% * monster AC) + (5% * DEX)
	var chance_to_hit = 5 + (5 * GameState.player.stats.level) + (5 * GameState.player.stats.dex)
	
	if (GameState.player_guaranteed_hit and mob) or Helpers.chance_luck(chance_to_hit):
		var damage_text = DamagePopup.instantiate()
		damage_text.amount = damage
		damage_text.is_crit = crit
		damage_text.is_heal = heal
		damage_text.global_position = position
		if mob:
			damage_text.global_position += Vector2(8, 0)
		else:
			damage_text.global_position += Vector2(0, -8)
		GameState.world.get_node("Effects").add_child(damage_text)
		
		hp -= damage
		hp = clamp(hp, 0, max_hp)
		
		if hp_bar:
			hp_bar.visible = true
			hp_bar.value = hp
		
		if hp <= 0:
			die()
		return true
	else:
		talk("Dodged")
		return false
	

func heal(amount: int):
	take_damage(-amount, false, true)

func teleport(tpos: Vector2):
	var new_pos = GameState.level.map_to_local(tpos)
	curr_tpos = tpos
	#tween.interpolate_property(self, "position",
		#position, new_pos,
		#MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#tween.start()

func die():
	GameState.level.free_tile(tpos())
	if mob and mob.type == Mob.Type.ENEMY:
		Events.emit_signal("enemy_died", mob.xp_value)
	queue_free()
	
