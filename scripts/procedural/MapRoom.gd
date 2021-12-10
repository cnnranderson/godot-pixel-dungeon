class_name MapRoom

var location = Vector2(0, 0) # center
var top_height = 0
var bottom_height = 0
var left_width = 0
var right_width = 0
var expansions = 0
var max_exp = 10

func top_left() -> Vector2:
	return Vector2(location.x - left_width, location.y - top_height)

func top_right():
	return Vector2(location.x + left_width, location.y - top_height)

func bottom_left():
	return Vector2(location.x - left_width, location.y + top_height)

func bottom_right():
	return Vector2(location.x + left_width, location.y + top_height)
