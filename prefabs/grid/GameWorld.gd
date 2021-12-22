extends Node2D
class_name GameWorld

const SOUND = {
	"door": "res://assets/pd_import/sounds/snd_door_open.mp3"
}

const WorldItem = preload("res://prefabs/items/WorldItem.tscn")
const Key = preload("res://prefabs/items/basic/Key.tres")
const Coins = preload("res://prefabs/items/basic/Coins.tres")

onready var level = $Level
var spawn = Vector2(5, 5)

func _ready():
	pass

func init_world():
	GameState.level = level
	_generate_test_items()
	Events.emit_signal("map_ready", spawn)

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
		Vector2(7, 7),
		Vector2(10, 7),
		Vector2(22, 14),
		Vector2(2, 2),
	]
	for gold_loc in gold_places:
		var coins = WorldItem.instance()
		coins.item = Coins
		coins.count = randi() % 100 + 10
		coins.position = level.map_to_world(gold_loc)
		$Items.add_child(coins)
	
	var key = WorldItem.instance()
	key.item = Key
	key.count = 1
	key.position = GameState.level.map_to_world(Vector2(3, 3))
	$Items.add_child(key)
