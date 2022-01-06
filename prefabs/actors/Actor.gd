tool
extends Area2D
class_name Actor

const DamagePopup = preload("res://ui/actions/DamagePopup.tscn")

export(Resource) var mob = null
export(int) var turn_speed = 20
export(int) var max_hp = 20
export(int) var hp = max_hp

var turn_acc = 0
var is_awake = false

func _ready():
	if mob:
		hp = mob.max_hp
		if has_node("Sprite"):
			$Sprite.texture = mob.texture

func can_act():
	return turn_acc >= Constants.BASE_ACTION_COST

func act():
	turn_acc -= Constants.BASE_ACTION_COST
	
	if mob:
		move(null)
	pass

func move(dir):
	var possible_moves = []
	var possible_attack = false
	for dir in Constants.INPUTS.keys():
		var new_pos = position + Constants.INPUTS[dir] * Constants.TILE_SIZE
		var tpos = GameState.level.world_to_map(new_pos)
		if not GameState.level.is_blocking(tpos) and \
				GameState.player.actor.tpos() != tpos and \
				not GameState.level.is_locked_door(tpos) and \
				not GameState.level.is_closed_door(tpos):
			possible_moves.append(tpos)
		if GameState.player.actor.tpos() == tpos:
			possible_attack = true
	
	# Attempt and attack if the player is near or move
	if possible_attack:
		Sounds.play_enemy_hit()
		attack(GameState.player.actor)
	else:
		possible_moves.shuffle()
		position = GameState.level.map_to_world(possible_moves[0])

func attack(actor: Actor):
	actor.take_damage(mob.strength)

func charge_time():
	turn_acc += turn_speed

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
	get_parent().add_child(damage_text)
	
	hp -= damage
	hp = clamp(hp, 0, max_hp)
	if hp <= 0:
		die()

func heal(amount: int):
	take_damage(-amount, false, true)

func die():
	queue_free()

static func priority_sort(a: Actor, b: Actor):
	return a.turn_acc > b.turn_acc
