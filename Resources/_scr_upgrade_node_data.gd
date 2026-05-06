extends Resource
class_name UpgradeNodeData

@export var type: UpgradeManager.Types
@export var max_lvl: int
@export var unlock_lvl: int
@export var cost: Dictionary = {
	Economy.Currencies.WOOD: [0],
	Economy.Currencies.FREE_CELLS: [0],
	}
