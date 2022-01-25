tool
extends Area2D
class_name Actor

const DamagePopup = preload("res://ui/actions/DamagePopup.tscn")
const TextPopup = preload("res://ui/actions/TextPopup.tscn")

const MOVE_TIME = 0.1
const ATTACK_TIME = 0.2
const PASS_TIME = 0.3

export(Resource) var mob = null
export(int) var turn_speed = 20
export(int) var max_hp = 20
export(int) var hp = max_hp

onready var tween = $Tween

var act_time = 0
var action_queue = []
var curr_tpos: Vector2
var unstable_teleport = 0
var should_teleport = false
var should_wake = false
var asleep = false

func _ready():
	curr_tpos = GameState.level.world_to_map(position)
	if mob:
		asleep = true
		hp = mob.max_hp
		if has_node("Sprite"):
			$Sprite.texture = mob.texture

func tpos():
	return curr_tpos

func act():
	# Teleportation rules
	if should_teleport:
		unstable_teleport -= 1
		print(unstable_teleport)
		if unstable_teleport <= 0:
			should_teleport = false
			action_queue.clear()
			var t_location = GameState.level.get_random_empty_tile()
			action_queue.append(ActionBuilder.new().teleport(t_location))
	
	# Sleeping mechanic
	if false and asleep:
		if should_wake:
			asleep = false
			should_wake = false
		else:
			action_queue.append(ActionBuilder.new().wait())
	
	# Mob AI
	if mob and action_queue.empty():
		var path = GameState.level.get_travel_path(tpos(), GameState.hero.tpos())
		if path.size() > 1:
			action_queue.append(ActionBuilder.new().move(path[0]))
		elif path.size() == 1:
			action_queue.append(ActionBuilder.new().attack(GameState.hero.tpos(), GameState.hero))
		else:
			action_queue.append(ActionBuilder.new().wait())
			
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
	var new_pos = GameState.level.map_to_world(tpos)
	GameState.level.free_tile(curr_tpos)
	curr_tpos = tpos
	GameState.level.occupy_tile(tpos)
	tween.interpolate_property(self, "position",
		position, new_pos,
		MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func talk(message: String):
	var message_text = TextPopup.instance()
	message_text.text = message
	message_text.rect_global_position = position
	if mob:
		message_text.rect_global_position += Vector2(8, 0)
	else:
		message_text.rect_global_position += Vector2(0, -8)
	GameState.world.get_node("Effects").add_child(message_text)

func attack(actor: Actor):
	yield(get_tree().create_timer(0.1), "timeout")
	Sounds.play_enemy_hit()
	actor.take_damage(mob.strength)

func take_damage(damage: int, crit = false, heal = false):
	var damage_text = DamagePopup.instance()
	damage_text.amount = damage
	damage_text.is_crit = crit
	damage_text.is_heal = heal
	damage_text.rect_global_position = position
	if mob:
		damage_text.rect_global_position += Vector2(8, 0)
	else:
		damage_text.rect_global_position += Vector2(0, -8)
	GameState.world.get_node("Effects").add_child(damage_text)
	
	hp -= damage
	hp = clamp(hp, 0, max_hp)
	if hp <= 0:
		die()

func heal(amount: int):
	take_damage(-amount, false, true)

func teleport(tpos: Vector2):
	var new_pos = GameState.level.map_to_world(tpos)
	curr_tpos = tpos
	if not mob:
		new_pos += Vector2(8, 8)
	tween.interpolate_property(self, "position",
		position, new_pos,
		MOVE_TIME * 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func die():
	GameState.level.free_tile(tpos())
	queue_free()
