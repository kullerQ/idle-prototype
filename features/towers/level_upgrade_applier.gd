class_name LevelUpgradeApplier
## Applies UpgradeDefinition level effects to a PlayerCell.


func apply(def: UpgradeDefinition, cell: PlayerCell) -> void:
	for effect in def.effects:
		if effect is LevelUpgradeEffect:
			(effect as LevelUpgradeEffect).apply_to_cell(cell)
		else:
			push_error(
				"LevelUpgradeApplier: expected LevelUpgradeEffect in definition id %d" % def.id
			)
