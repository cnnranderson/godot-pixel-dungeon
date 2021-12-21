extends Control

onready var lvl = $Panel/HBox/Stats/Vbox/Level/Label
onready var hp = $Panel/HBox/Stats/Vbox/Hp/Bar
onready var xp = $Panel/HBox/Stats/Vbox/Xp/Bar
onready var keys = $Panel/HBox/Items/Vbox/Keys/Count
onready var coins = $Panel/HBox/Items/Vbox/Coins/Count

func _ready():
	Events.connect("player_interact", self, "_on_player_interact")
	Events.connect("player_levelup", self, "_on_player_levelup")
	Events.connect("player_gain_xp", self, "_on_player_gain_xp")
	pass

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

func _on_player_gain_xp(xp_amount):
	xp.value = GameState.player.stats.xp
	
