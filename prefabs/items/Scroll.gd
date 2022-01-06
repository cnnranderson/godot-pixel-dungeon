extends Item
class_name Scroll

enum ScrollType {
	HEALING,
	TELEPORT,
	UPGRADE_WPN,
	UPGRADE_ARM,
	ALARM
}


export(ScrollType) var type = ScrollType.HEALING
export(Array) var textures = []
export var name = "UNKNOWN"
export var discovered = false

func is_discovered() -> bool:
	return GameState.discovered_scrolls.has(type)

func get_name():
	if is_discovered():
		return "a scroll of %s" % name
	else:
		return "an unknown scroll"

func use():
	if not is_discovered():
		GameState.discovered_scrolls.append(type)
	
	match(type):
		ScrollType.HEALING:
			GameState.player_actor.heal(999)
		ScrollType.TELEPORT:
			#GameState.player_actor.teleport()
			pass
		ScrollType.ALARM:
			#GameState.level.alert_all()
			pass
		ScrollType.UPGRADE_WPN:
			pass
		ScrollType.UPGRADE_ARM:
			pass
	pass

