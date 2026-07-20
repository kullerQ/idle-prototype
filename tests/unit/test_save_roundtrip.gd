extends TestCase
## Save/load round-trips through Economy, UpgradeManager, and RunState.restore_all.


func _make_upgrade_manager(tree: SceneTree) -> UpgradeManager:
	var timer_manager: TimerManager = TimerManager.new()
	tree.root.add_child(timer_manager)

	var cell_manager: CellManager = CellManager.new()
	var player_cell_manager: PlayerCellManager = PlayerCellManager.new()
	var building_manager: BuildingManager = BuildingManager.new()
	var projectile_manager: ProjectileManager = ProjectileManager.new()
	var damage_manager: DamageManager = DamageManager.new()
	damage_manager.initialize()

	var upgrade_manager: UpgradeManager = UpgradeManager.new()
	upgrade_manager.cell_manager = cell_manager
	upgrade_manager.timer_manager = timer_manager
	upgrade_manager.player_cell_manager = player_cell_manager
	upgrade_manager.building_manager = building_manager
	upgrade_manager.projectile_manager = projectile_manager
	upgrade_manager.damage_manager = damage_manager
	upgrade_manager.setup()
	return upgrade_manager


func test_economy_save_roundtrip() -> void:
	var economy: Economy = Economy.new()
	economy.set_resource(Economy.Currencies.WOOD, 150)
	economy.set_resource(Economy.Currencies.FREE_CELLS, 2)
	economy.set_resource(Economy.Currencies.XP, 40)

	var restored: Economy = Economy.new()
	restored.load_from_dict(economy.to_save_dict())

	assert_eq(restored.get_resource(Economy.Currencies.WOOD), 150)
	assert_eq(restored.get_resource(Economy.Currencies.FREE_CELLS), 2)
	assert_eq(restored.get_resource(Economy.Currencies.XP), 40)


func test_upgrade_levels_save_roundtrip_applies_modifiers() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var upgrade_manager: UpgradeManager = _make_upgrade_manager(tree)
	var cell_manager: CellManager = upgrade_manager.cell_manager

	var baseline_durability: int = cell_manager.get_data(CellManager.Names.WOOD_TREE).durability
	var baseline_break: int = cell_manager.get_data(CellManager.Names.WOOD_TREE).break_value

	upgrade_manager._levels[UpgradeManager.Types.TREE_DURABILITY] = 2
	upgrade_manager.applier.apply(
		upgrade_manager._definitions[UpgradeManager.Types.TREE_DURABILITY],
		2,
		false
	)

	var saved: Dictionary = upgrade_manager.to_save_dict()
	assert_eq(saved.get("TREE_DURABILITY"), 2)

	upgrade_manager.load_from_dict(saved)

	assert_eq(upgrade_manager.get_level(UpgradeManager.Types.TREE_DURABILITY), 2)
	assert_eq(
		cell_manager.get_data(CellManager.Names.WOOD_TREE).durability,
		baseline_durability + 40
	)
	assert_eq(
		cell_manager.get_data(CellManager.Names.WOOD_TREE).break_value,
		baseline_break + 20
	)


func test_run_state_restore_all_preserves_economy_and_upgrades() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var upgrade_manager: UpgradeManager = _make_upgrade_manager(tree)
	var player_cell_manager: PlayerCellManager = upgrade_manager.player_cell_manager
	var economy: Economy = Economy.new()
	player_cell_manager.economy = economy

	economy.set_resource(Economy.Currencies.WOOD, 99)
	economy.set_resource(Economy.Currencies.XP, 7)
	upgrade_manager._levels[UpgradeManager.Types.TREE_DURABILITY] = 1
	upgrade_manager.applier.apply(
		upgrade_manager._definitions[UpgradeManager.Types.TREE_DURABILITY],
		1,
		false
	)

	var state: RunState = RunState.new()
	state.snapshot_economy(economy)
	state.snapshot_upgrades(upgrade_manager)
	state.snapshot_tower_grid(player_cell_manager)

	economy.set_resource(Economy.Currencies.WOOD, 0)
	economy.set_resource(Economy.Currencies.XP, 0)
	upgrade_manager._levels.clear()

	state.restore_all(upgrade_manager, player_cell_manager, economy)

	assert_eq(economy.get_resource(Economy.Currencies.WOOD), 99)
	assert_eq(economy.get_resource(Economy.Currencies.XP), 7)
	assert_eq(upgrade_manager.get_level(UpgradeManager.Types.TREE_DURABILITY), 1)
