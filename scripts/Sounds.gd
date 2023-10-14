extends Node

enum SoundType { SFX, MUSIC }

const SOUND = {
	"bump": "res://assets/pd_import/sounds/snd_puff.mp3",
	"step": "res://assets/pd_import/sounds/snd_step.mp3",
	"hit": "res://assets/pd_import/sounds/snd_hit.mp3",
	"enemy_hit": "res://assets/pd_import/sounds/snd_enemy_hit.wav"
}

func play_sound(type, sound_file: String, pitch = 1.0):
	# Check for supported sound type
	assert(type in SoundType.values())
	
	# Setup the audio player
	var sound = AudioStreamPlayer.new()
	sound.stream = load(sound_file)
	sound.pitch_scale = pitch
	sound.connect("finished", Callable(sound, "queue_free"))
	_set_volume(sound, type)
	add_child(sound)
	sound.play()

func play_sound_2d(type, sound_file: String, sound_position: Vector2, pitch = 1.0):
	# Check for supported sound type
	assert(type in SoundType.values())
	
	# Setup the audio player (2D Positional)
	var sound = AudioStreamPlayer2D.new()
	sound.position = sound_position
	sound.stream = load(sound_file)
	sound.pitch_scale = pitch
	sound.connect("finished", Callable(sound, "queue_free"))
	_set_volume(sound, type)
	add_child(sound)
	sound.play()

func play_hit():
	play_sound(SoundType.SFX, SOUND.hit, clamp((randi() % 25 + 75) / 100.0, 0.75, 1.0))

func play_enemy_hit():
	play_sound(SoundType.SFX, SOUND.enemy_hit, clamp((randi() % 25 + 75) / 100.0, 0.75, 1.0))

func play_step():
	play_sound(Sounds.SoundType.SFX, SOUND.step, clamp((randi() % 25 + 75) / 100.0, 0.75, 1.0))

func play_collision():
	play_sound(Sounds.SoundType.SFX, SOUND.bump)

func _set_volume(audio, type):
	# Match volume to settings level - fine tune using your own settings configurations.
	match type:
		SoundType.SFX:
			audio.volume_db = linear_to_db(0.5)
		SoundType.MUSIC:
			audio.volume_db = linear_to_db(0.5)
		_:
			audio.volume_db = linear_to_db(0.5)
