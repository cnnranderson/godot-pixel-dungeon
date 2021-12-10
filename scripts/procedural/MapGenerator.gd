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

func generate_map():
	map = _init_map()
	_build_rooms()
	_build_walls()
	return map

# Initialize an empty map
func _init_map() -> Array:
	var matrix = []
	for x in range(width):
		matrix.append([])
		for y in range(height):
			matrix[x].append(1)
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
			print(room.location)
	
	var exp_attempts = rand_range(min_exp_attempts, max_exp_attempts)
	while exp_attempts > 0:
		_expand_room(rooms[rand_range(0, rooms.size())])
		exp_attempts -= 1
	pass

func _build_walls():
	for room in rooms:
		room = room as MapRoom # Just to get type view of object
		print(room.top_left().y, room.bottom_left().y)
		for x in range(room.top_left().x, room.top_right().x):
			for y in range(room.top_left().y, room.bottom_left().y):
				map[x][y] = 2
			pass
	pass

func _expand_room(room: MapRoom):
	
	room.expansions += 1
