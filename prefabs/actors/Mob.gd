extends Resource
class_name Mob

enum Type {
	ENEMY,
	FRIEND,
	NPC
}

@export var type: Type
@export var name: String
@export var is_unique: bool
@export var texture: Texture2D
@export var max_hp: int = 1
@export var strength: int = 1
@export var ac: int = 1
@export var level: int = 1
@export var hp: int = 1
@export var xp_value: int = 20
