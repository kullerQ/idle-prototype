extends LevelUpgradeEffect
class_name LevelUpgradeEffectSetRicochetAfterKill

@export var enabled: bool = true


func apply_to_cell(cell: PlayerCell) -> void:
	cell.projectile_mod_data.ricochet_after_kill = enabled
