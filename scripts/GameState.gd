extends Node

var turn_list = []
var player_turn = true
var camera: GameCam = null
var world: GameWorld = null

func is_player_turn():
	return turn_list

func shake(amount, decay):
	if not camera:
		return
	camera.add_trauma(amount, decay)
