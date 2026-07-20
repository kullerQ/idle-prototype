class_name UpgradeApplier
## Applies UpgradeDefinition effects through existing manager mutator APIs.
## Add new effect branches here when a new UpgradeEffect subclass appears.

var cell_manager: CellManager
var timer_manager: TimerManager
var player_cell_manager: PlayerCellManager
var building_manager: BuildingManager
var projectile_manager: ProjectileManager
var damage_manager: DamageManager


func apply(def: UpgradeDefinition, times: int = 1) -> void:
	for _i in times:
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
	elif effect is UpgradeEffectAddSpecialCellSpawnTimer:
		var e: UpgradeEffectAddSpecialCellSpawnTimer = effect as UpgradeEffectAddSpecialCellSpawnTimer
		var cell_name: CellManager.Names = e.cell_name as CellManager.Names
		timer_manager.add_special_cell_spawn_timer(
			cell_name,
			cell_manager.get_data(cell_name).life_time,
			e.color
		)
	elif effect is UpgradeEffectMultiplyCellLifeTime:
		var e: UpgradeEffectMultiplyCellLifeTime = effect as UpgradeEffectMultiplyCellLifeTime
		cell_manager.multiply_life_time(e.cell_name as CellManager.Names, e.factor)
	elif effect is UpgradeEffectSetBuildingAutomated:
		var e: UpgradeEffectSetBuildingAutomated = effect as UpgradeEffectSetBuildingAutomated
		building_manager.set_automated(e.building_type as BuildingManager.Buildings, e.enabled)
	elif effect is UpgradeEffectAddBuildingCooldown:
		var e: UpgradeEffectAddBuildingCooldown = effect as UpgradeEffectAddBuildingCooldown
		building_manager.add_cooldown(e.building_type as BuildingManager.Buildings, e.amount)
	elif effect is UpgradeEffectAddBuildingProduction:
		var e: UpgradeEffectAddBuildingProduction = effect as UpgradeEffectAddBuildingProduction
		building_manager.add_production(
			e.building_type as BuildingManager.Buildings,
			e.currency as Economy.Currencies,
			e.value
		)
	elif effect is UpgradeEffectAddBuildingChargePerHit:
		var e: UpgradeEffectAddBuildingChargePerHit = effect as UpgradeEffectAddBuildingChargePerHit
		building_manager.add_charge_per_hit(e.building_type as BuildingManager.Buildings, e.amount)
	elif effect is UpgradeEffectAddLumberjackCrit:
		var e: UpgradeEffectAddLumberjackCrit = effect as UpgradeEffectAddLumberjackCrit
		cell_manager.add_lumberjack_crit(e.amount)
	elif effect is UpgradeEffectAddLumberjackDmgRatio:
		var e: UpgradeEffectAddLumberjackDmgRatio = effect as UpgradeEffectAddLumberjackDmgRatio
		cell_manager.add_lumberjack_dmg_ratio(e.amount)
	elif effect is UpgradeEffectAddLumberjackSpawnWoodChance:
		var e: UpgradeEffectAddLumberjackSpawnWoodChance = effect as UpgradeEffectAddLumberjackSpawnWoodChance
		cell_manager.add_lumberjack_spawn_wood_chance(e.amount)
	elif effect is UpgradeEffectAddOutpostWeakeningChance:
		var e: UpgradeEffectAddOutpostWeakeningChance = effect as UpgradeEffectAddOutpostWeakeningChance
		cell_manager.add_outpost_weakening_chance(e.amount)
	elif effect is UpgradeEffectAddOutpostAttacks:
		var e: UpgradeEffectAddOutpostAttacks = effect as UpgradeEffectAddOutpostAttacks
		cell_manager.add_outpost_attacks(e.amount)
	elif effect is UpgradeEffectAddProjectileDamage:
		var e: UpgradeEffectAddProjectileDamage = effect as UpgradeEffectAddProjectileDamage
		damage_manager.add_flat_damage_bonus(e.projectile_type as ProjectileManager.Types, e.amount)
	elif effect is UpgradeEffectAddProjectileSpd:
		var e: UpgradeEffectAddProjectileSpd = effect as UpgradeEffectAddProjectileSpd
		projectile_manager.add_spd(e.projectile_type as ProjectileManager.Types, e.amount)
	elif effect is UpgradeEffectAddProjectileMaxRange:
		var e: UpgradeEffectAddProjectileMaxRange = effect as UpgradeEffectAddProjectileMaxRange
		projectile_manager.add_max_range(e.projectile_type as ProjectileManager.Types, e.amount)
	elif effect is UpgradeEffectAddProjectileMaxPiercings:
		var e: UpgradeEffectAddProjectileMaxPiercings = effect as UpgradeEffectAddProjectileMaxPiercings
		projectile_manager.add_max_piercings(e.projectile_type as ProjectileManager.Types, e.amount)
	elif effect is UpgradeEffectSetProjectileBounce:
		var e: UpgradeEffectSetProjectileBounce = effect as UpgradeEffectSetProjectileBounce
		projectile_manager.set_bounce(e.projectile_type as ProjectileManager.Types, e.enabled)
	elif effect is UpgradeEffectSetProjectileBackstab:
		var e: UpgradeEffectSetProjectileBackstab = effect as UpgradeEffectSetProjectileBackstab
		projectile_manager.set_backstab(e.projectile_type as ProjectileManager.Types, e.enabled)
	elif effect is UpgradeEffectAddProjectileBackstabBonusDmg:
		var e: UpgradeEffectAddProjectileBackstabBonusDmg = effect as UpgradeEffectAddProjectileBackstabBonusDmg
		projectile_manager.add_backstab_bonus_dmg(e.projectile_type as ProjectileManager.Types, e.amount)
	else:
		push_error("UpgradeApplier: unhandled effect type %s" % effect.get_class())
