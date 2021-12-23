tool
extends Area2D
class_name Actor

const DamagePopup = preload("res://ui/actions/DamagePopup.tscn")

export(Resource) var mob = null
export(bool) var is_mob = false
export(int) var turn_speed = 20
export(int) var hp = 1
var turn_acc = 0
var is_awake = false

func _ready():
	if is_mob:
		hp = mob.max_hp
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
	var damage_text = DamagePopup.instance()
	damage_text.amount = damage
	damage_text.is_crit = Helpers.chance_luck(70)
	damage_text.rect_global_position = position + Vector2(8, 0)
	get_parent().add_child(damage_text)
	
	hp -= damage
	if hp <= 0:
		die()

func die():
	queue_free()

static func priority_sort(a: Actor, b: Actor):
	return a.turn_acc > b.turn_acc
