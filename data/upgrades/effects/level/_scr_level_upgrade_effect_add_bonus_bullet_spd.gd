extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddBonusBulletSpd

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.projectile_mod_data.bonus_bullet_spd += amount
