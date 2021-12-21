extends Area2D
class_name Item

const SOUND = {
	"generic": "res://assets/pd_import/sounds/snd_item.mp3",
	"gold": "res://assets/pd_import/sounds/snd_gold.mp3"
}

export var texture: Texture
export var count: int = 1
export(Constants.Item) var item_type = Constants.Item.KEY

var collected = false

func _ready():
	$Texture.texture = texture

func collect():
	if collected: return
	collected = true
	match (item_type):
		Constants.Item.KEY:
			GameState.player.inventory.keys += count
			Sounds.play_sound(Sounds.SoundType.SFX, SOUND.generic)
			Events.emit_signal("player_interact", Constants.Item.KEY)
			Events.emit_signal("log_message", "You found a key")
		
		Constants.Item.COIN:
			GameState.player.inventory.coins += count
			Sounds.play_sound(Sounds.SoundType.SFX, SOUND.gold)
			Events.emit_signal("player_interact", Constants.Item.COIN)
			Events.emit_signal("log_message", "You found some gold (%d)" % count)
	
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
