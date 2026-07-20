extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddCellHitDamage

@export var amount: float = 0.0


func apply_to_cell(cell: PlayerCell) -> void:
	DamageManager.add_hit_hp(cell.bonus_damage, amount)
