extends GridContainer

const InventoryItem = preload("res://ui/inventory/InventoryItem.tscn")
var inventory: Inventory

func _ready():
	# Clear out any test children
	for child in get_children():
		child.queue_free()
	
	# Setup inventory spaces
	inventory = GameState.player.backpack
	for i in inventory.items.size():
		var slot = InventoryItem.instantiate()
		add_child(slot)
	Events.connect("refresh_backpack", refresh_inventory)
	inventory.connect("items_changed", _on_items_changed)
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

