class_name ActionBuilder

var action = Action.new()

func wait(cost: int = 1):
	action.type = Action.ActionType.WAIT
	action.cost = cost
	return action

func move(dest: Vector2 = Vector2i(0, 0), cost: int = 1):
	action.type = Action.ActionType.MOVE
	action.dest = dest
	action.cost = cost
	return action

func attack(dest: Vector2 = Vector2i(0, 0), target = null, cost: int = 1):
	action.type = Action.ActionType.ATTACK
	action.dest = dest
	action.target = target
	action.cost = cost
	return action

func search(cost: int = 1):
	action.type = Action.ActionType.SEARCH
	action.cost = cost
	return action

func teleport(dest: Vector2 = Vector2i(0, 0), cost: int = 1):
	action.type = Action.ActionType.TELEPORT
	action.dest = dest
	action.cost = cost
	return action

func use_item(cost: int = 1):
	action.type = Action.ActionType.USE_ITEM
	action.cost = cost
	return action

func equip(cost: int = 2):
	action.type = Action.ActionType.EQUIP
	action.cost = cost
	return action

func unequip(cost: int = 2):
	action.type = Action.ActionType.UNEQUIP
	action.cost = cost
	return action
