extends Node2D
class_name Game

func _enter_tree() -> void:
	var projectile_container: Node2D = Node2D.new()
	projectile_container.name = "ProjectileContainer"
	G.projectile_manager.projectile_container = projectile_container
	add_child(G.cell_manager)
	add_child(G.player_cell_manager)
	var timer_manager: TimerManager = G.timer_manager
	add_child(timer_manager)
	add_child(projectile_container)
	add_child(G.building_manager)
	var timer_ui: TimerUI = G.timer_ui
	add_child(timer_ui)
	timer_ui.setup_timers(timer_manager.timers)
	var particle_container: Node2D = Node2D.new()
	particle_container.name = "ParticleContainer"
	Bullet.particle_container = particle_container
	add_child(particle_container)
	
