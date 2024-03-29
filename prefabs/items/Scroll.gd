extends Item
class_name Scroll

enum ScrollType {
	HEALING,
	TELEPORT,
	UPGRADE_WPN,
	UPGRADE_ARM,
	ALARM
}


@export var type: ScrollType = ScrollType.HEALING
@export var textures: Array = []
@export var name = "UNKNOWN"
@export var discovered = false

func is_discovered() -> bool:
	return GameState.discovered_scrolls.has(type)

func get_item_name():
	if is_discovered():
		return "a scroll of %s" % name
	else:
		return "an unknown scroll"

func use():
	if not is_discovered():
		GameState.discovered_scrolls.append(type)
	
	Events.log_message.emit("You used a scroll of %s" % name)
	match type:
		ScrollType.HEALING:
			GameState.hero.heal(999)
		ScrollType.TELEPORT:
			Events.log_message.emit("You feel unstable...")
			GameState.hero.unstable_teleport = randi() % 4 + 2
			GameState.hero.should_teleport = true
			print("Unstable Count %d" % GameState.hero.unstable_teleport)
		ScrollType.ALARM:
			#GameState.world.alert_all()
			pass
		ScrollType.UPGRADE_WPN:
			pass
		ScrollType.UPGRADE_ARM:
			pass

