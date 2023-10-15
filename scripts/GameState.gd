extends Node

# ======= GAME MECHANICS ==========
var is_player_turn = false
var inventory_open = false
var world_generating = false

# ======= GAME SETTINGS  ==========
var fog_of_war = true
var enemies_start_awake = true
var auto_pickup = true
var free_auto_pickup = true
var player_guaranteed_hit = true
var player_guaranteed_miss = false
var player_any_dist_hit = true # Attack at any distance

# =======   STATE VARS   ==========
var hero: Actor
var world: GameWorld
var level: Level
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

