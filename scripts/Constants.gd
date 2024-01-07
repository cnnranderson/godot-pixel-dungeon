extends Node

# General Constants
const BASE_ACTION_COST = 100
const TILE_SIZE = 16
const TILE_HALF = TILE_SIZE / 2
const TILE_V = Vector2.ONE * TILE_SIZE
const CARDINAL = [
	Vector2i.RIGHT,
	Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.DOWN
]
const INPUTS = {
	"move_right": Vector2i.RIGHT,
	"move_left": Vector2i.LEFT,
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN
}
const VALID_DIRS = [
	Vector2i.RIGHT,
	Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i(-1, -1),
	Vector2i(-1, 1),
	Vector2i(1, -1),
	Vector2i(1, 1),
]
