extends Control

# Stats
@onready var lvl = $MainContainer/NameContainer/Character/LevelValue
@onready var hp = $MainContainer/HpContainer/Hp/Bar
@onready var xp = $MainContainer/XpContainer/Xp/Bar
@onready var keys = $MainContainer/MiscContainer/Items/Keys/Count
@onready var coins = $MainContainer/MiscContainer/Items/Coins/Count
@onready var depth = $MainContainer/MiscContainer/Items/Floor/Label

func _ready():
	Events.map_ready.connect(_init_stats)
	Events.player_interact.connect(_on_player_interact)
	Events.player_gain_xp.connect(_on_player_gain_xp)
	Events.player_hit.connect(_on_player_hit)
	Events.next_stage.connect(_on_next_level)

func _init_stats():
	lvl.text = "Lv: %d" % GameState.player.stats.level
	hp.max_value = GameState.hero.max_hp
	hp.value = GameState.hero.hp
	xp.value = GameState.player.stats.xp
	xp.max_value = GameState.player.stats.xp_next

### Player Events
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

func _on_next_level():
	depth.text = ": %d" % GameState.depth
