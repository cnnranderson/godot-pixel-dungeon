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

var act_time = 0
var action_queue = []
var action_timer = Timer.new()
var last_pos: Vector2
var unstable_teleport = 0
var should_teleport = false
var should_wake = false
var asleep = false

func _ready():
	_setup_action_timer()
	last_pos = GameState.level.world_to_map(position)
	if mob:
		asleep = true
		hp = mob.max_hp
		if has_node("Sprite"):
			$Sprite.texture = mob.texture

func _setup_action_timer():
	action_timer.wait_time = MOVE_TIME
	action_timer.one_shot = true
	add_child(action_timer)
	action_timer.connect("timeout", self, "_on_action_timer_timeout")

func tpos():
	return GameState.level.world_to_map(position)

func act():
	# Teleportation rules
	if should_teleport:
		unstable_teleport -= 1
		if unstable_teleport <= 0:
			should_teleport = false
			action_queue.clear()
			var t_location = GameState.level.get_random_empty_tile()
			action_queue.append(ActionBuilder.new().teleport(t_location))
	
	# Sleeping mechanic
	if asleep:
		if should_wake:
			asleep = false
			should_wake = false
		else:
			action_queue.append(ActionBuilder.new().wait())
	
	var action
	if action_queue.size() > 0:
		action = action_queue.pop_front()
	else:
		# Mob AI
		if mob:
			var path = GameState.level.get_travel_path(tpos(), GameState.hero.tpos())
			if path.size() > 0:
				action = ActionBuilder.new().move(path[0])
			else:
				action = ActionBuilder.new().wait()
	
	if action:
		act_time += action.cost
		match action.type:
			Action.ActionType.MOVE:
				move(action.dest)
			Action.ActionType.ATTACK:
				attack(action.target)
			Action.ActionType.TELEPORT:
				teleport(action.dest)
			_:
				Events.emit_signal("turn_ended", self)

func _on_action_timer_timeout():
	Events.emit_signal("turn_ended", self)

func move(tpos: Vector2):
	var possible_attack = false
	if GameState.hero.tpos() == tpos:
		possible_attack = true
	
	# Attempt an attack if the player is near or move
	if possible_attack:
		attack(GameState.hero)
	else:
		var new_pos = GameState.level.map_to_world(tpos)
		GameState.level.free_tile(last_pos)
		last_pos = tpos
		GameState.level.occupy_tile(tpos)
		$Tween.interpolate_property(self, "position",
			position, new_pos,
			MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		Events.emit_signal("turn_ended", self)

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
	Sounds.play_enemy_hit()
	actor.take_damage(mob.strength)
	action_timer.start(ATTACK_TIME)

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
	if not mob:
		new_pos += Vector2(8, 8)
	$Tween.interpolate_property(self, "position",
		position, new_pos,
		MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	action_timer.start(PASS_TIME)

func die():
	GameState.level.free_tile(tpos())
	queue_free()
