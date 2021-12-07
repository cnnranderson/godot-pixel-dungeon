extends Node

var turn_list = []
var camera : GameCam = null

func is_player_turn():
	return turn_list

func shake(amount, decay):
	if not camera:
		return
	camera.add_trauma(amount, decay)
