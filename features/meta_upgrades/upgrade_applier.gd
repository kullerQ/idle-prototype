class_name UpgradeApplier
## Applies UpgradeDefinition effects through existing manager mutator APIs.
## Add new effect branches here when a new UpgradeEffect subclass appears.

var cell_manager: CellManager
var timer_manager: TimerManager
var player_cell_manager: PlayerCellManager
var building_manager: BuildingManager
var projectile_manager: ProjectileManager
var damage_manager: DamageManager


func apply(def: UpgradeDefinition) -> void:
	for effect in def.effects:
		_apply_effect(effect as UpgradeEffect)


func _apply_effect(effect: UpgradeEffect) -> void:
	if effect is UpgradeEffectSubTimerWait:
		var e: UpgradeEffectSubTimerWait = effect as UpgradeEffectSubTimerWait
		timer_manager.sub_timer_wait_t(e.timer_type, e.timer_key, e.amount)
	elif effect is UpgradeEffectAddCellLifeTime:
		var e: UpgradeEffectAddCellLifeTime = effect as UpgradeEffectAddCellLifeTime
		cell_manager.add_life_time(e.cell_name, e.amount)
	elif effect is UpgradeEffectAddBreakAndDurability:
		var e: UpgradeEffectAddBreakAndDurability = effect as UpgradeEffectAddBreakAndDurability
		cell_manager.add_break_and_durability(e.cell_name, e.break_amount, e.durability_amount)
	elif effect is UpgradeEffectUnlockWeightedResource:
		var e: UpgradeEffectUnlockWeightedResource = effect as UpgradeEffectUnlockWeightedResource
		cell_manager.unlock_weighted_resource(e.cell_name, e.weight, e.resource_type)
	elif effect is UpgradeEffectAddCellWeight:
		var e: UpgradeEffectAddCellWeight = effect as UpgradeEffectAddCellWeight
		cell_manager.add_cell_weight(e.cell_name, e.amount, e.resource_type)
	elif effect is UpgradeEffectAddCellValue:
		var e: UpgradeEffectAddCellValue = effect as UpgradeEffectAddCellValue
		cell_manager.add_value(e.cell_name, e.amount)
	elif effect is UpgradeEffectAddBuffedChance:
		var e: UpgradeEffectAddBuffedChance = effect as UpgradeEffectAddBuffedChance
		cell_manager.add_buffed_chance(e.cell_name, e.amount)
	else:
		push_error("UpgradeApplier: unhandled effect type %s" % effect.get_class())
