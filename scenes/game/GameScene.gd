extends Node2D

onready var camera = $Player/Camera
onready var player = $Player
onready var world = $World

func _ready():
	$UI/ActionLog.visible = true
	$UI/PlayerUI.visible = true
	GameState.camera = camera
	GameState.world = world
	
	Events.connect("map_ready", player, "_init_character")
	GameState.world.init_world()

func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		GameState.shake(0.3, 0.5)
		GameState.level.reset_doors()
	
	if event.is_action_pressed("add_key"):
		GameState.player.inventory.keys += 1
		Events.emit_signal("player_interact", Item.Type.KEY)
		Events.emit_signal("log_message", "You found a key")
	
	if event.is_action_pressed("add_key"):
		GameState.player.inventory.keys += 1
		Events.emit_signal("player_interact", Item.Type.KEY)
		Events.emit_signal("log_message", "You found a key")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and false:
			player.travel_path = GameState.world.get_travel_path(
				Helpers.world_to_tile(player.global_position), 
				Helpers.world_to_tile(get_local_mouse_position()))
			pass

