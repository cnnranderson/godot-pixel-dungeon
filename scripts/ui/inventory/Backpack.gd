extends Control

func _ready():
	Events.connect("open_inventory", self, "_on_open_inventory")

func _on_open_inventory():
	visible = true if not visible else false
