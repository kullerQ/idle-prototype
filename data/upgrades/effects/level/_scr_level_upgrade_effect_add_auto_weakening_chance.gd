extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddAutoWeakeningChance

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.auto_weakening_chance += amount
