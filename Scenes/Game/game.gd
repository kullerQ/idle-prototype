extends Node2D
class_name Game

func _enter_tree() -> void:
	add_child(G.cell_manager)
	add_child(G.player_cell_manager)
	add_child(G.expedition_manager)

	var projectile_container: Node2D = add_new_node(Node2D, "ProjectileContainer")
	G.projectile_manager.projectile_container = projectile_container

	add_child(G.building_manager)

	var particle_container: Node2D = add_new_node(Node2D, "ParticleContainer")
	Projectile.particle_container = particle_container

	var uipp_layer: CanvasLayer = add_new_node(CanvasLayer, "UIPPLayer")
	var uipp: UIPP = add_new_node(UIPP, "UIPP", uipp_layer)
	var level_upgrade_menu_layer: CanvasLayer = add_new_node(CanvasLayer, "LevelUpgradeMenuLayer", uipp)
	var expedition_menu_layer: CanvasLayer = add_new_node(CanvasLayer, "ExpeditionMenuLayer", uipp)
	
	var level_upgrade_menu: LevelUpgradeMenu = add_scene(load("uid://beki2ixvgfrwy"), "LevelUpgradeMenu", level_upgrade_menu_layer)
	level_upgrade_menu.manager = G.level_upgrade_manager
	
	var expedition_manager: ExpeditionManager = G.expedition_manager
	var expedition_menu: ExpeditionMenu = add_scene(load("uid://dihjhmgs3n5d1"), "ExpeditionMenu", expedition_menu_layer)
	var expedition_end_screen: ExpeditionEndScreen = add_scene(load("uid://cf0ulssjiksm4"), "ExpeditionEndScreen", expedition_menu_layer)
	var expedition_ui: ExpeditionUI = new_scene(load("uid://cjumk0owaxjey"), "ExpeditionUI") 
	expedition_ui.manager = expedition_manager
	expedition_end_screen.manager = expedition_manager
	
	var timer_ui = new_scene(load("uid://cd2muxujuqyi3"), "TimerUI")
	timer_ui.initialize(G.timer_manager)
	
	uipp.add_element(timer_ui)
	uipp.add_element(expedition_ui)

	add_child(G.timer_manager)
	
	uipp.set_layout(UIPP.Layouts.BASE)
#	var expedition_ui = new_scene(load("uid://cjumk0owaxjey"), "ExpeditionUI")
#	uipp.add_element(timer_ui)
	
func add_new_node(type: Variant, _name: String, parent: Node = self) -> Node:
	var node: Node = new_node(type, _name)
	parent.add_child(node)
	return node

func add_scene(scene: PackedScene, _name: String, parent: Node = self) -> Node:
	var node: Node = new_scene(scene, _name)
	parent.add_child(node)
	return node

func new_node(type: Variant, _name: String) -> Node:
	var node: Node = type.new()
	node.name = _name
	return node

func new_scene(scene: PackedScene, _name: String) -> Node:
	var node: Node = scene.instantiate()
	node.name = _name
	return node
	
