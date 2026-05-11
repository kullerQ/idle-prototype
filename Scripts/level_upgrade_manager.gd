class_name LevelUpgradeManager

enum Types {
	NULL,
	TEST,
	SHOOTER_PATH2,
}

var descriptions: Dictionary = {
	Types.NULL: "no description",
	Types.TEST: "test",
	Types.SHOOTER_PATH2: "test",
}

func apply_upgrade(type: Types, cell: PlayerCell) -> void:
	match type:
		Types.TEST:
			cell.cooldown_reduction += 1

func get_description(type: Types) -> String:
	return descriptions[type]
