extends Node

"""
Events Singleton -- used to define events for the entire game.

This allows us to bind events anywhere across the entities used
without having to create complex hierarchies within nodes when
connecting signal subscribers.
"""

signal log_message(event)
signal map_ready(spawn)

signal game_won
signal game_lost
