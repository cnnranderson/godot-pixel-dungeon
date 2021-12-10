class_name MapGenerator

var map = []
var width = 60
var height = 60

var floor_num = 0
var room_count = 4

func generate_map():
	map = _init_map()
	_build_room()
	return map

# Initialize an empty map
func _init_map() -> Array:
	var matrix = []
	for x in range(width):
		matrix.append([])
		for y in range(height):
			matrix[x].append(1)
	return matrix

func _build_room():
	for x in range(width):
		map[x][0] = 2
		map[x][height - 1] = 2
	for y in range(height):
		map[0][y] = 2
		map[width - 1][y] = 2
	pass

	
