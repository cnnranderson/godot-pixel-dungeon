class_name Message

var text: String
var color: Color

func _init(text: String = "", color: Color = Color.SEA_GREEN):
	self.text = text
	self.color = color

static func from_generic(ev: String) -> Message:
	var message := Message.new(ev)
	return message
