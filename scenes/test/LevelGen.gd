extends Node2D

onready var gen_room = $Control/Container/GenRoom
onready var gen_hallway = $Control/Container/GenHallway
onready var connect_hallway = $Control/Container/Connect
onready var trim_hallway = $Control/Container/Trim
onready var level = $Level

var map: Array = []
var width = 45
var height = 29
var room_count = 14
var rooms = []
var regions = []
var region = 0

var room_gen = false
var hallway_gen = false
var connected_gen = false
var slack_gen = false

var room_types = [
	Vector2(3, 3),
	Vector2(5, 3),
	Vector2(3, 5),
	Vector2(5, 5),
	Vector2(3, 7),
	Vector2(7, 3),
	Vector2(7, 7)
]

func _ready():
	_init_map()

func _init_map():
	map = new_map()
	refresh_map()

func new_map():
	rooms.clear()
	map.clear()
	var matrix = []
	for x in range(width):
		matrix.append([])
		for y in range(height):
			matrix[x].append(-1)
	return matrix

func refresh_map():
	for x in range(width):
		for y in range(height):
			if map[x][y] != -1:
				level.set_tile(Vector2(x, y), Level.TILE_TYPE.NOBLOCK, Level.TILE.ground)
			else:
				level.set_tile(Vector2(x, y), Level.TILE_TYPE.BLOCK, Level.TILE.ground)
	pass

func _add_room():
	print("adding prop room")
	for i in range(200):
		var size = floor(rand_range(1, 3) * 2 + 1)
		var stretch = floor(rand_range(0, 1 + floor(size / 2)) * 2)
		var rwidth = size
		var rheight = size
		if Helpers.chance_luck(50):
			rwidth += stretch
		else:
			rheight += stretch
		
		var x = floor(rand_range(0, (width - 1 - rwidth) / 2)) * 2 + 1
		var y = floor(rand_range(0, (height - 1 - rheight) / 2)) * 2 + 1
		
		var room = Rect2(x, y, rwidth, rheight)
		var overlaps = false
		for other in rooms:
			if room.intersects(other, true):
				overlaps = true
				break
		
		if overlaps: continue
		
		rooms.append(room)
		region += 1
		for j in range(x, x + rwidth):
			for k in range(y, y + rheight):
				_carve(Vector2(j, k))
	room_gen = true
	print("done")

func _add_hallways():
	for x in range(1, width, 2):
		for y in range(1, height, 2):
			var tpos = Vector2(x, y)
			if map[x][y] != -1:
				continue
			print("adding hallway")
			_grow_hallway(tpos)
			break
		break
	
func _grow_hallway(start: Vector2):
	region += 1
	var cells = []
	
	_carve(start)
	cells.append(start)
	while not cells.empty():
		var last_dir
		var cell = cells.back()
		var unmade_cells = []
		for dir in Constants.CARDINAL:
			if can_tile(cell, dir):
				unmade_cells.append(dir)
		if not unmade_cells.empty():
			var dir
			if unmade_cells.has(last_dir) and Helpers.chance_luck(100):
				dir = last_dir
			else:
				unmade_cells.shuffle()
				dir = unmade_cells.front()
			
			_carve(cell + dir)
			_carve(cell + dir * 2)
			cells.append(cell + dir * 2)
			last_dir = dir
			yield(get_tree().create_timer(0.01), "timeout")
		else:
			cells.pop_back()
			last_dir = null
			yield(get_tree().create_timer(0.01), "timeout")
	_add_hallways()
	print("done")

func can_tile(tpos: Vector2, dir: Vector2):
	for i in range(2, 4):
		var x
		var y
		if dir.x != 0:
			x = tpos.x + dir.x * i
			y = tpos.y
		else:
			x = tpos.x
			y = tpos.y + dir.y * i
		if x < 0 or x >= width or y < 0 or y >= height or map[x][y] != -1:
			return false
	
	var bound = tpos + dir * 2
	return map[bound.x][bound.y] == -1

func _connect_region():
	print("connecting regions")
	pass

func _slack_hallway():
	print("slacking hallway")
	pass

func _carve(tpos: Vector2, region: int = region):
	map[tpos.x][tpos.y] = region
	
	match map[tpos.x][tpos.y]:
		-1:
			level.set_tile(tpos, Level.TILE_TYPE.BLOCK, Level.TILE.ground)
		0:
			level.set_tile(tpos, Level.TILE_TYPE.NOBLOCK, Level.TILE.ground)
		_:
			level.set_tile(tpos, Level.TILE_TYPE.INTERACTIVE, Level.TILE.door_closed)

# Generator/Trigger buttons
func _on_GenRoom_pressed():
	if rooms.size() < room_count and not room_gen:
		_add_room()
	elif rooms.size() >= room_count:
		_init_map()
		_add_room()

func _on_GenHallway_pressed():
	if room_gen and not hallway_gen:
		_add_hallways()

func _on_Connect_pressed():
	refresh_map()
	if room_gen and hallway_gen and not connected_gen:
		pass

func _on_Trim_pressed():
	if room_gen and hallway_gen and connected_gen and not slack_gen:
		pass
