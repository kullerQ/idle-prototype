extends Node2D
class_name Main

@onready var tree: SceneTree = get_tree()


func _enter_tree():
	G.initialize()
	Engine.time_scale = 1


func _input(event):
	if !(event is InputEventKey && event.is_pressed()):
		return

	if event.keycode == KEY_ESCAPE:
		tree.quit()
		return

	if !OS.is_debug_build():
		return

	match event.keycode:
	# programm stuff
		KEY_R:
			tree.reload_current_scene()
		KEY_4:
			if Engine.time_scale != 1:
				Engine.time_scale = 1
				return

			Engine.time_scale = 4
	# resource cells
		KEY_T:
			G.cell_manager.add_resource_at_global(get_global_mouse_position(), CellManager.Names.WOOD_FOREST)
		KEY_Z:
			G.cell_manager.add_resource_at_global(get_global_mouse_position(), CellManager.Names.SPECIAL_DRUID_OBELISK)
		KEY_B:
			var cell_manager: CellManager = G.cell_manager
			var cell: CellResource = cell_manager.get_cell_from_global_pos(get_global_mouse_position())
			cell.set_effect(EffectManager.Effects.WEAKENED, !cell.is_weakened())
		KEY_V:
			var cell_manager: CellManager = G.cell_manager
			var cell: CellResource = cell_manager.get_cell_from_global_pos(get_global_mouse_position())
			cell.set_effect(EffectManager.Effects.WEAKENED, !cell.is_weakened())
		KEY_5:
			var m: CellManager = G.cell_manager
			for i in range(10):
				m.add_rand_resource(CellManager.Types.WOOD)
		KEY_X:
			G.cell_manager.free_cell_at_global(get_global_mouse_position())

		KEY_K:
			G.cell_manager.kill_grid()

	# player cells
		KEY_1:
			G.player_cell_manager.add_free_cell()
		KEY_S:
			G.player_cell_manager.add_tower(PlayerCellData.Types.SHOOTER)
		KEY_A:
			G.player_cell_manager.add_tower(PlayerCellData.Types.ROGUE)
		KEY_W:
			G.player_cell_manager.add_tower(PlayerCellData.Types.WIZARD)
		KEY_D:
			G.player_cell_manager.add_tower(PlayerCellData.Types.DRUID)
		KEY_E:
			G.player_cell_manager.add_tower(PlayerCellData.Types.EXECUTIONER)
		KEY_C:
			var cell: PlayerCell = G.player_cell_manager.highlighted_cell
			if !cell:
				return

			cell.add_lvl()

		KEY_F1:
			var cell: PlayerCell = G.player_cell_manager.highlighted_cell
			if !cell:
				return

			cell.disabled = !cell.disabled

	# expeditions
		KEY_KP_1:
			if !G.in_expedition:
				G.expedition_manager.select_expedition(ExpeditionManager.Types.WHITE_TREE, 1)
				return

			G.expedition_manager.complete_expedition()

	# ui
		KEY_O:
			G.ui_layout_change_requested.emit(UIPP.Layouts.BASE)
		KEY_P:
			G.ui_layout_change_requested.emit(UIPP.Layouts.EXPEDITION)
