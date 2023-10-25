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
const Armors = {
	"cloth": preload("res://prefabs/items/armor/Cloth.tres"),
	"leather": preload("res://prefabs/items/armor/Leather.tres"),
	"chain": preload("res://prefabs/items/armor/Chainmail.tres"),
	"plate": preload("res://prefabs/items/armor/Plate.tres")
}
const Enemies = {
	"bat": preload("res://prefabs/actors/creatures/bat/Bat.tscn")
}

@onready var level: Level = $Level
@onready var visibility_map = $Visibility
@onready var fog_map = $Fog
@onready var items = $Items
@onready var actors = $Actors
@onready var effects = $Effects
@onready var objects = $Objects

var debug = false

func _ready():
	GameState.level = level
	Events.connect("player_acted", _process_actions)

func _process(delta):
	var mouse_pos = get_local_mouse_position()
	var m_tpos = level.local_to_map(mouse_pos)
	if not GameState.inventory_open:
		$Cursor.visible = true
		$Cursor.position = level.map_to_local(m_tpos)
	else:
		$Cursor.visible = false

func init_world():
	_clear_world()
	level.init_level()
	
	if GameState.fog_of_war:
		for x in level.level_size.x:
			for y in level.level_size.y:
				visibility_map.set_cell(1, Vector2i(x, y), 0)
				fog_map.set_cell(1, Vector2i(x, y), 0)
	else:
		visibility_map.visible = false
		fog_map.visible = false
	
	_init_player()
	_generate_test_entities()
	
	await get_tree().create_timer(0.1).timeout
	Events.map_ready.emit()
	_update_visuals()
	_process_actions()

func _init_player():
	var player = Player.instantiate()
	GameState.hero = player
	GameState.hero.position = level.map_to_local(level.spawn)
	$Actors.add_child(GameState.hero)
	GameState.is_player_turn = true

func _update_visuals():
	if debug: print("Updating FoV")
	if not GameState.fog_of_war: return
	
	var space_state = get_world_2d().direct_space_state
	var min_bound = GameState.hero.tpos() - Vector2i.ONE * (GameState.player.fov + 2)
	var max_bound = GameState.hero.tpos() + Vector2i.ONE * (GameState.player.fov + 2)
	for x in range(max(min_bound.x, 0), min(max_bound.x, level.level_size.x)):
		for y in range(max(min_bound.y, 0), min(max_bound.y, level.level_size.y)):
			var x_dir = 1 if x < GameState.hero.tpos().x else -1
			var y_dir = 1 if y < GameState.hero.tpos().y else -1
			var test_point = Helpers.tile_to_world(Vector2i(x, y)) + Vector2(x_dir, y_dir) * Constants.TILE_V / 2
			
			var params = PhysicsRayQueryParameters2D.create(GameState.hero.position, test_point)
			
			var occlusion = space_state.intersect_ray(params)
			if not occlusion or (occlusion.position - test_point).length() < 1:
				if (GameState.hero.position - test_point).length() / Constants.TILE_SIZE < GameState.player.fov:
					# Reveal if it's within FoV
					visibility_map.set_cell(0, Vector2i(x, y), -1)
					
					# Also punch a hole in overall fog map
					fog_map.set_cell(0, Vector2i(x, y), -1)
					_reveal_entities(x, y)
				else:
					# Hide again if not within FoV
					visibility_map.set_cell(0, Vector2i(x, y), 0)
					_reveal_entities(x, y, false)
			else:
				# Hide if no collision in general
				visibility_map.set_cell(0, Vector2i(x, y), 0)
				_reveal_entities(x, y, false)

func _reveal_entities(x, y, reveal: bool = true):
	var tpos = Vector2i(x, y)
	for item in items.get_children():
		if Helpers.world_to_tile(item.position) == tpos:
			item.visible = reveal
			break
	
	for actor in actors.get_children():
		if actor != GameState.hero:
			if actor.tpos() == tpos:
				actor.visible = reveal
				break

func _clear_world():
	Helpers.delete_children(items)
	Helpers.delete_children(actors)
	Helpers.delete_children(effects)
	Helpers.delete_children(objects)

func get_actor_at_tpos(tpos: Vector2i) -> Actor:
	for actor in $Actors.get_children():
		if actor.tpos() == tpos:
			return actor
	return null

func _process_actions():
	var actors = $Actors.get_children()
	actors.sort_custom(actor_priority_sort)
	var lowest_time = actors[0].act_time
	
	var attacked = false
	var hero_acted = false
	for actor in actors:
		if actor.act_time == lowest_time:
			var action = actor.act()
			
			# If the hero acted, make note; otherwise it just became the hero's turn
			if actor == GameState.hero:
				if action and action.cost > 0:
					hero_acted = true
				else:
					GameState.is_player_turn = true
					break
			
			# If an actor attacks, let animation finish before other actors move
			if action and action.type == Action.ActionType.ATTACK:
				attacked = true
				break
		elif actor == GameState.hero and GameState.hero.act_time != lowest_time:
			hero_acted = true
	
	# FIXME: this is still dumb and cause turn sync issues
	if attacked:
		await get_tree().create_timer(Actor.ATTACK_TIME + 0.05).timeout
	else:
		await get_tree().create_timer(Actor.MOVE_TIME + 0.05).timeout
	if hero_acted or attacked:
		_update_visuals()
		_process_actions()

"""
Sorts actors by their act time. Actors who have the lowest act time
should move first, and continue doing so until they catch up to other actors.
"""
static func actor_priority_sort(a: Actor, b: Actor):
	return a.act_time < b.act_time or (a == GameState.hero and a.act_time == b.act_time)


### TEST UTILITIES
func _generate_test_entities():
	#_generate_test_keys()
	#_generate_test_coins()
	#_generate_test_scrolls()
	#_generate_test_weapons()
	#_generate_test_armor()
	_generate_test_enemies()

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
		spawn_scroll(Scrolls.values()[1], tpos) #randi() % Scrolls.size()], tpos)

func _generate_test_weapons():
	var weapon_pos = level.items.weapon_spawns
	for tpos in weapon_pos:
		spawn_weapon(Weapons.values()[randi() % Weapons.size()], tpos)

func _generate_test_armor():
	var armor_pos = level.items.armor_spawns
	for tpos in armor_pos:
		spawn_armor(Armors.values()[randi() % Armors.size()], tpos)

func _generate_test_enemies():
	var enemy_pos = level.enemies
	for tpos in enemy_pos:
		var bat = Enemies.bat.instantiate()
		bat.position = level.map_to_local(tpos)
		$Actors.add_child(bat)
		level.occupy_tile(tpos)

# TODO: For these utility functions, see if they can be combined.
# They're only separated in case special stuff needs to happen between types.
func spawn_basic_item(item: Resource, count: int, tpos: Vector2):
	var world_item = WorldItem.instantiate()
	world_item.item = item
	world_item.count = count
	world_item.position = level.map_to_local(tpos)
	$Items.add_child(world_item)

func spawn_scroll(scroll: Resource, tpos: Vector2):
	var world_item = WorldItem.instantiate()
	world_item.item = scroll
	world_item.position = level.map_to_local(tpos)
	$Items.add_child(world_item)

func spawn_weapon(weapon: Resource, tpos: Vector2):
	var world_item = WorldItem.instantiate()
	world_item.item = weapon
	world_item.position = level.map_to_local(tpos)
	$Items.add_child(world_item)

func spawn_armor(armor: Resource, tpos: Vector2):
	var world_item = WorldItem.instantiate()
	world_item.item = armor
	world_item.position = level.map_to_local(tpos)
	$Items.add_child(world_item)

