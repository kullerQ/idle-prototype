extends Node2D
class_name Main

@onready var tree: SceneTree = get_tree()

func _enter_tree():
	G.initialize()
	Engine.time_scale = 1

#func _ready() -> void:
#	G.economy.set_resource(Economy.Currencies.WOOD, 500)

func _input(event):
	if event is InputEventKey && event.is_pressed():
		match event.keycode:
			KEY_ESCAPE:
				tree.quit()
			KEY_R:
				tree.reload_current_scene()
			KEY_T:
				G.cell_manager.add_resource(CellManager.Names.SPECIAL_LUMBERJACK)
			KEY_4:
				Engine.time_scale = 32
			KEY_5:
				var m: CellManager = G.cell_manager
				for i in range(10):
					m.add_rand_resource(CellManager.Types.WOOD)
			KEY_X:
				G.cell_manager.free_cell_at_global(get_global_mouse_position())
