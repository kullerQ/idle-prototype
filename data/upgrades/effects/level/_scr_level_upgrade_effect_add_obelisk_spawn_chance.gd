extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddObeliskSpawnChance

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.obelisk_spawn_chance += amount
