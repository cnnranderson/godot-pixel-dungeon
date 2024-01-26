extends Item
class_name Weapon

enum WeaponType {
	AXE,
	SWORD,
	STAFF,
	UNIQUE
}

@export var type: WeaponType = WeaponType.AXE
@export var name = "Axe"
@export var equippable = true
@export var roll_damage = "1d4"
@export var weight = 10
@export var upgrade = 0
@export var enchanted = false # TODO figure out special weapon enchantments
@export var unique = false

func get_item_name():
	var value = ""
	match(type):
		WeaponType.AXE:
			value += "an "
		WeaponType.SWORD, WeaponType.STAFF:
			value += "a "
		WeaponType.UNIQUE:
			value += "the "
	value += name
	return value

func calc_damage():
	return Utils.dice_roll_composed(roll_damage)
