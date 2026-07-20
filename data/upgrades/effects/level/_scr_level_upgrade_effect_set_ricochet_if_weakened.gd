extends LevelUpgradeEffect
class_name LevelUpgradeEffectSetRicochetIfWeakened

@export var enabled: bool = true


func apply_to_cell(cell: PlayerCell) -> void:
	cell.projectile_mod_data.ricochet_if_weakened = enabled
