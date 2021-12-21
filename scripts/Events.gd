extends Node

"""
Events Singleton -- used to define global events for the entire game.

This allows us to bind events anywhere across the entities used
without having to create complex hierarchies within nodes when
connecting signal subscribers.
"""

signal log_message(event)
signal map_ready(spawn)

# UI Events
signal player_interact(item)
signal player_wait()
signal player_search()
signal player_gain_xp()
signal player_levelup()
signal open_inventory()
