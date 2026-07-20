extends LevelUpgradeEffect
class_name LevelUpgradeEffectSetWeakeningChance

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.weakening_chance = amount
