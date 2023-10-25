@tool
extends Area2D
class_name WorldItem

const SOUND = {
	"generic": "res://assets/pd_import/sounds/snd_item.mp3",
	"gold": "res://assets/pd_import/sounds/snd_gold.mp3"
}

@export var count: int = 1
@export var item: Resource: set = set_item

var collected = false

func set_item(new_value):
	item = new_value as Item
	
	if item:
		match item.category:
			Item.Category.SCROLL:
				item.texture.region.position.x = 16 * (randi() % 8)
				$Sprite2D.texture = item.texture
			_:
				$Sprite2D.texture = item.texture

func collect():
	if collected: return
	collected = true
	match item.category:
		Item.Category.KEY:
			GameState.player.inventory.keys += count
			Sounds.play_sound(Sounds.SoundType.SFX, SOUND.generic)
			Events.player_interact.emit(Item.Category.KEY)
			Events.log_message.emit("You found a key")
		
		Item.Category.COINS:
			GameState.player.inventory.coins += count
			Sounds.play_sound(Sounds.SoundType.SFX, SOUND.gold)
			Events.player_interact.emit(Item.Category.COINS)
			Events.log_message.emit("You found some gold (%d)" % count)
		
		Item.Category.SCROLL:
			item = item as Scroll
			if GameState.player.backpack.add_item(item):
				Events.log_message.emit("You found %s" % item.get_item_name())
			else:
				Events.log_message.emit("Your inventory is full!")
		
		Item.Category.WEAPON, Item.Category.ARMOR:
			item = item
			if GameState.player.backpack.add_item(item):
				Events.log_message.emit("You found %s" % item.get_item_name())
			else:
				Events.log_message.emit("Your inventory is full!")
	
	await get_tree().create_timer(0.1).timeout
	queue_free()
