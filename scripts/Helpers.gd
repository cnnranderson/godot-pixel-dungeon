extends Node

"""
Misc helper functions
"""

func chance_luck(percentage):
	if percentage > 99:
		return true
	elif percentage > 0:
		var chance = randi() % 99 + 1
		return chance in range(1, percentage)
	return false
