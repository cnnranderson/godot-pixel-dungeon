extends Node2D
class_name GameWorld

const SOUND = {
	"door": "res://assets/pd_import/sounds/snd_door_open.mp3"
}

const TILE = {
	"empty": Vector2(0, 0),
	"ground": Vector2(1, 0),
	"wall": Vector2(4, 0),
	"door_closed": Vector2(5, 0),
	"door_open": Vector2(6, 0)
}

onready var level = $Level
onready var astar = AStar2D.new()

var path: PoolVector2Array
var map: Array = []
var spawn = Vector2(5, 5)
var map_generator = MapGenerator.new()

func _ready():
	#map = map_generator.generate_map()
	pass

func _init_world():
	$Level.new_gen()
	_add_points()
	_connect_points()
	Events.emit_signal("map_ready", spawn)
	pass

func _add_points():
	for cell in level.get_used_cells():
		var cell_type = level._get_cell(cell)
		match cell_type:
			TILE.door_open, TILE.door_closed, TILE.ground:
				astar.add_point(id(cell), cell, 1.0)
		
func _connect_points():
	var used_cells = level.get_used_cells()
	for cell in used_cells:
		var neighbors = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
		for neighbor in neighbors:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell), id(next_cell), false)

func get_travel_path(start, end):
	path = astar.get_point_path(id(start), id(end))
	path.remove(0)
	return path

func id(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b


