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
	elif effect is UpgradeEffectAddFreeTowerCell:
		player_cell_manager.add_free_cell()
	elif effect is UpgradeEffectAddTower:
		var e: UpgradeEffectAddTower = effect as UpgradeEffectAddTower
		player_cell_manager.add_tower(e.tower_type as PlayerCellData.Types)
	elif effect is UpgradeEffectAddTowerCooldown:
		var e: UpgradeEffectAddTowerCooldown = effect as UpgradeEffectAddTowerCooldown
		player_cell_manager.add_cooldown(e.tower_type as PlayerCellData.Types, e.amount)
	elif effect is UpgradeEffectAddTowerAccuracy:
		var e: UpgradeEffectAddTowerAccuracy = effect as UpgradeEffectAddTowerAccuracy
		player_cell_manager.add_accuracy(e.tower_type as PlayerCellData.Types, e.amount)
	elif effect is UpgradeEffectAddTowerCritChance:
		var e: UpgradeEffectAddTowerCritChance = effect as UpgradeEffectAddTowerCritChance
		player_cell_manager.add_crit_chance(e.tower_type as PlayerCellData.Types, e.amount)
	elif effect is UpgradeEffectAddTowerCritMult:
		var e: UpgradeEffectAddTowerCritMult = effect as UpgradeEffectAddTowerCritMult
		player_cell_manager.add_crit_mult(e.tower_type as PlayerCellData.Types, e.amount)
	elif effect is UpgradeEffectAddTowerXpIncrease:
		var e: UpgradeEffectAddTowerXpIncrease = effect as UpgradeEffectAddTowerXpIncrease
		player_cell_manager.add_xp_increase(e.tower_type as PlayerCellData.Types, e.amount)
	else:
		push_error("UpgradeApplier: unhandled effect type %s" % effect.get_class())
