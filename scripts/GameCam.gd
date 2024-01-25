extends Camera2D
class_name GameCam

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
var decay = 0.8  # How quickly the shaking stops [0, 1].
var max_offset = Vector2(64, 48)  # Maximum hor/ver shake in pixels.

func _ready():
	Events.camera_shake.connect(add_trauma)

func _unhandled_input(event):
	if event.is_action_pressed("camera_zoom"):
		var z = Vector2.ONE * 0.5 if zoom.x == 1 else Vector2.ONE
		var tween = create_tween()
		tween.tween_property(self, "zoom", z, 0.25) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)

func _physics_process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount, decay_percent):
	decay = clamp(decay_percent, 0, 1)
	if amount > trauma:
		trauma = min(amount, 1.0)

func shake():
	var amount = pow(trauma, trauma_power)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
