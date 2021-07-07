extends Node

enum SoundType { SFX, MUSIC }

func play_sound(type, sound_file: String, pitch = 1.0):
	# Check for supported sound type
	assert(type in SoundType.values())
	
	# Setup the audio player
	var sound = AudioStreamPlayer.new()
	sound.stream = load(sound_file)
	sound.pitch_scale = pitch
	sound.connect("finished", sound, "queue_free")
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
	sound.connect("finished", sound, "queue_free")
	_set_volume(sound, type)
	add_child(sound)
	sound.play()

func _set_volume(audio, type):
	# Match volume to settings level
	match type:
		SoundType.SFX:
			audio.volume_db = linear2db(0.5)
		SoundType.MUSIC:
			audio.volume_db = linear2db(0.5)
		_:
			audio.volume_db = linear2db(0.5)
