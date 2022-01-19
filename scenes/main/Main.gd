extends Node2D
class_name Main

const DEFAULT_SCENE_DELAY = 0.05
const DEFAULT_TRANSITION_DELAY = 1

# Set this to something else if you wish to enter a different scene on start
var curr_scene = Global.Scenes.MAP_GEN
var scene_state = 0
var skip_transition = [false, false]

func _ready():
	Global.main = self
	load_scene(curr_scene, true, true)

"""
Prepares to load a scene into the node tree. This will also allow for set transitions
to occur while loading in/out of scenes.

scene - The scene to load; Scenes should be mapped in the Global script.
skip_exit - whether or not to use a transition when leaving the current scene.
skip_enter - whether or not to use a transition when entering the next scene.
"""
func load_scene(scene = -1, skip_exit = false, skip_enter = false):
	# Validate scene - make sure the scene is mapped to a corresponding tscn
	if scene != -1:
		assert(scene in Global.Scenes.values())
		scene_state = 0
		curr_scene = scene
		skip_transition = [skip_exit, skip_enter]
	
	match scene_state:
		0:
			# Pause any happenings
			get_tree().paused = true
			$Timers/LoadTimer.set_wait_time(DEFAULT_SCENE_DELAY)
			$Timers/LoadTimer.start()
			
			scene_state = 2 if skip_transition[0] else 1
		1:
			# Enter transition - enable this if you want transitions. Requires setup.
			# $TransitionLayer/Screen/Animation.play("transition_in")
			$Timers/LoadTimer.set_wait_time(DEFAULT_TRANSITION_DELAY)
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
			
			$Timers/LoadTimer.set_wait_time(DEFAULT_SCENE_DELAY)
			$Timers/LoadTimer.start()
			scene_state = 4 if skip_transition[1] else 3
		3:
			# Exit transition - enable this if you want transitions. Requires setup.
			# $TransitionLayer/Screen/Animation.play("transition_out")
			$Timers/LoadTimer.set_wait_time(DEFAULT_TRANSITION_DELAY)
			$Timers/LoadTimer.start()
			scene_state = 4
		4:
			# Unpause the tree to continue with the scene
			get_tree().paused = false
			scene_state = 0

"""
This timeout continuously goes through the load scene steps to process a full scene swap.
"""
func _on_LoadTimer_timeout():
	load_scene()
