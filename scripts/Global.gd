extends Node

# Give all game scenes a key mapping to easily request scenes to be loaded
enum Scenes { START_MENU, GAME }

# Constants
const TILE_SIZE = 16
const TILE_V = Vector2.ONE * TILE_SIZE
const INPUTS = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN
}

# Put all game scenes here
const SceneMap = {
	Scenes.START_MENU: "res://scenes/start/StartScene.tscn",
	Scenes.GAME: "res://scenes/game/GameScene.tscn"
}

var main : Main = null
var debug = true

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(_delta):
	if debug:
		# Close the game if the ESCAPE key is pressed
		if Input.is_action_pressed("ui_cancel"):
			get_tree().quit()
