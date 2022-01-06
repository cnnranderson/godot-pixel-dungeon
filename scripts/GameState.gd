extends Node

var actors = []
var player_turn = true
var camera: GameCam = null
var world: GameWorld = null
var level: Level = null
var inventory_open = false
var player_actor: Actor = null
var player = {
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
		"xp_next": 100,
		"level": 1,
		"max_hp": 20
	}
}

var discovered_scrolls = []

func _ready():
	player.backpack.set_backpack_size(GameState.player.inventory.max_size)
	Events.connect("player_acted", self, "_on_player_acted")
	Events.connect("enemies_acted", self, "_on_enemies_acted")

func is_player_turn():
	return actors[0] is Player

func shake(amount, decay):
	if not camera: return
	camera.add_trauma(amount, decay)

func _on_player_acted():
	player_turn = false
	for actor in actors:
		if is_instance_valid(actor) and not actor is Player:
			actor.act()
	Events.emit_signal("enemies_acted")

func _on_enemies_acted():
	player_turn = true
