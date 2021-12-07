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

func tile_to_world(tile_pos: Vector2, center_offset: bool = true) -> Vector2:
	tile_pos *= Global.TILE_SIZE
	if center_offset:
		tile_pos += (Global.TILE_V / 2)
	return tile_pos

func world_to_tile(world_pos: Vector2):
	var tile_position = world_pos / float(Global.TILE_SIZE)
	tile_position = tile_position.floor()
	return tile_position

func valid(obj):
	if obj == null: return false
	if !is_instance_valid(obj): return false
	if !obj.is_inside_tree(): return false
	if obj.is_queued_for_deletion(): return false
	return true

