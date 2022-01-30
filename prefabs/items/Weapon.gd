extends Item
class_name Weapon

enum WeaponType {
	AXE,
	SWORD,
	STAFF,
	UNIQUE
}

export(WeaponType) var type = WeaponType.AXE
export var name = "Axe"
export var equippable = true
export var roll_damage = "1d4"
export var upgrade = 0
export var enchanted = false # TODO figure out special weapon enchantments
export var unique = false

func get_name():
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
	var total_damage = 0
	var calc = roll_damage.split("+")
	for die in calc:
		var attempts = die.split("d")
		total_damage += Helpers.dice_roll(attempts[0] as int, attempts[1] as int)
	return total_damage
