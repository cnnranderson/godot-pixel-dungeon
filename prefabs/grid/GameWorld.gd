extends Node2D
class_name GameWorld

const Player = preload("res://prefabs/actors/player/Player.tscn")
const WorldItem = preload("res://prefabs/items/WorldItem.tscn")
const Items = {
	"key": preload("res://prefabs/items/basic/Key.tres"),
	"coins": preload("res://prefabs/items/basic/Coins.tres")
}
const Scrolls = {
	"healing": preload("res://prefabs/items/scrolls/HealingScroll.tres")
}
const Weapons = {
	"axe": preload("res://prefabs/items/weapons/Axe.tres"),
	"broadsword": preload("res://prefabs/items/weapons/Broadsword.tres"),
	"dagger": preload("res://prefabs/items/weapons/Dagger.tres"),
	"shortsword": preload("res://prefabs/items/weapons/Shortsword.tres"),
	"staff": preload("res://prefabs/items/weapons/Staff.tres")
}
const Enemies = {
	"bat": preload("res://prefabs/actors/bat/Bat.tscn")
}

onready var level = $Level

# TODO: Resolve how spawn location gets setup
var spawn = Vector2(3, 3)

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

func _init_player():
	var player = Player.instance()
	player.position = level.map_to_world(spawn) + Vector2(8, 8)
	GameState.hero = player
	$Actors.add_child(player)
	GameState.is_player_turn = true

func _on_player_acted():
	GameState.is_player_turn = false
	var chosen_actor = null
	while chosen_actor != GameState.hero:
		for actor in $Actors.get_children():
			if actor.is_awake or actor.should_wake:
				if chosen_actor == null or actor.act_time <= chosen_actor.act_time:
					chosen_actor = actor
		
		if chosen_actor.mob:
			chosen_actor.act()
			yield(get_tree().create_timer(0.05), "timeout")
	GameState.is_player_turn = true

### TEST UTILITIES
func _generate_test_entities():
	_generate_test_keys()
	_generate_test_coins()
	_generate_test_scrolls()
	_generate_test_weapons()
	_generate_test_enemies()

func _generate_test_keys():
	var key_pos = [
		Vector2(3, 4)
	]
	
	for tpos in key_pos:
		spawn_basic_item(Items.key, 1, tpos)

func _generate_test_coins():
	var coin_pos = [
		Vector2(2, 2),
		Vector2(7, 7),
		Vector2(10, 7),
	]
	
	for tpos in coin_pos:
		spawn_basic_item(Items.coins, randi() % 100 + 10, tpos)

func _generate_test_scrolls():
	var scroll_pos = [
		Vector2(0, 1),
	]
	
	for tpos in scroll_pos:
		spawn_scroll(Scrolls.healing, tpos)

func _generate_test_weapons():
	var weapon_pos = [
		Vector2(5, 8)
	]
	
	for tpos in weapon_pos:
		spawn_weapon(Weapons.values()[randi() % Weapons.size()], tpos)

func _generate_test_enemies():
	var enemy_pos = [
		Vector2(-1, -1),
		Vector2(10, 12),
		Vector2(-5, 1),
	]
	
	for tpos in enemy_pos:
		var bat = Enemies.bat.instance()
		bat.position = level.map_to_world(tpos)
		$Actors.add_child(bat)

# TODO: For these utility functions, see if they can be combined.
# They're only separated in case special stuff needs to happen between types.
func spawn_basic_item(item: Resource, count: int, tpos: Vector2):
	var world_item = WorldItem.instance()
	world_item.item = item
	world_item.count = count
	world_item.position = level.map_to_world(tpos)
	$Items.add_child(world_item)

func spawn_scroll(scroll: Resource, tpos: Vector2):
	var world_item = WorldItem.instance()
	world_item.item = scroll
	world_item.position = level.map_to_world(tpos)
	$Items.add_child(world_item)

func spawn_weapon(weapon: Resource, tpos: Vector2):
	var world_item = WorldItem.instance()
	world_item.item = weapon
	world_item.position = level.map_to_world(tpos)
	$Items.add_child(world_item)

func spawn_armor(armor: Resource, tpos: Vector2):
	pass

static func actor_priority(a: Actor, b: Actor) -> bool:
	return a.act_time < b.act_time
