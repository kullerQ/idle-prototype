extends Node2D
class_name Game

func _enter_tree() -> void:
	var projectile_container: Node2D = Node2D.new()
	projectile_container.name = "ProjectileContainer"
	G.projectile_manager.projectile_container = projectile_container
	add_child(G.cell_manager)
	add_child(G.player_cell_manager)
	add_child(G.timer_manager)
	add_child(projectile_container)
