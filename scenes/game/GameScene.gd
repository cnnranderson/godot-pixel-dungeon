extends Node2D

onready var camera = $Player/Camera
onready var player = $Player
onready var world = $World

var Key = preload("res://prefabs/items/Key.tscn")
var Gold = preload("res://prefabs/items/Gold.tscn")

func _ready():
	GameState.camera = camera
	GameState.world = world
	
	Events.connect("map_ready", player, "_init_character")
	GameState.world._init_world()
	var gold_places = [
		Vector2(7, 7),
		Vector2(10, 7),
		Vector2(22, 14),
		Vector2(2, 2),
	]
	for gold_loc in gold_places:
		var gold = Gold.instance()
		gold.get_child(0).count = randi() % 100 + 10
		gold.position = GameState.level.map_to_world(gold_loc)
		$Items.add_child(gold)
	
	var key = Key.instance()
	key.get_child(0).count = 1
	key.position = GameState.level.map_to_world(Vector2(3, 3))
	$Items.add_child(key)
	
func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		GameState.shake(0.3, 0.5)
		GameState.level.reset_doors()
	
	if event.is_action_pressed("add_key"):
		GameState.player.inventory.keys += 1
		Events.emit_signal("player_interact", Constants.Item.KEY)
		Events.emit_signal("log_message", "You found a key")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and false:
			player.travel_path = GameState.world.get_travel_path(
				Helpers.world_to_tile(player.global_position), 
				Helpers.world_to_tile(get_local_mouse_position()))
			pass

