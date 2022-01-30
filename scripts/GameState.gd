extends Node

# ======= GAME MECHANICS ==========
var is_player_turn = false
var inventory_open = false

# ======= GAME SETTINGS  ==========
var fog_of_war = false
var enemies_start_awake = false
var auto_pickup = true
var free_auto_pickup = true
var guaranteed_player_hit = true

# =======   STATE VARS   ==========
var hero: Actor = null
var world: GameWorld = null
var level: Level = null
var player = {
	"fov": 7,
	"inventory": {
		"keys": 0,
		"coins": 0,
		"max_size": 12
	},
	"backpack": Inventory.new(),
	"equipped": {
		"weapon": null,
		"armor": null
	},
	"stats": {
		"xp": 0,
		"xp_next": 10,
		"level": 1,
		"max_hp": 20,
		"hp": 20,
		"str": 1,
		"ac": 1,
		"dex": 1
	}
}

var discovered_scrolls = []
var discovered_potions = []

func _ready():
	player.backpack.set_backpack_size(GameState.player.inventory.max_size)
	# TODO: Load stats and stuff here..?

