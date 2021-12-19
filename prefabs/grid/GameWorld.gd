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
