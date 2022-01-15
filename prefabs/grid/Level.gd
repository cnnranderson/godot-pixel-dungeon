extends TileMap
class_name Level

enum TILE_TYPE {
	BLOCK,
	NOBLOCK,
	INTERACTIVE
}
const TILE = {
	"ground": Vector2(0, 0),
	"door_closed": Vector2(3, 0),
	"door_open": Vector2(3, 0),
	"door_locked": Vector2(3, 1)
}
const SOUND = {
	"door": "res://assets/pd_import/sounds/snd_door_open.mp3",
	"unlock": "res://assets/pd_import/sounds/snd_unlock.mp3"
}

export var level_size := Vector2(45, 30)
export var rooms_size := Vector2(4, 8)
export var rooms_max := 15

var astar = AStar2D.new()
var map: Array = []

var blocked = []

func _ready():
	astar.reserve_space(level_size.x * level_size.y)
	_add_points()
	_connect_points()

### PATH FINDING - TODO: CLEANUP
func _add_points():
	var used_cells = get_used_cells_by_id(TILE_TYPE.NOBLOCK)
	for cell in used_cells:
		var type = get_cellv(cell)
		astar.add_point(tile_id(cell), cell, 1.0)

func _connect_points():
	var used_cells = get_used_cells()
	for cell in used_cells:
		for neighbor in Constants.VALID_DIRS:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(tile_id(cell), tile_id(next_cell), false)

func get_travel_path(start, end):
	var start_id = tile_id(start)
	var end_id = tile_id(end)
	if astar.has_point(start_id) and astar.has_point(end_id):
		var path = Array(astar.get_point_path(start_id, end_id))
		path.remove(0)
		return path
	return []

func tile_id(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b

func free_tile(tpos: Vector2):
	var id = tile_id(tpos)
	if astar.has_point(id):
		astar.set_point_disabled(id, false)
		blocked.remove(blocked.find(tpos))

func occupy_tile(tpos: Vector2):
	var id = tile_id(tpos)
	if astar.has_point(id):
		astar.set_point_disabled(id, true)
		blocked.append(tpos)

func can_move_to(tpos: Vector2) -> bool:
	var tile_id = tile_id(tpos)
	return astar.has_point(tile_id) and not astar.is_point_disabled(tile_id)

### UTILITY FUNCTIONS
func reset_doors():
	var tiles = get_used_cells()
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
	return get_cell_autotile_coord(tpos.x, tpos.y)

func set_tile(tpos: Vector2, set: int, tile: Vector2):
	set_cell(tpos.x, tpos.y, set, false, false, false, tile)

func is_blocking(tpos: Vector2) -> bool:
	var type = get_cellv(tpos)
	return type == TILE_TYPE.BLOCK

func is_door(tpos: Vector2) -> bool:
	return is_open_door(tpos) or is_closed_door(tpos) or is_locked_door(tpos)

func is_locked_door(tpos: Vector2) -> bool:
	var tile = get_tile(tpos)
	var type = get_cellv(tpos)
	return tile == TILE.door_locked and type == TILE_TYPE.INTERACTIVE

func is_open_door(tpos: Vector2) -> bool:
	var tile = get_tile(tpos)
	var type = get_cellv(tpos)
	return tile == TILE.door_open and type == TILE_TYPE.NOBLOCK

func is_closed_door(tpos: Vector2) -> bool:
	var tile = get_tile(tpos)
	var type = get_cellv(tpos)
	return tile == TILE.door_closed and type == TILE_TYPE.INTERACTIVE


### ROOM GENERATION - TODO: CLEANUP
func new_gen():
	clear()
	
	for vector in _generate_data():
		set_tile(vector, 1, TILE.ground)
	pass

func _generate_data() -> Array:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var data := {}
	var rooms := []
	for r in range(6):
		var room := _get_random_room(rng)
		if _intersects(rooms, room):
			continue
		
		_add_room(data, rooms, room)
		if rooms.size() > 1:
			var room_previous: Rect2 = rooms[-2]
			_add_connection(rng, data, room_previous, room)
	return data.keys()

func _get_random_room(rng: RandomNumberGenerator) -> Rect2:
	var width := rng.randi_range(rooms_size.x, rooms_size.y)
	var height := rng.randi_range(rooms_size.x, rooms_size.y)
	var x := rng.randi_range(0, level_size.x - width - 1)
	var y := rng.randi_range(0, level_size.y - height - 1)
	return Rect2(x, y, width, height)

func _add_room(data: Dictionary, rooms: Array, room: Rect2) -> void:
	rooms.push_back(room)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			data[Vector2(x, y)] = null

func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int) -> void:
	for t in range(min(start, end), max(start, end) + 1):
		var point := Vector2.ZERO
		match axis:
			Vector2.AXIS_X: point = Vector2(t, constant)
			Vector2.AXIS_Y: point = Vector2(constant, t)
		data[point] = null

func _add_connection(rng: RandomNumberGenerator, data: Dictionary, room1: Rect2, room2: Rect2) -> void:
	var room_center1 := (room1.position + room1.end) / 2
	var room_center2 := (room2.position + room2.end) / 2
	if rng.randi_range(0, 1) == 0:
		_add_corridor(data, room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
	else:
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		_add_corridor(data, room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)

func _intersects(rooms: Array, room: Rect2) -> bool:
	var out := false
	for room_other in rooms:
		if room.intersects(room_other):
			out = true
			break
	return out




