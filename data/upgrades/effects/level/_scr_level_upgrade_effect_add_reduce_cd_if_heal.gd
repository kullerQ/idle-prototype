extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddReduceCdIfHeal

@export var amount: float = 0.0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.reduce_cd_if_heal += amount
