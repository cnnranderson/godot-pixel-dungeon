extends Node

enum Scenes { START_MENU, GAME }
enum Colors { BLUE, BROWN, RED, YELLOW, WHITE }

const SceneMap = {
	Scenes.START_MENU: "res://scenes/start/StartScene.tscn",
	Scenes.GAME: "res://scenes/game/GameScene.tscn"
}

const ColorPalette = {
	Colors.BLUE: Color(20, 119, 114),
	Colors.BROWN: Color(81, 71, 46),
	Colors.RED: Color(215, 73, 35),
	Colors.YELLOW: Color(239, 166, 28),
	Colors.WHITE: Color(239, 239, 233)
}

var main : Main = null
var debug = true

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(_delta):
	if debug:
		if Input.is_action_pressed("debug_quit"):
			get_tree().quit()
