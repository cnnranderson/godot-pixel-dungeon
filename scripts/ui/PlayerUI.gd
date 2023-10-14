extends Control

# Stats
@onready var lvl = $VBox/Panel/HBox/Stats/Vbox/Level/Label
@onready var hp = $VBox/Panel/HBox/Stats/Vbox/Hp/Bar
@onready var xp = $VBox/Panel/HBox/Stats/Vbox/Xp/Bar
@onready var keys = $VBox/Panel/HBox/Items/Vbox/Keys/Count
@onready var coins = $VBox/Panel/HBox/Items/Vbox/Coins/Count
@onready var depth = $VBox/Panel/HBox/Stats/Vbox/Level/Floor/Label

# Actions
@onready var backpack = $VBox/Hbox/Backpack/Button
@onready var search = $VBox/Hbox/Search/Button
@onready var wait = $VBox/Hbox/Wait/Button
@onready var continue_box = $VBox/Hbox/Continue
@onready var continue_queue = $VBox/Hbox/Continue/Button

# Indicators/Effects
@onready var wait_indicator = $VBox/Wait/Container

var waiting = false

func _ready():
	Events.connect("player_interact", Callable(self, "_on_player_interact"))
	Events.connect("player_gain_xp", Callable(self, "_on_player_gain_xp"))
	Events.connect("player_hit", Callable(self, "_on_player_hit"))
	Events.connect("player_interrupted", Callable(self, "_on_player_interrupted"))
	backpack.connect("pressed", Callable(self, "_on_backpack_pressed"))
	search.connect("pressed", Callable(self, "_on_search_pressed"))
	wait.connect("pressed", Callable(self, "_on_wait_pressed"))
	continue_queue.connect("pressed", Callable(self, "_on_continue_pressed"))

func _init_stats():
	lvl.text = "Lv: %d" % GameState.player.stats.level
	hp.max_value = GameState.hero.max_hp
	hp.value = GameState.hero.hp
	xp.value = GameState.player.stats.xp
	xp.max_value = GameState.player.stats.xp_next

func _process(delta):
	if not GameState.is_player_turn:
		wait_indicator.set_rotation(wait_indicator.get_rotation() + deg_to_rad(10 + 360 * delta))

### Player Events
func _on_player_interrupted():
	continue_box.visible = not GameState.hero.interrupted_actions.is_empty()

func _on_player_interact(item):
	match (item):
		Item.Category.KEY: keys.text = str(GameState.player.inventory.keys)
		Item.Category.COINS: coins.text = str(GameState.player.inventory.coins)

func _on_player_gain_xp():
	lvl.text = "Lv: %d" % GameState.player.stats.level
	hp.value = GameState.hero.hp
	hp.max_value = GameState.hero.max_hp
	xp.value = GameState.player.stats.xp
	xp.max_value = GameState.player.stats.xp_next

func _on_player_hit():
	hp.value = GameState.hero.hp

### Action Events
func _on_backpack_pressed():
	Events.emit_signal("open_inventory")

func _on_search_pressed():
	if not GameState.inventory_open:
		Events.emit_signal("player_search")

func _on_wait_pressed():
	if not GameState.inventory_open:
		Events.emit_signal("player_wait")

func _on_continue_pressed():
	if not GameState.inventory_open:
		continue_box.visible = false
		Events.emit_signal("player_continue")
		
