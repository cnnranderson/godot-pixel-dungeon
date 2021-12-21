extends KinematicBody2D
class_name Item

export var texture: Texture
export var count: int = 1
export(Constants.Item) var item_type = Constants.Item.KEY

func _ready():
	$Texture.texture = texture

func collect():
	return item_type
