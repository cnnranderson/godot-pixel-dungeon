class_name ActionBuilder

var action = Action.new()

func wait(cost: int = 1):
	action.type = Action.ActionType.WAIT
	action.cost = cost
	return action

func move(dest: Vector2 = Vector2(0, 0), cost: int = 1):
	action.type = Action.ActionType.MOVE
	action.dest = dest
	action.cost = cost
	return action

func attack(dest: Vector2 = Vector2(0, 0), target = null, cost: int = 1):
	action.type = Action.ActionType.ATTACK
	action.dest = dest
	action.target = target
	action.cost = cost
	return action

func search(cost: int = 1):
	action.type = Action.ActionType.SEARCH
	action.cost = cost
	return action
