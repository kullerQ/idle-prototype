extends LevelUpgradeEffect
class_name LevelUpgradeEffectSetAutoAim

@export var enabled: bool = true


func apply_to_cell(cell: PlayerCell) -> void:
	cell.auto_aim = enabled
