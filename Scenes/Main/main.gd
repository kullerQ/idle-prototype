extends Node2D
class_name Main

@onready var tree: SceneTree = get_tree()


func _enter_tree():
	G.initialize()
	Engine.time_scale = 1


func _input(event):
	if !(event is InputEventKey && event.is_pressed() && !event.echo):
		return

	if event.is_action_pressed("quit"):
		tree.quit()
		return

	if !OS.is_debug_build():
		return

	if event.is_action_pressed("debug_reload"):
		tree.reload_current_scene()
	elif event.is_action_pressed("debug_timescale"):
		Engine.time_scale = 1.0 if Engine.time_scale != 1.0 else 4.0
	elif event.is_action_pressed("debug_spawn_wood"):
		G.cell_manager.add_resource_at_global(get_global_mouse_position(), CellManager.Names.WOOD_FOREST)
	elif event.is_action_pressed("debug_spawn_obelisk"):
		G.cell_manager.add_resource_at_global(get_global_mouse_position(), CellManager.Names.SPECIAL_DRUID_OBELISK)
	elif event.is_action_pressed("debug_toggle_weakened"):
		var cell: CellResource = G.cell_manager.get_cell_from_global_pos(get_global_mouse_position())
		cell.set_effect(EffectManager.Effects.WEAKENED, !cell.is_weakened())
	elif event.is_action_pressed("debug_spawn_wood_batch"):
		var m: CellManager = G.cell_manager
		for i in range(10):
			m.add_rand_resource(CellManager.Types.WOOD)
	elif event.is_action_pressed("debug_free_cell"):
		G.cell_manager.free_cell_at_global(get_global_mouse_position())
	elif event.is_action_pressed("debug_kill_grid"):
		G.cell_manager.kill_grid()
	elif event.is_action_pressed("debug_add_free_cell"):
		G.player_cell_manager.add_free_cell()
	elif event.is_action_pressed("debug_add_shooter"):
		G.player_cell_manager.add_tower(PlayerCellData.Types.SHOOTER)
	elif event.is_action_pressed("debug_add_rogue"):
		G.player_cell_manager.add_tower(PlayerCellData.Types.ROGUE)
	elif event.is_action_pressed("debug_add_wizard"):
		G.player_cell_manager.add_tower(PlayerCellData.Types.WIZARD)
	elif event.is_action_pressed("debug_add_druid"):
		G.player_cell_manager.add_tower(PlayerCellData.Types.DRUID)
	elif event.is_action_pressed("debug_add_executioner"):
		G.player_cell_manager.add_tower(PlayerCellData.Types.EXECUTIONER)
	elif event.is_action_pressed("debug_cell_level_up"):
		var cell: PlayerCell = G.player_cell_manager.highlighted_cell
		if cell:
			cell.add_lvl()
	elif event.is_action_pressed("debug_toggle_cell_disabled"):
		var cell: PlayerCell = G.player_cell_manager.highlighted_cell
		if cell:
			cell.disabled = !cell.disabled
	elif event.is_action_pressed("debug_expedition_toggle"):
		if !G.expedition_manager.is_active:
			G.expedition_manager.select_expedition(ExpeditionManager.Types.WHITE_TREE, 1)
		else:
			G.expedition_manager.complete_expedition()
	elif event.is_action_pressed("debug_layout_base"):
		G.ui_layout_change_requested.emit(UIPP.Layouts.BASE)
	elif event.is_action_pressed("debug_layout_expedition"):
		G.ui_layout_change_requested.emit(UIPP.Layouts.EXPEDITION)
	elif event.is_action_pressed("debug_save_test"):
		var state: RunState = RunState.new()
		state.snapshot_economy(G.economy)
		state.snapshot_upgrades(G.upgrade_manager)
		state.snapshot_tower_grid(G.player_cell_manager)
		SaveService.save_to_file(state.to_dict())
		print("Saved: ", state.to_dict())
	elif event.is_action_pressed("debug_load_test"):
		var loaded: Dictionary = SaveService.load_from_file()
		if loaded.is_empty():
			print("No save file found")
		else:
			var state: RunState = RunState.from_dict(loaded)
			state.restore_all(G.upgrade_manager, G.player_cell_manager, G.economy)
			var upgrade_menu: UpgradeMenu = G.ui.get_node("CanvasLayer/UpgradeMenu")
			upgrade_menu.sync_levels_from(G.upgrade_manager)
			print("Loaded: ", loaded)
