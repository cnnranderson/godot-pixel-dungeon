extends Control

const EventLabel = preload("res://ui/log/EventLabel.tscn")

@export var log_count = 5

@onready var feed = $Feed

func _ready():
	Events.log_message.connect(add_event)

func add_event(text: String):
	var logs = feed.get_children()
	if not logs.is_empty() and logs.back().display_text == text:
		# Add an additional log count to the most recent event
		logs.back().add_event_count()
	else:
		# Add a new event to the log
		var label = EventLabel.instantiate()
		feed.add_child(label)
		label.show_event(text)
		
	# Remove old events
	if logs.size() > log_count:
		var log_event = logs.pop_front()
		log_event.queue_free()
