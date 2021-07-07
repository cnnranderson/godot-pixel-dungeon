extends Control

func _ready():
	pass

func _on_PlayButton_pressed():
	Global.main.load_scene(Global.Scenes.GAME)

func _on_QuitButton_pressed():
	get_tree().quit()


