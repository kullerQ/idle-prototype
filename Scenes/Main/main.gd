extends Node2D
class_name Main

@onready var tree: SceneTree = get_tree()

func _enter_tree():
	G.initialize()

func _ready() -> void:
	G.economy.set_resource(CellResourceData.Types.WOOD, 1000)

func _input(event):
	if event is InputEventKey && event.is_pressed():
		match event.keycode:
			KEY_ESCAPE:
				tree.quit()
			KEY_R:
				tree.reload_current_scene()
