extends CenterContainer

onready var item_image = $ItemImage
onready var item_eq = $Extra/Equipped
onready var item_stat = $Extra/Stat
onready var item_upgrade = $Extra/Upgrade
onready var inventory = GameState.player.backpack

func _ready():
	_hide_stats()

func _hide_stats():
	item_eq.visible = false
	item_stat.visible = false
	item_upgrade.visible = false

func display_item(item):
	if item is Item:
		item_image.texture = item.texture
		
		if item is Weapon:
			item_eq.visible = (GameState.player.equipped.weapon == item)
			item_stat.visible = true
			item_upgrade.visible = true
			item_stat.text = "%d" % item.damage
			item_upgrade.text = "+%d" % item.upgrade
		else:
			_hide_stats()
	else:
		item_image.texture = null
		_hide_stats()

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

func _on_ItemImage_gui_input(event):
	if event.is_action_released("select"):
		var item = inventory.get_item(get_index()) as Item
		if item is Weapon:
			if item == GameState.player.equipped.weapon:
				Events.emit_signal("player_unequip_weapon")
				Events.emit_signal("open_inventory")
			else:
				Events.emit_signal("player_equip", item)
				Events.emit_signal("open_inventory")
		elif item is Scroll:
			item.use()
			inventory.remove_item(get_index())
			Events.emit_signal("open_inventory")
			Events.emit_signal("player_acted")
