extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddReduceCdIfWeakened

@export var amount: float = 0.0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.projectile_mod_data.reduce_cd_if_weakened += amount
