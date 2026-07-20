extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddSpreadHeal

@export var ratio: float = 0.0
@export var targets: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.projectile_mod_data.spread_damage_ratio += ratio
	cell.projectile_mod_data.spread_damage_to += targets
