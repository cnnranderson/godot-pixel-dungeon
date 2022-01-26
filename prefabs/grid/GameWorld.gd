extends Node2D
class_name GameWorld

const Player = preload("res://prefabs/actors/player/Player.tscn")
const WorldItem = preload("res://prefabs/items/WorldItem.tscn")
const Items = {
	"key": preload("res://prefabs/items/basic/Key.tres"),
	"coins": preload("res://prefabs/items/basic/Coins.tres")
}
const Scrolls = {
	"healing": preload("res://prefabs/items/scrolls/HealingScroll.tres"),
	"teleport": preload("res://prefabs/items/scrolls/TeleportScroll.tres")
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
onready var visibility_map = $Visibility
onready var items = $Items
onready var actors = $Actors
onready var effects = $Effects
onready var objects = $Objects

func _ready():
	GameState.level = level
	Events.connect("player_acted", self, "_process_actions")

func _process(delta):
	var mouse_pos = get_local_mouse_position()
	var m_tpos = level.world_to_map(mouse_pos)
	var tile = level.get_cellv(m_tpos)
	if tile != TileMap.INVALID_CELL and not GameState.inventory_open:
		$Cursor.visible = true
		$Cursor.position = level.map_to_world(level.world_to_map(mouse_pos))
	else:
		$Cursor.visible = false

func init_world():
	_clear_world()
	level.init_level()
	_init_player()
	_generate_test_entities()
	
	yield(get_tree().create_timer(0.1), "timeout")
	Events.emit_signal("map_ready")
	_process_actions()

func _clear_world():
	Helpers.delete_children(items)
	Helpers.delete_children(actors)
	Helpers.delete_children(effects)
	Helpers.delete_children(objects)

func _init_player():
	var player = Player.instance()
	player.position = level.map_to_world(level.spawn) + Vector2(8, 8)
	GameState.hero = player
	$Actors.add_child(player)
	GameState.is_player_turn = true

func get_actor_at_tpos(tpos: Vector2) -> Actor:
	for actor in $Actors.get_children():
		if actor.tpos() == tpos:
			return actor
	return null

func _process_actions():
	var actors = $Actors.get_children()
	actors.sort_custom(self, "actor_priority_sort")
	var lowest_time = actors[0].act_time
	
	var attacked = false
	if lowest_time == GameState.hero.act_time:
		# Player can now take a turn
		print("player acting")
		GameState.is_player_turn = true
		if GameState.hero.action_queue.size() > 0:
			if actors.size() == 1: # TODO Fix this by normalizing when wait times are scheduled
				yield(get_tree().create_timer(Actor.MOVE_TIME), "timeout")
			GameState.hero.act()
	else:
		# Enemies take turns
		print("enemies acting")
		for actor in actors:
			if actor.act_time == lowest_time:
				var action = actor.act()
				
				# If an actor attacks, it should let the animation finish before actors move
				if action and action.type == Action.ActionType.ATTACK:
					attacked = true
					break
		
		if attacked:
			yield(get_tree().create_timer(Actor.ATTACK_TIME), "timeout")
			_process_actions()
		else:
			yield(get_tree().create_timer(Actor.MOVE_TIME), "timeout")
			_process_actions()

"""
Sorts actors by their act time. Actors who have the lowest act time
should move first, and continue doing so until they catch up to other actors.
"""
static func actor_priority_sort(a: Actor, b: Actor):
	return a.act_time < b.act_time

### TEST UTILITIES
func _generate_test_entities():
	_generate_test_keys()
	_generate_test_coins()
	_generate_test_scrolls()
	_generate_test_weapons()
	_generate_test_enemies()
	pass

func _generate_test_keys():
	var key_pos = level.items.key_spawns
	for tpos in key_pos:
		spawn_basic_item(Items.key, 1, tpos)

func _generate_test_coins():
	var coin_pos = level.items.coin_spawns
	for tpos in coin_pos:
		spawn_basic_item(Items.coins, randi() % 100 + 10, tpos)

func _generate_test_scrolls():
	var scroll_pos = level.items.scroll_spawns
	for tpos in scroll_pos:
		spawn_scroll(Scrolls.values()[randi() % Scrolls.size()], tpos)

func _generate_test_weapons():
	var weapon_pos = level.items.weapon_spawns
	for tpos in weapon_pos:
		spawn_weapon(Weapons.values()[randi() % Weapons.size()], tpos)

func _generate_test_enemies():
	var enemy_pos = level.enemies
	for tpos in enemy_pos:
		var bat = Enemies.bat.instance()
		bat.position = level.map_to_world(tpos)
		$Actors.add_child(bat)
		level.occupy_tile(tpos)

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

