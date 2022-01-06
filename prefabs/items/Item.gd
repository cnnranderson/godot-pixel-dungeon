extends Resource
class_name Item

const SOUND = {
	"generic": "res://assets/pd_import/sounds/snd_item.mp3",
	"gold": "res://assets/pd_import/sounds/snd_gold.mp3"
}

# Item Constants
enum Category {
	KEY,
	GOLD_KEY,
	BOSS_KEY,
	COINS,
	WEAPON,
	ARMOR,
	WAND,
	POTION,
	SCROLL
}

export var texture: Texture
export(Category) var category
