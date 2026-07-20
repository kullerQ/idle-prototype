extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddSpawnWoodToRightChance

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.spawn_wood_to_the_right_chance += amount
