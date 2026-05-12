extends Node2D
class_name Main

@onready var tree: SceneTree = get_tree()

func _enter_tree():
	G.initialize()
	Engine.time_scale = 1

func _input(event):
	if event is InputEventKey && event.is_pressed():
		match event.keycode:
	# programm stuff
			KEY_ESCAPE:
				tree.quit()
			KEY_R:
				tree.reload_current_scene()
			KEY_4:
				if Engine.time_scale != 1:
					Engine.time_scale = 1
					return
					
				Engine.time_scale = 4
	# resource cells
			KEY_T:
				G.cell_manager.add_resource_at_global(get_global_mouse_position(), CellManager.Names.WOOD_TREE)
			KEY_Z:
				G.cell_manager.add_resource_at_global(get_global_mouse_position(), CellManager.Names.SPECIAL_LUMBERJACK)
			KEY_5:
				var m: CellManager = G.cell_manager
				for i in range(10):
					m.add_rand_resource(CellManager.Types.WOOD)
			KEY_X:
				G.cell_manager.free_cell_at_global(get_global_mouse_position())
			
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
			KEY_C:
				var cell: PlayerCell = G.player_cell_manager.highlighted_cell
				if !cell:
					return
					
				cell.add_lvl()

				
