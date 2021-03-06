extends Resource
class_name Inventory

signal items_changed(indexes)

export(Array, Resource) var items = []

func set_backpack_size(size):
	for i in size:
		items.append(null)

func add_item(item):
	for idx in items.size():
		if items[idx] == null:
			set_item(idx, item)
			emit_signal("items_changed", [idx])
			return true
	return false

func set_item(item_index, item):
	var prev_item = items[item_index]
	items[item_index] = item
	emit_signal("items_changed", [item_index])
	return prev_item

func get_item(item_index):
	return items[item_index]

func swap_items(item_index, target_index):
	var item = items[item_index]
	var target = items[target_index]
	items[target_index] = item
	items[item_index] = target
	emit_signal("items_changed", [item_index, target_index])

func remove_item(item_index):
	var prev_item = items[item_index]
	items[item_index] = null
	emit_signal("items_changed", [item_index])
	return prev_item

