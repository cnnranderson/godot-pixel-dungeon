tool
extends Area2D
class_name WorldItem

const SOUND = {
	"generic": "res://assets/pd_import/sounds/snd_item.mp3",
	"gold": "res://assets/pd_import/sounds/snd_gold.mp3"
}

export(int) var count = 1

var collected = false
export(Resource) var item: Resource setget set_item

func set_item(new_value):
	item = new_value as Item
	$TextureRect.texture = item.texture

func collect():
	if collected: return
	collected = true
	match (item.type):
		Item.Type.KEY:
			GameState.player.inventory.keys += count
			Sounds.play_sound(Sounds.SoundType.SFX, SOUND.generic)
			Events.emit_signal("player_interact", Item.Type.KEY)
			Events.emit_signal("log_message", "You found a key")
		
		Item.Type.COINS:
			GameState.player.inventory.coins += count
			Sounds.play_sound(Sounds.SoundType.SFX, SOUND.gold)
			Events.emit_signal("player_interact", Item.Type.COINS)
			Events.emit_signal("log_message", "You found some gold (%d)" % count)
		
		Item.Type.WEAPON:
			item = item as Weapon
			if GameState.player.backpack.add_item(item):
				Events.emit_signal("log_message", "You found %s" % item.get_name())
			else:
				Events.emit_signal("log_message", "Your inventory is full!")
	
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
