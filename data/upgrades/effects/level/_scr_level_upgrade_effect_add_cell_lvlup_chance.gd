extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddCellLvlupChance

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.cell_lvlup_chance += amount
