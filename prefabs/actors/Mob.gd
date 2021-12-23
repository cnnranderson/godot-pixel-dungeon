extends Resource
class_name Mob

enum Type {
	ENEMY,
	SHOPKEEPER,
	PLAYER
}

export(Type) var type
export(Resource) var movement
export(Texture) var texture
export(int) var hp
