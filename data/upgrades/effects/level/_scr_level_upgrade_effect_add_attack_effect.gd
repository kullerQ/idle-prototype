extends LevelUpgradeEffect
class_name LevelUpgradeEffectAddAttackEffect

## PlayerCellManager.AttackEffects value (int to avoid class_name cycle).
@export var attack_effect: int = 0


func apply_to_cell(cell: PlayerCell) -> void:
	cell.attack_effects.append(attack_effect)
