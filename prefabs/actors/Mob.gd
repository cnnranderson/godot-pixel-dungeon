extends Resource
class_name Mob

enum Type {
	ENEMY,
	FRIEND,
	NPC
}

export(Type) var type
export(Texture) var texture
export(int) var max_hp = 1
export(int) var strength = 1
export(int) var ac = 1
export(int) var level = 1
