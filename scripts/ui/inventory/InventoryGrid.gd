extends GridContainer

const InventoryItem = preload("res://ui/inventory/InventoryItem.tscn")
var inventory = preload("res://scripts/ui/inventory/Inventory.tres")
var player_inventory = GameState.player.inventory

func _ready():
	inventory.set_backpack_size(player_inventory.max_size)
	for i in inventory.items.size() - 1:
		var slot = InventoryItem.instance()
		add_child(slot)
	inventory.connect("items_changed", self, "_on_items_changed")
	refresh_inventory()

func refresh_inventory():
	for idx in inventory.items.size():
		update_inventory_slot(idx)

func update_inventory_slot(item_index):
	var item_slot = get_child(item_index)
	var item = inventory.items[item_index]
	item_slot.display_item(item)

func _on_items_changed(indexes):
	for idx in indexes:
		update_inventory_slot(idx)

