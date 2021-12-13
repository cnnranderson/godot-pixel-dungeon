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
	for y in range(height):
		matrix.append([])
		for x in range(width):
			matrix[y].append(0)
	return matrix

func _build_rooms():
	while rooms.size() < 7:
		var room = MapRoom.new()
		var has_space = true
		var test_pos = Vector2((randi() % width - 1) + 2, (randi() % height - 1) + 2)
		print(test_pos)
		
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
		exp_attempts -= 1
	pass

func _refresh_map(room: MapRoom):
	for y in range(clamp(room.top_left().y, 0, height), clamp(room.bottom_left().y, 0, height)):
		for x in range(clamp(room.top_left().x, 0, width), clamp(room.top_right().x, 0, width)):
			map[y][x] = 1
	pass

func _place_walls():
	for room in rooms:
		room = room as MapRoom # Just to get type view of object
		for y in range(clamp(room.top_left().y, 0, height), clamp(room.bottom_left().y, 0, height)):
			for x in range(clamp(room.top_left().x, 0, width), clamp(room.top_right().x, 0, width)):
				if x == room.top_left().x or x == room.bottom_right().x - 1:
					map[y][x] = 2
				if y == room.top_left().y or y == room.bottom_right().y - 1:
					map[y][x] = 2
			pass
	pass

func _expand_room(room: MapRoom):
	var dir = expansion_dir[randi() % expansion_dir.size()]
	var start_line
	var can_expand = true
	match dir:
		Vector2.UP: 
			start_line = [room.top_left(), room.top_right()]
			if room.location.y - room.top_height - 1 >= 0:
				for x in range(room.top_left().x, room.top_right().x - 1):
					if x == width:
						print(room.top_left(), room.top_right())
					if map[room.top_left().y - 1][x] != 0:
						can_expand = false
						break
			else:
				can_expand = false
			
			if can_expand:
				room.top_height += 1
		Vector2.DOWN: 
			start_line = [room.bottom_left(), room.bottom_right()]
			if room.location.y + room.bottom_height + 1 < height - 1:
				for x in range(room.bottom_left().x, room.bottom_right().x - 1):
					if x == width:
						print(room.top_left(), room.top_right())
					if map[room.top_left().y + 1][x] != 0:
						can_expand = false
						break
			else:
				can_expand = false
			
			if can_expand:
				room.bottom_height += 1
		Vector2.LEFT: 
			start_line = [room.top_left(), room.bottom_left()]
			if room.location.x - room.left_width - 1 >= 0:
				for y in range(room.top_left().y, room.bottom_left().y - 1):
					if y == height:
						print(room.top_left(), room.bottom_left())
					if map[y][room.top_left().x - 1] != 0:
						can_expand = false
						break
			else:
				can_expand = false
			
			if can_expand:
				room.left_width += 1
		Vector2.RIGHT: 
			start_line = [room.top_right(), room.bottom_right()]
			if room.location.x + room.right_width + 1 < width - 1:
				for y in range(room.top_right().y, room.bottom_right().y - 1):
					if y == height - 1:
						print(room.top_right(), room.bottom_right())
					if map[y][room.top_right().x + 1] != 0:
						can_expand = false
						break
			else:
				can_expand = false
			
			if can_expand:
				room.right_width += 1
	
	if can_expand:
		_refresh_map(room)
		room.expansions += 1
	
	return can_expand
	
