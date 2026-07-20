extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddSpawnTreeOnOverhealChance

@export var amount: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.spawn_tree_on_overheal_chance += amount
