extends TestCase


func _make_test_cell() -> PlayerCell:
	var cell: PlayerCell = PlayerCell.new()
	cell.projectile_mod_data = ProjectileDataModifiers.new()
	cell.bonus_damage = DamageManager.new_damage_data(
		DamageManager.new_data(0, 0),
		DamageManager.new_data(0, 0)
	)
	return cell


func test_add_weakening_chance_effect() -> void:
	var cell: PlayerCell = _make_test_cell()
	var effect: LevelUpgradeEffectAddWeakeningChance = LevelUpgradeEffectAddWeakeningChance.new()
	effect.amount = 40

	effect.apply_to_cell(cell)

	assert_eq(cell.projectile_mod_data.weakening_chance, 40)


func test_add_cell_hit_damage_effect() -> void:
	var cell: PlayerCell = _make_test_cell()
	var effect: LevelUpgradeEffectAddCellHitDamage = LevelUpgradeEffectAddCellHitDamage.new()
	effect.amount = 10.0

	effect.apply_to_cell(cell)

	assert_eq(cell.bonus_damage[DamageManager.Types.HIT][DamageManager.Stats.HP], 10.0)


func test_remap_legacy_type_after_dead_enum_removal() -> void:
	assert_eq(LevelUpgradeManager.remap_legacy_type(17), LevelUpgradeManager.Types.DRUID_OVERHEAL_SPAWN_WEAK)
	assert_eq(LevelUpgradeManager.remap_legacy_type(24), LevelUpgradeManager.Types.DRUID_OBELISK_CHANCE)
	assert_eq(LevelUpgradeManager.remap_legacy_type(12), LevelUpgradeManager.Types.NULL)
	assert_eq(LevelUpgradeManager.remap_legacy_type(11), LevelUpgradeManager.Types.SHOOTER_DPS_DMG)


func test_level_upgrade_manager_loads_definitions() -> void:
	var manager := LevelUpgradeManager.new()
	manager.setup()

	assert_eq(
		manager.get_description(LevelUpgradeManager.Types.SHOOTER_SUPPORT),
		"40% chance to make a cell weakened on hit"
	)
	assert_eq(
		manager.get_description(LevelUpgradeManager.Types.DRUID_OBELISK_CHANCE),
		"+10% chance to add 1 druid obelisk if overheals"
	)

	for type_name in LevelUpgradeManager.Types.keys():
		if type_name == "NULL":
			continue
		var type: int = LevelUpgradeManager.Types[type_name]
		assert_true(
			manager.get_description(type) != "no description",
			"missing definition for %s" % type_name
		)
