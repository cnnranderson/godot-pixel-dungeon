extends Node

@onready var current_time := mgs_delay

var msg_queue: Array[Message] = []
var mgs_delay := 0.25

func _process(delta: float) -> void:
	current_time -= delta
	
	if current_time <= 0:
		_show_messages()
		current_time = mgs_delay

func _show_messages():
	var msg: Message = msg_queue.pop_front()
	
	# TODO: instantiate a UI message
	# TODO: add message to world

func add_message(pos: Vector2i, msg: Message) -> void:
	msg_queue.push_back(msg)
