tool
extends Area2D
class_name Actor

export(Resource) var mob = null
export(bool) var is_mob = false
export(int) var turn_speed = 20
var turn_acc = 0

func _ready():
	if is_mob:
		if has_node("Sprite"):
			$Sprite.texture = mob.texture

func can_act():
	return turn_acc >= Constants.BASE_ACTION_COST

func act(action):
	turn_acc -= Constants.BASE_ACTION_COST
	pass

func charge_time():
	turn_acc += turn_speed
	pass

func take_damage(damage: int):
	if mob:
		mob.hp -= damage
		if mob.hp <= 0:
			die()

func die():
	queue_free()

static func priority_sort(a: Actor, b: Actor):
	return a.turn_acc > b.turn_acc
