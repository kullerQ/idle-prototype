extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddWeakenedDmgMod

@export var amount: float = 0.0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.projectile_mod_data.weakened_dmg_mod += amount
