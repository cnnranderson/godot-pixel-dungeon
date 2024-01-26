extends Node

signal on_value_change(key, value)

const SECTION = "user"
const SETTINGS_FILE = "user://settings.cfg"

const VOLUME_MASTER = "volume_master"
const VOLUME_MUSIC = "volume_music"
const VOLUME_SFX = "volume_sfx"
const DB_MASTER = "db_master"
const DB_MUSIC = "db_music"
const DB_SFX = "db_sfx"

var DEFAULTS = {
	VOLUME_MASTER: true,
	VOLUME_MUSIC: true,
	VOLUME_SFX: true,
	DB_MASTER: 100,
	DB_MUSIC: 70,
	DB_SFX: 70
}

var config: ConfigFile

func _ready():
	config = ConfigFile.new()
	config.load(SETTINGS_FILE)

func set_value(key, value):
	config.set_value(SECTION, key, value)
	config.save(SETTINGS_FILE)

func get_value(key):
	return config.get_value(SECTION, key, _get_default(key))

func _get_default(key):
	if DEFAULTS.has(key):
		return DEFAULTS[key]
	return null
