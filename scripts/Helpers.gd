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

func dice_roll(count: int = 1, sides: int = 6):
	var sum = 0
	for i in range(count):
		var roll = randi() % sides + 1
		sum += roll
	return sum

func tile_to_world(tpos: Vector2, center_offset: bool = true) -> Vector2:
	tpos *= Constants.TILE_SIZE
	if center_offset:
		tpos += (Constants.TILE_V / 2)
	return tpos

func world_to_tile(world_pos: Vector2):
	var tpos = world_pos / float(Constants.TILE_SIZE)
	tpos = tpos.floor()
	return tpos

func valid(obj):
	if obj == null: return false
	if !is_instance_valid(obj): return false
	if !obj.is_inside_tree(): return false
	if obj.is_queued_for_deletion(): return false
	return true

