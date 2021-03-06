extends Node

"""
Events Singleton -- used to define global events for the entire game.

This allows us to bind events anywhere across the entities used
without having to create complex hierarchies within nodes when
connecting signal subscribers.
"""

# Misc Events
signal log_message(event)
signal camera_shake(amount, decay)
signal map_ready
signal next_stage

# Actor Events
signal player_acted
signal enemy_died(xp)

# Player Events
signal player_interrupted
signal player_interact(item)
signal player_equip(item)
signal player_use_item
signal player_unequip_weapon
signal player_unequip_armor
signal player_continue
signal player_search
signal player_wait
signal player_hit
signal player_gain_xp
signal player_levelup
signal refresh_backpack
signal open_inventory
