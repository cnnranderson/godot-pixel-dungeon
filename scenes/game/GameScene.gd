extends Node2D

@onready var world = $World
@onready var load_splash = $UI/LoadSplash
var tween: Tween

func _ready():
	#Events.connect("map_ready", _start_game) # TODO: Doesn't happen yet
	Events.next_stage.connect(_reload_map)
	$UI/ActionLog.visible = true
	$UI/PlayerUI.visible = true
	$UI/Backpack.visible = false
	$UI/LoadSplash.visible = false
	GameState.world = world
	_reload_map()

func _unhandled_input(event):
	if event.is_action_pressed("cancel") and not GameState.world_generating:
		GameState.world_generating = true
		Events.next_stage.emit()
		
	if event.is_action_pressed("add_key"):
		GameState.player.inventory.keys += 1
		Events.player_interact.emit(Item.Category.KEY)
		Events.log_message.emit("You found a key")
	
	if GameState.is_player_turn:
		if event.is_action_pressed("inventory"):
			Events.open_inventory.emit()
		
		if event.is_action_pressed("search"):
			if not GameState.inventory_open:
				Events.player_search.emit()
		
		if event.is_action_pressed("wait"):
			if not GameState.inventory_open:
				Events.player_wait.emit()

func _reload_map():
	tween = create_tween()
	load_splash.visible = true
	load_splash.modulate.a = 0
	
	# Fade out
	tween.tween_property(load_splash, "modulate:a", 1.0, 1) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	await tween.step_finished
	
	GameState.world.init_world()
	await Events.map_ready
	
	# Fade back in
	tween = create_tween()
	tween.tween_property(load_splash, "modulate:a", 0, 1) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	
	GameState.world_generating = false
	load_splash.visible = false
