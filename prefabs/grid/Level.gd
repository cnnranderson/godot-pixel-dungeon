extends TileMap
class_name Level

enum TILE_TYPE {
	BLOCK,
	NOBLOCK,
	INTERACTIVE
}
const TILE = {
	"wall": Vector2(0, 0),
	"ground": Vector2(0, 0),
	"stair_down": Vector2(0, 1),
	"stair_up": Vector2(0, 0),
	"door_closed": Vector2(3, 0),
	"door_open": Vector2(3, 0),
	"door_locked": Vector2(3, 1)
}
const SOUND = {
	"door": "res://assets/pd_import/sounds/snd_door_open.mp3",
	"unlock": "res://assets/pd_import/sounds/snd_unlock.mp3"
}

const MapGen = preload("res://scripts/procgen/MapGenerator.gd")

@export var level_size := Vector2(21, 15)
@export var rooms_max := 100

var map: Array = []
var astar = AStar2D.new()
var spawn: Vector2
var stair_spawn: Vector2
var blocked = []
var items = {}
var enemies = []

func init_level():
	_generate_map()
	_generate_astar_path()

func _generate_map():
	var map_gen = MapGen.new()
	map = map_gen.generate_map(rooms_max, level_size.x, level_size.y)
	spawn = map_gen.spawn_point
	items = map_gen.items
	enemies = map_gen.enemies
	print("Map Generation complete")
	refresh_map()

func _generate_astar_path():
	astar.clear()
	astar.reserve_space(level_size.x * level_size.y)
	_add_points()
	_connect_points()

func refresh_map():
	for x in level_size.x:
		for y in level_size.y:
			var tpos = Vector2(x, y)
			match map[x][y]:
				-1:
					set_tile(tpos, TILE_TYPE.BLOCK, TILE.wall)
				-2:
					set_tile(tpos, TILE_TYPE.INTERACTIVE, TILE.door_open)
				-3:
					set_tile(tpos, TILE_TYPE.INTERACTIVE, TILE.stair_down)
				_:
					set_tile(tpos, TILE_TYPE.NOBLOCK, TILE.ground)
	
	set_tile(spawn, TILE_TYPE.INTERACTIVE, TILE.stair_up)


### A-STAR PATHFINDING UTILITY
func get_travel_path(start, end):
	var start_id = _tile_id(start)
	var end_id = _tile_id(end)
	if astar.has_point(start_id) and astar.has_point(end_id):
		var path = Array(astar.get_point_path(start_id, end_id))
		path.remove(0)
		return path
	return []

func free_tile(tpos: Vector2):
	var id = _tile_id(tpos)
	if astar.has_point(id):
		astar.set_point_disabled(id, false)
		blocked.remove(blocked.find(tpos))

func occupy_tile(tpos: Vector2):
	var id = _tile_id(tpos)
	if astar.has_point(id):
		astar.set_point_disabled( id)
		blocked.append(tpos)

func can_move_to(tpos: Vector2) -> bool:
	var tile_id = _tile_id(tpos)
	return astar.has_point(tile_id) and not astar.is_point_disabled(tile_id)

func _add_points():
	var used_cells = get_used_cells_by_id(TILE_TYPE.NOBLOCK)
	used_cells.append_array(get_used_cells_by_id(TILE_TYPE.INTERACTIVE))
	for cell in used_cells:
		var type = get_tile(cell)
		astar.add_point(_tile_id(cell), cell, 1.0)

func _connect_points():
	var used_cells = get_used_cells(0)
	for cell in used_cells:
		for neighbor in Constants.VALID_DIRS:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(_tile_id(cell), _tile_id(next_cell), false)

func _tile_id(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b


### UTILITY FUNCTIONS
func get_random_empty_tile() -> Vector2:
	var attempts = level_size.x * level_size.y
	while attempts > 0:
		attempts -= 1
		var x = randi() % map.size()
		var y = randi() % map[0].size()
		if can_move_to(Vector2(x, y)):
			return Vector2(x, y)
	return Vector2.ZERO

func reset_doors():
	var tiles = get_used_cells(0)
	for tile in tiles:
		close_door(tile)

func unlock_door(tpos: Vector2, keep_closed: bool = true):
	if is_locked_door(tpos):
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.unlock)
		if keep_closed:
			set_tile(tpos, TILE_TYPE.INTERACTIVE, TILE.door_closed)
		else:
			set_tile(tpos, TILE_TYPE.NOBLOCK, TILE.door_open)

func open_door(tpos: Vector2):
	if is_closed_door(tpos) or is_locked_door(tpos):
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.door)
		set_tile(tpos, TILE_TYPE.NOBLOCK, TILE.door_open)

func close_door(tpos: Vector2):
	if is_open_door(tpos):
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.door)
		set_tile(tpos, TILE_TYPE.INTERACTIVE, TILE.door_closed)

func get_tile(tpos: Vector2):
	return get_cell_atlas_coords(0, tpos)

func set_tile(tpos: Vector2, set: int, tile: Vector2):
	set_cell(0, tpos, set, tile)

func is_blocking(tpos: Vector2) -> bool:
	var type = get_cell_source_id(0, tpos)
	return type == TILE_TYPE.BLOCK

func is_door(tpos: Vector2) -> bool:
	return is_open_door(tpos) or is_closed_door(tpos) or is_locked_door(tpos)

func is_locked_door(tpos: Vector2) -> bool:
	var tile = get_tile(tpos)
	var type = get_cell_source_id(0, tpos)
	return tile == TILE.door_locked and type == TILE_TYPE.INTERACTIVE

func is_open_door(tpos: Vector2) -> bool:
	var tile = get_tile(tpos)
	var type = get_cell_source_id(0, tpos)
	return tile == TILE.door_open and type == TILE_TYPE.NOBLOCK

func is_closed_door(tpos: Vector2) -> bool:
	var tile = get_tile(tpos)
	var type = get_cell_source_id(0, tpos)
	return tile == TILE.door_closed and type == TILE_TYPE.INTERACTIVE

func is_stair_down(tpos: Vector2) -> bool:
	var tile = get_tile(tpos)
	var type = get_cell_source_id(0, tpos)
	return tile == TILE.stair_down and type == TILE_TYPE.INTERACTIVE

