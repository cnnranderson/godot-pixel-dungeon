class_name Action

enum ActionType {
	MOVE,
	ATTACK,
	PICKUP,
	UNLOCK_DOOR,
	OPEN_CHEST,
	DESCEND,
	ASCEND,
	EQUIP,
	UNEQUIP,
	WAIT,
	SEARCH,
	TELEPORT
}
var type = null
var dest: Vector2
var target
var cost: int = 1
