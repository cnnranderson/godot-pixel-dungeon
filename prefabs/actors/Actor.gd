tool
extends Area2D
class_name Actor

const DamagePopup = preload("res://ui/actions/DamagePopup.tscn")
const TextPopup = preload("res://ui/actions/TextPopup.tscn")

const MOVE_TIME = 0.1

export(Resource) var mob = null
export(int) var turn_speed = 20
export(int) var max_hp = 20
export(int) var hp = max_hp

var act_time = 0
var is_awake = false
var should_wake = false
var action_queue = []
var action_timer = Timer.new()

func _ready():
	_setup_action_timer()
	if mob:
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
	var action
	if action_queue.size() > 0:
		action = action_queue.pop_front()
	else:
		if mob:
			act_time += 1
			var path = GameState.level.get_travel_path(tpos(), GameState.hero.tpos())
			if path.size() > 0:
				action = {
					"type": "move",
					"target": path[0],
					"cost": 1
				}
			else:
				action = {
					"type": "wait",
					"cost": 1
				}
	
	if action:
		match action.type:
			"move":
				move(action.target)
			"wait":
				pass
		act_time += action.cost
		if not mob:
			action_timer.start(.1)

func _on_action_timer_timeout():
	Events.emit_signal("turn_ended", self)

func move(tpos: Vector2):
	var possible_attack = false
	if GameState.hero.tpos() == tpos:
		possible_attack = true
	
	# Attempt an attack if the player is near or move
	if possible_attack:
		attack(GameState.hero)
		action_timer.start(.4)
	else:
		GameState.level.free_tile(tpos())
		var new_pos = GameState.level.map_to_world(tpos)
		$Tween.interpolate_property(self, "position",
			position, new_pos,
			0.08, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
		GameState.level.occupy_tile(tpos)
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

func die():
	queue_free()
