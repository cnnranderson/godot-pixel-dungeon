extends CenterContainer

onready var item_image = $ItemImage

var inventory = preload("res://scripts/ui/inventory/Inventory.tres")

func display_item(item):
	if item is Item:
		item_image.texture = item.texture
	else:
		item_image.texture = null

func get_drag_data(_position):
	var item_index = get_index()
	var item = inventory.get_item(item_index)
	if item is Item:
		var data = {}
		data.item = item
		data.item_index = item_index
		var drag_preview = TextureRect.new()
		drag_preview.texture = item.texture
		drag_preview.rect_scale = Vector2(2, 2)
		set_drag_preview(drag_preview)
		return data

func can_drop_data(_position, data):
	return data is Dictionary and data.has("item")

func drop_data(_position, data):
	var item_index = get_index()
	var item = inventory.items[item_index]
	inventory.swap_items(item_index, data.item_index)
	inventory.set_item(item_index, data.item)