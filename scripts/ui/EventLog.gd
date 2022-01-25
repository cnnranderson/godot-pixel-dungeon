extends Control

var EventLabel = preload("res://ui/log/EventLabel.tscn")

onready var feed = $Feed

func _ready():
	Events.connect("log_message", self, "add_event")

func add_event(text: String):
	var label = EventLabel.instance()
	feed.add_child(label)
	label.show_event(text)
