extends Node2D

onready var camera = $Player/Camera
onready var player = $Player
onready var world = $World

func _ready():
	$UI/ActionLog.visible = true
	$UI/PlayerUI.visible = true
	GameState.camera = camera
	GameState.world = world
	GameState.player_actor = player
	
	Events.connect("map_ready", player, "_init_character")
	Events.connect("map_ready", $UI/PlayerUI, "_init_stats")
	GameState.world.init_world()
	GameState.actors.append(player)
	GameState.actors.append($Bat)
	GameState.actors.append($Bat2)

func _process(delta):
	if not player.can_act():
		player.charge_time()

func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		GameState.shake(0.3, 0.5)
		GameState.level.reset_doors()
	
	if event.is_action_pressed("add_key"):
		GameState.player.inventory.keys += 1
		Events.emit_signal("player_interact", Item.Category.KEY)
		Events.emit_signal("log_message", "You found a key")
	
	if GameState.player_turn:
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
			player.travel_path = GameState.world.get_travel_path(
				Helpers.world_to_tile(player.global_position), 
				Helpers.world_to_tile(get_local_mouse_position()))
			pass
