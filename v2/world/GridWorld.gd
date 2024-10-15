class_name GridWorld
extends Node

signal world_updated()

@export var world_size := Vector2i(40, 21)
@export var cell_size := Vector2(16, 16)

@onready var cycle_timer: Timer
@onready var cycle_wait_timer: Timer
# TODO: Tooltip/Cursor overlays here..? seems odd

# TODO: Assign a player node to the world for ref

# <Vector2i, GridCell> - position, cell data
var cells: Dictionary = {}
