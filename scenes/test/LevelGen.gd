extends Node2D

onready var gen_room = $Control/Container/GenRoom
onready var gen_hallway = $Control/Container/GenHallway
onready var connect_hallway = $Control/Container/Connect
onready var trim_hallway = $Control/Container/Trim
onready var level = $Level

var map: Array = []
var width = 45
var height = 31
var room_count = 8
var rooms = []
var regions = []
var region = 0

var room_gen = false
var hallway_gen = false
var connected_gen = false
var slack_gen = false
var show_gen = true

func _ready():
	_init_map()

func _init_map():
	map = new_map()
	clean_map()

func new_map():
	region = 0
	rooms.clear()
	map.clear()
	var matrix = []
	for x in range(width):
		matrix.append([])
		for y in range(height):
			matrix[x].append(-1)
	return matrix

func clean_map():
	for x in range(width):
		for y in range(height):
			level.set_tile(Vector2(x, y), Level.TILE_TYPE.BLOCK, Level.TILE.ground)
	pass

func _add_rooms():
	for i in range(200):
		# Create a room of certain size
		var size = floor(rand_range(1, 3)) * 2 + 1
		var stretch = floor(rand_range(0, 1 + floor(size / 2))) * 2
		var rwidth = size
		var rheight = size
		if Helpers.chance_luck(50):
			rwidth += stretch
		else:
			rheight += stretch
		
		# Blueprint a room to be made
		var x = floor(rand_range(0, floor((width - rwidth) / 2))) * 2 + 1
		var y = floor(rand_range(0, floor((height - rheight) / 2))) * 2 + 1
		var room = Rect2(x, y, rwidth, rheight)
		
		# Check if any rooms overlap
		var overlaps = false
		for other in rooms:
			if room.intersects(other, true):
				overlaps = true
				break
		if overlaps: continue
		
		# Safe to add the room; carve out the space
		print("adding room")
		region += 1
		rooms.append(room)
		for j in range(x, x + rwidth):
			for k in range(y, y + rheight):
				_carve(Vector2(j, k))
		if show_gen: yield(get_tree().create_timer(0.05), "timeout")
		
		if rooms.size() > room_count:
			break
	
	# Done with creating all rooms
	room_gen = true
	print("done")

func _add_hallways():
	var hallway = false
	for y in range(1, height, 2):
		for x in range(1, width, 2):
			var tpos = Vector2(x, y)
			if map[tpos.x][tpos.y] != -1: continue
			print("adding hallway")
			_grow_hallway(tpos)
			hallway = true
			break
		if hallway: break

func _grow_hallway(start: Vector2):
	region += 1
	var cells = []
	
	_carve(start)
	cells.append(start)
	var last_dir
	while not cells.empty():
		var cell = cells.back()
		var unmade_cells = []
		for dir in Constants.CARDINAL:
			if can_tile(cell, dir):
				unmade_cells.append(dir)
		if not unmade_cells.empty():
			var dir
			if unmade_cells.has(last_dir) and Helpers.chance_luck(50):
				dir = last_dir
			else:
				unmade_cells.shuffle()
				dir = unmade_cells.front()
			
			_carve(cell + dir)
			_carve(cell + dir * 2)
			cells.append(cell + dir * 2)
			last_dir = dir
			if show_gen: yield(get_tree().create_timer(0.01), "timeout")
		else:
			cells.pop_back()
			last_dir = null
			if show_gen: yield(get_tree().create_timer(0.01), "timeout")
	_add_hallways()

func _connect_regions():
	print("connecting regions")
	var connecting_regions = {}
	for x in range(1, width - 1):
		for y in range(1, height - 1):
			if map[x][y] != -1: continue
			
			var regions = []
			for dir in Constants.CARDINAL:
				var tile = map[x + dir.x][y + dir.y]
				if tile != -1  and tile != -2 and not regions.has(tile):
					regions.append(tile)
			
			if regions.size() < 2: continue
			connecting_regions[Vector2(x, y)] = regions
	
	# Begin setup for connecting regions
	var connectors = connecting_regions.keys()
	var merged = {}
	var open_regions = []
	for i in range(1, region + 1):
		merged[i] = i
		open_regions.append(i)
	
	# Loop until everything has been unified
	while open_regions.size() > 1:
		var connector = connectors[randi() % connectors.size()]
		
		# Carve a junction
		_carve(connector, true)
		if show_gen: yield(get_tree().create_timer(0.05), "timeout")
		
		# Merge connected regions
		var r = connecting_regions[connector]
		var source = merged[r.back()]
		var dest = merged[r.front()]
		
		# Mark merged regions
		for i in range(1, region + 1):
			if source == merged[i]:
				merged[i] = dest
		
		# Cleanup
		open_regions.erase(source)
		var cleanup = []
		for item in connectors:
			var old_r = connecting_regions[item]
			if merged[old_r.front()] == merged[old_r.back()]:
				cleanup.append(item)
		for item in cleanup:
			connectors.erase(item)

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

func _remove_deadends():
	region = -1
	print("removing deadends")
	var done = false
	while not done:
		done = true
		for x in range(1, width):
			for y in range(1, height):
				if map[x][y] == -1: continue
				
				var exits = 0
				for dir in Constants.CARDINAL:
					if map[x + dir.x][y + dir.y] != -1: exits += 1
				
				if exits != 1: continue
				
				done = false
				_carve(Vector2(x, y))
				if show_gen: yield(get_tree().create_timer(0.01), "timeout")
	print("done")

func _carve(tpos: Vector2, connector: bool = false):
	if connector:
		map[tpos.x][tpos.y] = -2
	else:
		map[tpos.x][tpos.y] = region
	
	match map[tpos.x][tpos.y]:
		-1:
			level.set_tile(tpos, Level.TILE_TYPE.BLOCK, Level.TILE.ground)
		-2:
			level.set_tile(tpos, Level.TILE_TYPE.INTERACTIVE, Level.TILE.door_open)
		_:
			level.set_tile(tpos, Level.TILE_TYPE.NOBLOCK, Level.TILE.ground)

# Generator/Trigger buttons
func _on_GenRoom_pressed():
	_init_map()
	_add_rooms()

func _on_GenHallway_pressed():
	if room_gen and not hallway_gen:
		_add_hallways()
	print(region)

func _on_Connect_pressed():
	if not connected_gen:
		_connect_regions()

func _on_Trim_pressed():
	_remove_deadends()
