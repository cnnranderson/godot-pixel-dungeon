extends Node2D

func _ready():
	GameState.camera = $Camera

func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		GameState.shake(0.5, 0.5)
	if event.is_action_pressed("ui_accept"):
		if $Camera.zoom == 0.5:
			$Camera.zoom = 1
		else:
			$Camera.zoom = 0.5
		$Camera/Tween.interpolate_property($Camera, "zoom", $Camera.zoom, Vector2.ONE * $Camera.zoom, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Camera/Tween.start()

func _physics_process(delta):
	$Background.rect_position = $Camera.get_camera_screen_center() - $Background.rect_size / 2
	$Camera.target = $Player.position
