extends Node2D
class_name GameWorld

const Player = preload("res://prefabs/actors/player/Player.tscn")
const WorldItem = preload("res://prefabs/items/WorldItem.tscn")
const Items = {
	"key": preload("res://prefabs/items/basic/Key.tres"),
	"coins": preload("res://prefabs/items/basic/Coins.tres"),
	"healing_scroll": preload("res://prefabs/items/scrolls/HealingScroll.tres")
}

onready var level = $Level

var active = false
var spawn = Vector2(5, 5)

func _ready():
	pass

func init_world():
	GameState.level = level
	_init_player()
	_generate_test_items()
	Events.emit_signal("map_ready")
	active = true

func _init_player():
	var actor = Player.instance()
	actor.position = level.map_to_world(spawn) + Vector2(8, 8)
	GameState.player.actor = actor
	$Actors.add_child(actor)

func _input(delta):
	var mouse_pos = get_local_mouse_position()
	if level.get_cellv(level.world_to_map(mouse_pos)) != TileMap.INVALID_CELL \
			and GameState.player_turn \
			and not GameState.inventory_open:
		$Cursor.visible = true
		$Cursor.position = level.map_to_world(level.world_to_map(mouse_pos))
	else:
		$Cursor.visible = false

# TODO: Remove this once generation is done -- these are just test items
func _generate_test_items():
	var gold_places = [
		Vector2(2, 2),
		Vector2(7, 7),
		Vector2(10, 7),
	]
	
	for gold_loc in gold_places:
		var coins = WorldItem.instance()
		coins.item = Items.coins
		coins.count = randi() % 100 + 10
		coins.position = level.map_to_world(gold_loc)
		$Items.add_child(coins)
	
	var key = WorldItem.instance()
	key.item = Items.key
	key.count = 1
	key.position = GameState.level.map_to_world(Vector2(3, 3))
	$Items.add_child(key)

func _generate_test_keys():
	pass

func _generate_test_coins():
	pass

func _generate_test_scrolls():
	pass

func _generate_test_enemies():
	pass
