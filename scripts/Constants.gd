extends Node

# General Constants
const TILE_SIZE = 16
const TILE_V = Vector2.ONE * TILE_SIZE
const INPUTS = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN
}

# Item Constants
enum Item {
	KEY,
	COIN,
	WEAPON,
	WAND,
	POTION,
	SCROLL
}
