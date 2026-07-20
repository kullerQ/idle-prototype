extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddWeakeningChance

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.projectile_mod_data.weakening_chance += amount
