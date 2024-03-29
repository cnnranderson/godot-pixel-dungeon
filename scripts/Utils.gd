extends Node

"""
Misc helper functions
"""

"""
Returns true or false for a given percent chance of something happening.

percentage - The chance of a successful event.
"""
func chance_luck(percentage):
	if percentage > 99:
		return true
	elif percentage > 0:
		var chance = randi() % 99 + 1
		return chance in range(1, percentage)
	return false

func dice_roll_composed(dice: String) -> int:
	var damage = 0
	var calc = dice.split("+")
	for die in calc:
		var attempts = die.split("d")
		damage += dice_roll(attempts[0] as int, attempts[1] as int)
	return damage

func dice_roll(count: int = 1, sides: int = 6) -> int:
	var sum = 0
	for i in range(count):
		var roll = randi() % sides + 1
		sum += roll
	return sum

func tile_to_world(tpos: Vector2i, center_offset: bool = true) -> Vector2:
	var world_pos = Vector2(tpos)
	world_pos *= Constants.TILE_SIZE
	if center_offset:
		world_pos += Constants.TILE_V * 0.5
	return world_pos

func world_to_tile(world_pos: Vector2) -> Vector2i:
	var tpos = Vector2i(world_pos / float(Constants.TILE_SIZE))
	return tpos

func valid(obj):
	if obj == null: return false
	if !is_instance_valid(obj): return false
	if !obj.is_inside_tree(): return false
	if obj.is_queued_for_deletion(): return false
	return true

static func free_children(node):
	for n in node.get_children():
		n.queue_free()
