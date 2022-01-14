class_name Action

enum ActionType {
	TEST,
	MOVE,
	ATTACK,
	WAIT
}
var type = null
var dest: Vector2
var target
var cost: int = 1
