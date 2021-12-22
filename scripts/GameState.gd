extends Node

var turn_list = []
var player_turn = true
var camera: GameCam = null
var world: GameWorld = null
var level: Level = null
var inventory_open = false
var inventory: Inventory = Inventory.new()
var player = {
	"inventory": {
		"keys": 0,
		"coins": 0,
		"max_size": 12
	},
	"equipped": {
		"weapon": null,
		"armor": null
	},
	"stats": {
		"xp": 0,
		"xp_next": 100,
		"level": 1,
		"hp": 100,
		"hp_max": 100
	}
}

func _ready():
	inventory.set_backpack_size(GameState.player.inventory.max_size)

func is_player_turn():
	return turn_list

func shake(amount, decay):
	if not camera: return
	camera.add_trauma(amount, decay)
