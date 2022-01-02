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
	backpack.connect("button_down", self, "_on_backpack_pressed")
	search.connect("button_down", self, "_on_search_pressed")
	wait.connect("button_down", self, "_on_wait_pressed")


### Player Events
func _on_player_interact(item):
	match (item):
		Item.Type.KEY: keys.text = str(GameState.player.inventory.keys)
		Item.Type.COINS: coins.text = str(GameState.player.inventory.coins)
	pass

func _on_player_levelup():
	lvl.text = "Lv: %d" % GameState.player.level
	hp.value = GameState.player.stats.hp
	hp.max_value = GameState.player.stats.hp_max
	xp.value = GameState.player.stats.hp
	xp.max_value = GameState.player.stats.xp_next


### Action Events
func _on_backpack_pressed():
	Events.emit_signal("open_inventory")

func _on_search_pressed():
	if not GameState.inventory_open:
		Events.emit_signal("player_search")

func _on_wait_pressed():
	if not GameState.inventory_open:
		Events.emit_signal("player_wait")
