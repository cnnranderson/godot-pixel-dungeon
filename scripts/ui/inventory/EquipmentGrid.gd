extends GridContainer

@onready var weapon_slot = $Weapon
@onready var armor_slot = $Armor
@onready var ring1_slot = $Ring1
@onready var ring2_slot = $Ring2

func _ready():
	Events.refresh_backpack.connect(refresh_inventory)

func refresh_inventory():
	weapon_slot.display_item(GameState.player.equipped.weapon)
	armor_slot.display_item(GameState.player.equipped.armor)
	ring1_slot.display_item(null)
	ring2_slot.display_item(null)
