class_name GridCell
extends RefCounted

# Contents at location
var _entities: Array
var actor: String #: Actor
# var ambient_tile: AmbientTile

# Sight
var in_vision := false
var displayed := true

var current_display_index: int = 0

var grid_position: Vector2i = Vector2i.ZERO

func _init(pos: Vector2i):
	grid_position = pos

func reset_display() -> void:
	current_display_index = 0
	# _display_entity()

func cycle_display() -> void:
	current_display_index += 1
	var count = _entities.size()
	
	if actor:
		count += 1
	
	if count <= 0:
		return
	
	current_display_index %= count
	

func set_display(b: bool) -> void:
	pass

func add_entity(e: String) -> void:
	pass

func remove_entity(e: String) -> void:
	pass

func get_entities() -> Array:
	return _entities

func get_entity_count() -> int:
	return _entities.size()

func blocks_movement() -> bool:
	return false

func blocks_vision() -> bool:
	return false

func has_any(test_func: Callable) -> bool:
	return false

func set_player_visilbe(v: bool) -> void:
	in_vision = v
