extends Node2D
class_name GameWorld

const Player = preload("res://prefabs/actors/player/Player.tscn")
const WorldItem = preload("res://prefabs/items/WorldItem.tscn")
const Enemies = {
	"bat": preload("res://prefabs/actors/bat/Bat.tscn")
}
const Items = {
	"key": preload("res://prefabs/items/basic/Key.tres"),
	"coins": preload("res://prefabs/items/basic/Coins.tres")
}
const Scrolls = {
	"healing": preload("res://prefabs/items/scrolls/HealingScroll.tres")
}

onready var level = $Level

var awake_enemies = []
var active = false
var spawn = Vector2(5, 5)

func _ready():
	Events.connect("player_acted", self, "_on_player_acted")
	Events.connect("enemies_acted", self, "_on_enemies_acted")

func _input(delta):
	var mouse_pos = get_local_mouse_position()
	if level.get_cellv(level.world_to_map(mouse_pos)) != TileMap.INVALID_CELL \
			and not GameState.inventory_open:
		$Cursor.visible = true
		$Cursor.position = level.map_to_world(level.world_to_map(mouse_pos))
	else:
		$Cursor.visible = false

func init_world():
	GameState.level = level
	_init_player()
	_generate_test_entities()
	Events.emit_signal("map_ready")
	active = true

func _init_player():
	var actor = Player.instance()
	actor.position = level.map_to_world(spawn) + Vector2(8, 8)
	actor.turn_acc = Constants.BASE_ACTION_COST
	GameState.player.actor = actor
	$Actors.add_child(actor)

func _on_player_acted():
	for enemy in awake_enemies:
		if is_instance_valid(enemy):
			enemy.act()
	Events.emit_signal("enemies_acted")

func _on_enemies_acted():
	GameState.player.actor.turn_acc = Constants.BASE_ACTION_COST

### TEST UTILITIES
func _generate_test_entities():
	_generate_test_keys()
	_generate_test_coins()
	_generate_test_scrolls()
	_generate_test_enemies()

func _generate_test_keys():
	var key_pos = [
		Vector2(3, 3)
	]
	for pos in key_pos:
		var key = WorldItem.instance()
		key.item = Items.key
		key.count = 1
		key.position = level.map_to_world(pos)
		$Items.add_child(key)

func _generate_test_coins():
	var coin_pos = [
		Vector2(2, 2),
		Vector2(7, 7),
		Vector2(10, 7),
	]
	
	for pos in coin_pos:
		var coins = WorldItem.instance()
		coins.item = Items.coins
		coins.count = randi() % 100 + 10
		coins.position = level.map_to_world(pos)
		$Items.add_child(coins)

func _generate_test_scrolls():
	var scroll_pos = [
		Vector2(0, 1),
	]
	
	for pos in scroll_pos:
		var scroll = WorldItem.instance()
		scroll.item = Scrolls.healing
		scroll.position = level.map_to_world(pos)
		$Items.add_child(scroll)
		pass
	pass

func _generate_test_enemies():
	var enemy_pos = [
		Vector2(-1, -1),
		Vector2(10, 12),
		Vector2(-5, 1),
	]
	
	for pos in enemy_pos:
		var bat = Enemies.bat.instance()
		bat.position = level.map_to_world(pos)
		bat.is_awake = true
		awake_enemies.append(bat)
		$Actors.add_child(bat)
