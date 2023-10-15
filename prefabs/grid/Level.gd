extends TileMap
class_name Level

enum TILE_TYPE {
	BLOCK,
	NOBLOCK,
	INTERACTIVE
}
const TILE = {
	"wall": Vector2i(0, 0),
	"ground": Vector2i(0, 0),
	"stair_down": Vector2i(0, 1),
	"stair_up": Vector2i(0, 0),
	"door_closed": Vector2i(3, 0),
	"door_open": Vector2i(3, 0),
	"door_locked": Vector2i(3, 1)
}
const SOUND = {
	"door": "res://assets/pd_import/sounds/snd_door_open.mp3",
	"unlock": "res://assets/pd_import/sounds/snd_unlock.mp3"
}

const MapGen = preload("res://scripts/procgen/MapGenerator.gd")

@export var level_size := Vector2i(45, 31)
@export var rooms_max := 100

var map: Array = []
var astar: AStarGrid2D
var spawn: Vector2i
var stair_spawn: Vector2i
var blocked = []
var items = {}
var enemies = []

func init_level():
	_generate_map()
	_generate_astar_path()

func _generate_map():
	blocked.clear()
	var map_gen = MapGen.new()
	map = map_gen.generate_map(rooms_max, level_size.x, level_size.y)
	spawn = map_gen.spawn_point
	items = map_gen.items
	enemies = map_gen.enemies
	print("Map Generation complete")
	refresh_map()

func _generate_astar_path():
	astar = AStarGrid2D.new()
	#astar.diagonal_mode = 0 AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.size = level_size
	astar.cell_size = Vector2i.ONE * Constants.TILE_SIZE
	astar.update()
	_add_points()

func refresh_map():
	for x in level_size.x:
		for y in level_size.y:
			var tpos = Vector2i(x, y)
			match map[x][y]:
				-1:
					set_tile(tpos, TILE_TYPE.BLOCK, TILE.wall)
					blocked.append(tpos)
				-2:
					set_tile(tpos, TILE_TYPE.INTERACTIVE, TILE.door_closed)
				-3:
					set_tile(tpos, TILE_TYPE.INTERACTIVE, TILE.stair_down)
				_:
					set_tile(tpos, TILE_TYPE.NOBLOCK, TILE.ground)
	set_tile(spawn, TILE_TYPE.INTERACTIVE, TILE.stair_up)


### A-STAR PATHFINDING UTILITY
func get_travel_path(start, end):
	var path = astar.get_id_path(start, end)
	return path

func free_tile(tpos: Vector2i):
	if astar.is_in_boundsv(tpos):
		astar.set_point_solid(tpos, false)
		blocked.erase(blocked.find(tpos))

func occupy_tile(tpos: Vector2i):
	astar.set_point_solid(tpos, true)
	blocked.append(blocked.find(tpos))

func can_move_to(tpos: Vector2i) -> bool:
	return astar.is_in_boundsv(tpos) and not astar.is_point_solid(tpos)

func _add_points():
	print(blocked.size())
	for cell in blocked:
		astar.set_point_solid(cell, true)

func _tile_id(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b


### UTILITY FUNCTIONS
func get_random_empty_tile() -> Vector2i:
	var attempts = level_size.x * level_size.y
	while attempts > 0:
		attempts -= 1
		var x = randi() % map.size()
		var y = randi() % map[0].size()
		if can_move_to(Vector2i(x, y)):
			return Vector2i(x, y)
	return Vector2i.ZERO

func reset_doors():
	var tiles = get_used_cells(0)
	for tile in tiles:
		close_door(tile)

func unlock_door(tpos: Vector2i, keep_closed: bool = true):
	if is_locked_door(tpos):
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.unlock)
		if keep_closed:
			set_tile(tpos, TILE_TYPE.INTERACTIVE, TILE.door_closed)
		else:
			set_tile(tpos, TILE_TYPE.NOBLOCK, TILE.door_open)

func open_door(tpos: Vector2i):
	if is_closed_door(tpos) or is_locked_door(tpos):
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.door)
		set_tile(tpos, TILE_TYPE.NOBLOCK, TILE.door_open)

func close_door(tpos: Vector2i):
	if is_open_door(tpos):
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.door)
		set_tile(tpos, TILE_TYPE.INTERACTIVE, TILE.door_closed)

func get_tile(tpos: Vector2i):
	return get_cell_atlas_coords(0, tpos)

func set_tile(tpos: Vector2i, type: int, tile: Vector2):
	set_cell(0, tpos, type, tile)

func is_blocking(tpos: Vector2i) -> bool:
	var type = get_cell_source_id(0, tpos)
	return type == TILE_TYPE.BLOCK

func is_door(tpos: Vector2i) -> bool:
	return is_open_door(tpos) or is_closed_door(tpos) or is_locked_door(tpos)

func is_locked_door(tpos: Vector2i) -> bool:
	var tile = get_tile(tpos)
	var type = get_cell_source_id(0, tpos)
	return tile == TILE.door_locked and type == TILE_TYPE.INTERACTIVE

func is_open_door(tpos: Vector2i) -> bool:
	var tile = get_tile(tpos)
	var type = get_cell_source_id(0, tpos)
	return tile == TILE.door_open and type == TILE_TYPE.NOBLOCK

func is_closed_door(tpos: Vector2i) -> bool:
	var tile = get_tile(tpos)
	var type = get_cell_source_id(0, tpos)
	return tile == TILE.door_closed and type == TILE_TYPE.INTERACTIVE

func is_stair_down(tpos: Vector2i) -> bool:
	var tile = get_tile(tpos)
	var type = get_cell_source_id(0, tpos)
	return tile == TILE.stair_down and type == TILE_TYPE.INTERACTIVE

