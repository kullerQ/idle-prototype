extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddBonusAttacks

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.bonus_attacks += amount
