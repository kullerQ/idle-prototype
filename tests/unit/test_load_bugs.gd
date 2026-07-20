extends TestCase


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


func _count_special_spawn_timers(timer_manager: TimerManager) -> int:
	var count: int = 0
	for timer in timer_manager.timers[TimerManager.Types.CELL_SPAWN]:
		if timer == timer_manager._default_wood_timer:
			continue
		count += 1
	return count


func test_load_does_not_duplicate_special_spawn_timers() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var upgrade_manager: UpgradeManager = _make_upgrade_manager(tree)

	upgrade_manager._levels[UpgradeManager.Types.UNLOCK_LUMBERJACK] = 1
	upgrade_manager.applier.apply(
		upgrade_manager._definitions[UpgradeManager.Types.UNLOCK_LUMBERJACK],
		1,
		false
	)
	assert_eq(_count_special_spawn_timers(upgrade_manager.timer_manager), 1)

	upgrade_manager.load_from_dict({"UNLOCK_LUMBERJACK": 1})
	assert_eq(_count_special_spawn_timers(upgrade_manager.timer_manager), 1)


func test_load_restores_lumberjack_and_outpost_timers() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var upgrade_manager: UpgradeManager = _make_upgrade_manager(tree)

	upgrade_manager.load_from_dict({
		"UNLOCK_LUMBERJACK": 1,
		"UNLOCK_OUTPOST": 1,
	})

	var timer_manager: TimerManager = upgrade_manager.timer_manager
	assert_true(timer_manager.get_special_cell_timer(CellManager.Names.SPECIAL_LUMBERJACK) != null)
	assert_true(timer_manager.get_special_cell_timer(CellManager.Names.SPECIAL_OUTPOST) != null)
	assert_eq(_count_special_spawn_timers(timer_manager), 2)


func test_sync_free_cells_from_economy() -> void:
	var manager: PlayerCellManager = PlayerCellManager.new()
	manager.columns = 5
	manager.start_pos = Vector2i(4, 6)
	manager.all_data[PlayerCellData.Types.NULL] = preload(
		"res://data/player_cells/player_cell_empty.tres"
	).duplicate()
	manager.all_data[PlayerCellData.Types.SHOOTER] = preload(
		"res://data/player_cells/player_cell_shooter.tres"
	).duplicate()

	var occupied: PlayerCell = PlayerCell.new()
	var empty: PlayerCell = PlayerCell.new()
	manager.cells[manager.start_pos] = occupied
	manager.cells[manager.start_pos + Vector2i(-1, 0)] = empty
	occupied.data = manager.all_data[PlayerCellData.Types.SHOOTER]
	empty.data = manager.all_data[PlayerCellData.Types.NULL]

	var economy: Economy = Economy.new()
	economy.set_resource(Economy.Currencies.FREE_CELLS, 1)

	manager.free_cells.clear()
	manager.sync_free_cells_from_economy(economy)

	assert_eq(manager.free_cells.size(), 1)
	assert_eq(economy.get_resource(Economy.Currencies.FREE_CELLS), 1)
	assert_eq(manager.free_cells[0], empty)
