extends Control

onready var hp = $Panel/Stats/Vbox/Hp/Bar
onready var xp = $Panel/Stats/Vbox/Xp/Bar
onready var keys = $Panel/Items/Vbox/Keys/Count
onready var coins = $Panel/Items/Vbox/Coins/Count

func _ready():
	Events.connect("player_interact", self, "_on_player_interact")
	pass

func _on_player_interact(item):
	match (item):
		Item.Type.KEY: keys.text = str(GameState.player.inventory.keys)
		Item.Type.COINS: coins.text = str(GameState.player.inventory.coins)
	pass
