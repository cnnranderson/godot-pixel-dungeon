class_name MapGenerator

var rooms = []
var map = []
var width = 45
var height = 30

var floor_num = 0
var min_rooms = 4
var max_rooms = 8
var min_exp_attempts = 20
var max_exp_attempts = 100
var connection_attempts = 500

const expansion_dir =  [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

func generate_map():
	rooms.clear()
	map = _init_map()
	_build_rooms()
	_place_walls()
	return map

# Initialize an empty map
func _init_map() -> Array:
	var matrix = []
	for x in range(width):
		matrix.append([])
		for y in range(height):
			matrix[x].append(0)
	return matrix

func _build_rooms():
	while rooms.size() < 7:
		var room = MapRoom.new()
		var has_space = true
		var test_pos = Vector2((randi() % width - 1) + 1, (randi() % height - 1) + 1)
		
		for existing_room in rooms:
			existing_room = existing_room as MapRoom
			var dx = abs(existing_room.location.x - test_pos.x)
			var dy = abs(existing_room.location.y - test_pos.y)
			if dx < 2 and dy < 2:
				has_space = false
		
		if has_space:
			room.location = test_pos
			rooms.append(room)
			_refresh_map(room)
	
	var exp_attempts = rand_range(min_exp_attempts, max_exp_attempts)
	while exp_attempts > 0:
		var expanded = _expand_room(rooms[rand_range(0, rooms.size())])
		exp_attempts -= 1 if expanded else 0
	pass

func _refresh_map(room: MapRoom):
	for x in range(clamp(room.top_left().x, 0, width), clamp(room.top_right().x, 0, width)):
		for y in range(clamp(room.top_left().y, 0, height), clamp(room.bottom_left().y, 0, height)):
			map[x][y] = 1
	pass

func _place_walls():
	for room in rooms:
		room = room as MapRoom # Just to get type view of object
		for x in range(clamp(room.top_left().x, 0, width), clamp(room.top_right().x, 0, width)):
			for y in range(clamp(room.top_left().y, 0, height), clamp(room.bottom_left().y, 0, height)):
				if x == room.top_left().x or x == 0:
					map[x][y] = 2
				if x == room.bottom_right().x - 1 or x == width:
					map[x][y] = 2
				if y == room.top_left().y or y == 0:
					map[x][y] = 2
				if y == room.bottom_right().y - 1 or x == height:
					map[x][y] = 2
			pass
	pass

func _expand_room(room: MapRoom):
	var dir = expansion_dir[randi() % expansion_dir.size()]
	match dir:
		Vector2.UP: room.top_height += 1
		Vector2.DOWN: room.bottom_height += 1
		Vector2.LEFT: room.left_width += 1
		Vector2.RIGHT: room.right_width += 1
	_refresh_map(room)
	room.expansions += 1
	
	return true
