extends Node2D

func _ready():
	GameState.camera = $Camera
	GameState.grid = $Grid

func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		GameState.shake(0.3, 0.5)
		GameState.grid.reset_doors()
	
	if event.is_action_pressed("ui_accept"):
		if $Camera.z == 0.5:
			$Camera.z = 1
		else:
			$Camera.z = 0.5
		$Camera/Tween.interpolate_property($Camera, "zoom", $Camera.z, Vector2.ONE * $Camera.zoom, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Camera/Tween.start()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$Player.travel_path = GameState.grid.get_travel_path(Helpers.world_to_tile($Player.global_position), Helpers.world_to_tile(get_local_mouse_position()))
			pass

func _physics_process(delta):
	$Background.rect_position = $Camera.get_camera_screen_center() - $Background.rect_size / 2
	$Camera.target = $Player.position
