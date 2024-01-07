@tool
extends CenterContainer

@export var default_img: Texture2D

@onready var item_image = $ItemImage
@onready var item_eq = $Extra/Equipped
@onready var item_stat = $Extra/Stat
@onready var item_upgrade = $Extra/Upgrade
var inventory

func _ready():
	if not Engine.is_editor_hint():
		inventory = GameState.player.backpack
		_hide_stats()
	if default_img:
		item_image.texture = default_img

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
			item_stat.text = "%d" % item.weight
			item_upgrade.text = "+%d" % item.upgrade
		elif item is Armor:
			item_eq.visible = (GameState.player.equipped.armor == item)
			item_stat.visible = true
			item_upgrade.visible = true
			item_stat.text = "%d" % item.ac
			item_upgrade.text = "+%d" % item.upgrade
		else:
			_hide_stats()
	else:
		item_image.texture = null
		_hide_stats()

func _get_drag_data(_position):
	var item_index = get_index()
	var item = inventory.get_item(item_index)
	if item is Item:
		var data = {}
		data.item = item
		data.item_index = item_index
		var drag_preview = TextureRect.new()
		drag_preview.texture = item.texture
		drag_preview.scale = Vector2(2, 2)
		set_drag_preview(drag_preview)
		return data

func _can_drop_data(_position, data):
	return data is Dictionary and data.has("item")

func _drop_data(_position, data):
	var item_index = get_index()
	# var item = inventory.items[item_index]
	inventory.swap_items(item_index, data.item_index)
	inventory.set_item(item_index, data.item)

func _on_ItemImage_gui_input(event):
	if event.is_action_released("select"):
		var item = inventory.get_item(get_index()) as Item
		if item is Weapon:
			if GameState.player.equipped.weapon:
				var ref = GameState.player.equipped.weapon
				inventory.set_item(get_index(), ref)
			else:
				inventory.remove_item(get_index())
			Events.player_equip.emit(item)
			Events.open_inventory.emit()
		elif item is Armor:
			if GameState.player.equipped.armor:
				inventory.set_item(get_index(), GameState.player.equipped.armor)
			else:
				inventory.remove_item(get_index())
			Events.player_equip.emit(item)
			Events.open_inventory.emit()
		elif item is Scroll:
			Events.player_use_item.emit()
			Events.open_inventory.emit()
			inventory.remove_item(get_index())
			item.use()
