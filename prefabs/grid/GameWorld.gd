extends Node2D
class_name GameWorld

const SOUND = {
	"door": "res://assets/pd_import/sounds/snd_door_open.mp3"
}

onready var level = $Level
var spawn = Vector2(5, 5)

func _ready():
	pass

func _init_world():
	GameState.level = level
	Events.emit_signal("map_ready", spawn)
	pass

func _process(delta):
	var mouse_pos = get_local_mouse_position()

	if level.get_cellv(level.world_to_map(mouse_pos)) != TileMap.INVALID_CELL:
		$Cursor.visible = true
		$Cursor.position = level.map_to_world(level.world_to_map(mouse_pos))
	else:
		$Cursor.visible = false
	pass
