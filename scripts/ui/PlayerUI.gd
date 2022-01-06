extends Control

# Stats
onready var lvl = $VBox/Panel/HBox/Stats/Vbox/Level/Label
onready var hp = $VBox/Panel/HBox/Stats/Vbox/Hp/Bar
onready var xp = $VBox/Panel/HBox/Stats/Vbox/Xp/Bar
onready var keys = $VBox/Panel/HBox/Items/Vbox/Keys/Count
onready var coins = $VBox/Panel/HBox/Items/Vbox/Coins/Count
onready var depth = $VBox/Panel/HBox/Stats/Vbox/Level/Floor/Label

# Actions
onready var backpack = $VBox/Hbox/Backpack/Button
onready var search = $VBox/Hbox/Search/Button
onready var wait = $VBox/Hbox/Wait/Button

func _ready():
	Events.connect("player_interact", self, "_on_player_interact")
	Events.connect("player_levelup", self, "_on_player_levelup")
	Events.connect("player_hit", self, "_on_player_hit")
	backpack.connect("button_down", self, "_on_backpack_pressed")
	search.connect("button_down", self, "_on_search_pressed")
	wait.connect("button_down", self, "_on_wait_pressed")

func _init_stats():
	lvl.text = "Lv: %d" % GameState.player.stats.level
	hp.max_value = GameState.player.actor.max_hp
	hp.value = GameState.player.actor.hp
	xp.value = GameState.player.stats.xp
	xp.max_value = GameState.player.stats.xp_next


### Player Events
func _on_player_interact(item):
	match (item):
		Item.Category.KEY: keys.text = str(GameState.player.inventory.keys)
		Item.Category.COINS: coins.text = str(GameState.player.inventory.coins)

func _on_player_levelup():
	lvl.text = "Lv: %d" % GameState.player.level
	hp.value = GameState.player.stats.hp
	hp.max_value = GameState.player.stats.hp_max
	xp.value = GameState.player.stats.hp
	xp.max_value = GameState.player.stats.xp_next

func _on_player_hit():
	hp.value = GameState.player.actor.hp

### Action Events
func _on_backpack_pressed():
	Events.emit_signal("open_inventory")

func _on_search_pressed():
	if not GameState.inventory_open:
		Events.emit_signal("player_search")

func _on_wait_pressed():
	if not GameState.inventory_open:
		Events.emit_signal("player_wait")
