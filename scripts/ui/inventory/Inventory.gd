extends Resource
class_name Inventory

signal items_changed(indexes)

@export var items = [] # (Array, Resource)

func set_backpack_size(size):
	for i in size:
		items.append(null)

func add_item(item):
	for idx in items.size():
		if items[idx] == null:
			set_item(idx, item)
			items_changed.emit([idx])
			return true
	return false

func set_item(item_index, item):
	var prev_item = items[item_index]
	items[item_index] = item
	items_changed.emit([item_index])
	return prev_item

func get_item(item_index):
	return items[item_index]

func swap_items(item_index, target_index):
	var item = items[item_index]
	var target = items[target_index]
	items[target_index] = item
	items[item_index] = target
	items_changed.emit([item_index, target_index])

func remove_item(item_index):
	var prev_item = items[item_index]
	items[item_index] = null
	items_changed.emit([item_index])
	return prev_item

