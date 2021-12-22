extends Node

# General Constants
const TILE_SIZE = 16
const TILE_V = Vector2.ONE * TILE_SIZE
const INPUTS = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN,
	"move_ul": Vector2.LEFT + Vector2.UP,
	"move_ur": Vector2.RIGHT + Vector2.UP,
	"move_dl": Vector2.LEFT + Vector2.DOWN,
	"move_dr": Vector2.RIGHT + Vector2.DOWN
}
