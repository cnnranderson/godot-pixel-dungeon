extends Node

"""
Misc helper functions
"""

"""
Returns true or false for a given percent chance of something happening.

percentage - The chance of a successful event.
"""
func chance_luck(percentage):
	if percentage > 99:
		return true
	elif percentage > 0:
		var chance = randi() % 99 + 1
		return chance in range(1, percentage)
	return false
