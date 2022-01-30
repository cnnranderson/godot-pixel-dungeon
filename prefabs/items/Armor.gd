extends Item
class_name Armor

enum ArmorType {
	CLOTH,
	LEATHER,
	CHAIN,
	SCALE,
	PLATE,
	UNIQUE
}

export(ArmorType) var type = ArmorType.LEATHER
export var name = "Cloth"
export var equippable = true
export var cursed = false
export var str_required = 1
export var ac = 1
export var upgrade = 0
export var enchanted = false # TODO figure out special weapon enchantments
export var unique = false

func get_name():
	var value = ""
	match(type):
		ArmorType.UNIQUE:
			value += "the "
		_:
			value += "%s armor" % name
	return value
