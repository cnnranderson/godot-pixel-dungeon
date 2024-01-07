extends Node
class_name MapGenerator

var map: Array = []
var width = 31
var height = 31
var max_rooms = 80
var rooms = []
var regions = []
var region = 0
var spawn_point = Vector2i(15, 15)

var items = {
	"key_spawns": [],
	"coin_spawns": [],
	"armor_spawns": [],
	"weapon_spawns": [],
	"scroll_spawns": []
}
var enemies = []
var stair_spawn: Vector2

var debug = false

func _ready():
	pass

func generate_map(max_rooms: int = 200, width: int = 31, height: int = 31):
	self.width = width
	self.height = height
	self.max_rooms = 80 if max_rooms > 80 else max_rooms
	
	# Width and Height must be odd to alleviate issues with generation
	if width % 2 == 0: width += 1
	if height % 2 == 0: height += 1
	
	# Generate the map
	map = _clear_map()
	
	# Generate rooms/hallways
	_add_rooms()
	_add_hallways()
	
	# Connect rooms/hallways and trim deadends
	_connect_regions()
	_remove_deadends()
	
	# TODO: Decorate map later
	return map

func _clear_map():
	region = 0
	rooms.clear()
	map.clear()
	var grid = []
	for x in range(width):
		grid.append([])
		for y in range(height):
			grid[x].append(-1)
	return grid

func _add_rooms():
	for i in range(200):
		# Create a room of certain size
		var size = floor(randf_range(1, 3)) * 2 + 1
		var stretch = floor(randf_range(0, 1 + floor(size / 2))) * 2
		var rwidth = size
		var rheight = size
		if Helpers.chance_luck(50):
			rwidth += stretch
		else:
			rheight += stretch
		
		# Blueprint a room to be made
		var x = floor(randf_range(0, floor((width - rwidth) / 2))) * 2 + 1
		var y = floor(randf_range(0, floor((height - rheight) / 2))) * 2 + 1
		var room = Rect2(x, y, rwidth, rheight)
		
		# Check if any rooms overlap
		var overlaps = false
		for other in rooms:
			if room.intersects(other, true):
				overlaps = true
				break
		if overlaps: continue
		
		# Safe to add the room; carve out the space
		if debug: print("adding room")
		region += 1
		rooms.append(room)
		for j in range(x, x + rwidth):
			for k in range(y, y + rheight):
				_carve(Vector2i(j, k))
		
		# Set the spawn point
		if rooms.size() == 1:
			spawn_point = Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2))
		else:
			# Spawn Stairs or maybe an item
			if not stair_spawn and Helpers.chance_luck(10 + (i / max_rooms) * 10):
				stair_spawn = Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2))
			elif Helpers.chance_luck(25):
				# Scrolls
				items.scroll_spawns.append(Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2)))
			elif Helpers.chance_luck(25):
				# Keys
				items.key_spawns.append(Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2)))
			elif Helpers.chance_luck(25):
				# Coins
				items.coin_spawns.append(Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2)))
			elif Helpers.chance_luck(100):
				# Enemies
				enemies.append(Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2)))
			elif Helpers.chance_luck(15):
				# Weapons
				items.weapon_spawns.append(Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2)))
			elif Helpers.chance_luck(25):
				# Armor
				items.armor_spawns.append(Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2)))
				
		# Stop if we have reached the room limit
		if rooms.size() >= max_rooms:
			if not stair_spawn:
				stair_spawn = Vector2i(x + floor(rwidth / 2), y + floor(rheight / 2))
			break
	
	map[stair_spawn.x][stair_spawn.y] = -3
	# Done with creating all rooms
	if debug: print("done")

func _add_hallways():
	var hallway = false
	for y in range(1, height, 2):
		for x in range(1, width, 2):
			var tpos = Vector2i(x, y)
			if map[tpos.x][tpos.y] != -1: continue
			if debug: print("adding hallway")
			_grow_hallway(tpos)
			hallway = true
			break
		if hallway: break

func _grow_hallway(start: Vector2i):
	region += 1
	var cells = []
	
	_carve(start)
	cells.append(start)
	var last_dir
	while not cells.is_empty():
		var cell = cells.back()
		var unmade_cells = []
		for dir in Constants.CARDINAL:
			if can_tile(cell, dir):
				unmade_cells.append(dir)
		if not unmade_cells.is_empty():
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
		else:
			cells.pop_back()
			last_dir = null
	_add_hallways()

func _connect_regions():
	if debug: print("connecting regions")
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
			connecting_regions[Vector2i(x, y)] = regions
	
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

func can_tile(tpos: Vector2i, dir: Vector2i):
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
	if debug: print("removing deadends")
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
				_carve(Vector2i(x, y))
	if debug: print("done")

func _carve(tpos: Vector2i, connector: bool = false):
	if connector:
		map[tpos.x][tpos.y] = -2
	else:
		map[tpos.x][tpos.y] = region
