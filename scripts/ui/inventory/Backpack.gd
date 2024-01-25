extends Control

func _ready():
	Events.open_inventory.connect(_on_open_inventory)

func _on_open_inventory():
	visible = true if not visible else false
	GameState.inventory_open = visible
