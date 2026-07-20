extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddBonusCritChanceOnWeakened

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.projectile_mod_data.bonus_crit_chance_on_weakened += amount
