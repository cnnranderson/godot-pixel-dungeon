extends Node2D

func _ready():
	GameState.camera = $Camera
	GameState.world = $World
	
	Events.connect("map_ready", $Player, "_init_character")
	GameState.world._init_world()
	
func _unhandled_input(event):
	if event.is_action_pressed("cancel"):
		GameState.shake(0.3, 0.5)
		GameState.world.reset_doors()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$Player.travel_path = GameState.world.get_travel_path(
				Helpers.world_to_tile($Player.global_position), 
				Helpers.world_to_tile(get_local_mouse_position()))
			pass

func _physics_process(delta):
	$Background.rect_position = $Camera.get_camera_screen_center() - $Background.rect_size / 2
	$Camera.target = $Player.position
