extends Node2D
class_name Grid

const SOUND = {
	"door": "res://assets/pd_import/sounds/snd_door_open.mp3"
}

const TILE = {
	"ground": Vector2(1, 0),
	"wall": Vector2(2, 0),
	"door_closed": Vector2(5, 0),
	"door_open": Vector2(6, 0)
}

onready var tilemap : TileMap = $TileMap
onready var astar = AStar2D.new()
onready var used_cells = tilemap.get_used_cells()
var path: PoolVector2Array

func _ready():
	_add_points()
	_connect_points()

func _add_points():
	for cell in used_cells:
		var cellType = get_cell(cell)
		match cellType:
			TILE.door_open, TILE.door_closed, TILE.ground:
				astar.add_point(id(cell), cell, 1.0)
		
func _connect_points():
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

func reset_doors():
	var tiles = tilemap.get_used_cells()
	for tile in tiles:
		if get_cell(tile) == TILE.door_open:
			close_door(tile)
	pass

func open_door(tpos: Vector2):
	if get_cell(tpos) == TILE.door_closed:
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.door)
		set_cell(tpos, TILE.door_open)

func close_door(tpos: Vector2):
	if get_cell(tpos) == TILE.door_open:
		Sounds.play_sound(Sounds.SoundType.SFX, SOUND.door)
		set_cell(tpos, TILE.door_closed)

func get_cell(tpos: Vector2):
	return tilemap.get_cell_autotile_coord(tpos.x, tpos.y)

func set_cell(tpos: Vector2, tile: Vector2):
	tilemap.set_cell(tpos.x, tpos.y, 0, false, false, false, tile)
