extends Node2D
class_name Game

func _enter_tree() -> void:
	
	add_child(G.cell_manager)
	add_child(G.player_cell_manager)
#	add_child(G.timer_ui)
	add_child(G.timer_manager)

	var projectile_container: Node2D = add_new_node(Node2D, "ProjectileContainer")
	G.projectile_manager.projectile_container = projectile_container

	add_child(G.building_manager)

	var particle_container: Node2D = add_new_node(Node2D, "ParticleContainer")
	Projectile.particle_container = particle_container

	var uipp_layer: CanvasLayer = add_new_node(CanvasLayer, "UIPPLayer")
	var uipp: UIPP = add_new_node(UIPP, "UIPP", uipp_layer)
	var level_upgrade_menu_layer: CanvasLayer = add_new_node(CanvasLayer, "LevelUpgradeMenuLayer", uipp)
	
	var level_upgrade_menu: LevelUpgradeMenu = add_scene(load("uid://c007jdbkuuhvx"), "LevelUpgradeMenu", level_upgrade_menu_layer)
	level_upgrade_menu.manager = G.level_upgrade_manager
	
	uipp.add_child(G.timer_ui)

func add_new_node(type: Variant, _name: String, parent: Node = self) -> Node:
	var node: Node = type.new()
	node.name = _name
	parent.add_child(node)
	return node

func add_scene(scene: PackedScene, _name: String, parent: Node = self) -> Node:
	var node: Node = scene.instantiate()
	node.name = _name
	parent.add_child(node)
	return node
	
