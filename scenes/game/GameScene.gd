extends Node2D

onready var world = $World
onready var tween = $Tween
onready var load_splash = $UI/LoadSplash

func _ready():
	Events.connect("map_ready", $UI/PlayerUI, "_init_stats")
	Events.connect("map_ready", self, "_start_game")
	Events.connect("next_stage", self, "_reload_map")
	$UI/ActionLog.visible = true
	$UI/PlayerUI.visible = true
	GameState.world = world
	_reload_map()

func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		Events.emit_signal("next_stage")
	
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

func _reload_map():
	load_splash.visible = true
	load_splash.modulate.a = 0
	tween.interpolate_property(load_splash, "modulate:a", 0, 1.0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(1.0), "timeout")
	GameState.world.init_world()
	yield(Events, "map_ready")
	tween.interpolate_property(load_splash, "modulate:a", 1.0, 0, 1.0, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	load_splash.visible = false
