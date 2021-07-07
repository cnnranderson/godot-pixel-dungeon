extends Node2D
class_name Main

var curr_scene = Global.Scenes.START_MENU
var scene_state = 0
var skip_transition = [false, false]

func _ready():
	Global.main = self
	load_scene(Global.Scenes.GAME, true, true)

func load_scene(scene = -1, skip_intro = false, skip_outro = false):
	# Validate scene
	if scene != -1:
		assert(scene in Global.Scenes.values())
		scene_state = 0
		curr_scene = scene
		skip_transition = [skip_intro, skip_outro]
	
	match scene_state:
		0:
			# Pause any happenings
			get_tree().paused = true
			$Timers/LoadTimer.set_wait_time(0.05)
			$Timers/LoadTimer.start()
			
			scene_state = 1 if not skip_transition[0] else 2
		1:
			# Enter transition
			# $TransitionLayer/Screen/Animation.play("transition_in")
			$Timers/LoadTimer.set_wait_time(1)
			$Timers/LoadTimer.start()
			scene_state = 2
		2:
			# Load the new scene
			print("LOADING Scene: %s" % curr_scene)
			var children = $Scene.get_children()
			if not children.empty():
				children[0].queue_free()
			var new_scene = load(Global.SceneMap[curr_scene]).instance()
			$Scene.add_child(new_scene)
			
			$Timers/LoadTimer.set_wait_time(0.05)
			$Timers/LoadTimer.start()
			scene_state = 3 if not skip_transition[0] else 4
		3:
			# Exit transition
			# $TransitionLayer/Screen/Animation.play("transition_out")
			$Timers/LoadTimer.set_wait_time(1)
			$Timers/LoadTimer.start()
			scene_state = 4
		4:
			# Unpause the tree to continue with the scene
			get_tree().paused = false
			scene_state = 0

func _on_LoadTimer_timeout():
	load_scene()
