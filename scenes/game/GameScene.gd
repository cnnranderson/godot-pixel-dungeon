extends Node2D

onready var world = $World

func _ready():
	Events.connect("map_ready", $UI/PlayerUI, "_init_stats")
	Events.connect("map_ready", self, "_start_game")
	$UI/ActionLog.visible = true
	$UI/PlayerUI.visible = true
	GameState.world = world
	GameState.world.init_world()

func _start_game():
	pass

func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		Events.emit_signal("camera_shake", 0.3, 0.5)
		GameState.level.reset_doors()
	
	if event.is_action_pressed("add_key"):
		GameState.player.inventory.keys += 1
		Events.emit_signal("player_interact", Item.Category.KEY)
		Events.emit_signal("log_message", "You found a key")
	
	if GameState.is_player_turn:
		if event.is_action_pressed("inventory"):
			Events.emit_signal("open_inventory")
		
		if event.is_action_pressed("search"):
			if not GameState.inventory_open:
				Events.emit_signal("player_search")
		
		if event.is_action_pressed("wait"):
			if not GameState.inventory_open:
				Events.emit_signal("player_wait")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and false:
			#player.travel_path = GameState.world.get_travel_path(
			#	Helpers.world_to_tile(player.global_position), 
			#	Helpers.world_to_tile(get_local_mouse_position()))
			pass
