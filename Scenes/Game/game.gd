extends Node2D
class_name Game

## Runtime tree (created in G.initialize, parented here — not visible in the editor scene):
##   Game
##   ├── CellManager
##   ├── PlayerCellManager
##   ├── ExpeditionManager
##   ├── ProjectileContainer   ← G.projectile_manager.projectile_container
##   ├── BuildingManager
##   ├── ParticleContainer     ← Projectile.particle_container
##   ├── TimerManager
##   └── UIPPLayer
##       └── UIPP
##           ├── LevelUpgradeMenuLayer / ExpeditionMenuLayer
##           └── layout elements (TimerUI, ExpeditionUI)

const LEVEL_UPGRADE_MENU_SCENE: PackedScene = preload("res://Scenes/LevelUpgradeMenu/level_upgrade_menu.tscn")
const EXPEDITION_MENU_SCENE: PackedScene = preload("res://Scenes/ExpeditionMenu/expedition_menu.tscn")
const EXPEDITION_END_SCREEN_SCENE: PackedScene = preload("res://Scenes/ExpeditionEndScreen/expedition_end_screen.tscn")
const EXPEDITION_UI_SCENE: PackedScene = preload("res://Scenes/ExpeditionUI/expedition_ui.tscn")
const TIMER_UI_SCENE: PackedScene = preload("res://Scenes/TimerUI/timer_ui.tscn")


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
	
	var level_upgrade_menu: LevelUpgradeMenu = add_scene(LEVEL_UPGRADE_MENU_SCENE, "LevelUpgradeMenu", level_upgrade_menu_layer)
	level_upgrade_menu.manager = G.level_upgrade_manager
	
	var expedition_manager: ExpeditionManager = G.expedition_manager
	var expedition_menu: ExpeditionMenu = add_scene(EXPEDITION_MENU_SCENE, "ExpeditionMenu", expedition_menu_layer)
	var expedition_end_screen: ExpeditionEndScreen = add_scene(EXPEDITION_END_SCREEN_SCENE, "ExpeditionEndScreen", expedition_menu_layer)
	var expedition_ui: ExpeditionUI = new_scene(EXPEDITION_UI_SCENE, "ExpeditionUI") 
	expedition_ui.manager = expedition_manager
	expedition_end_screen.manager = expedition_manager
	
	var timer_ui = new_scene(TIMER_UI_SCENE, "TimerUI")
	timer_ui.initialize(G.timer_manager)
	
	uipp.add_element(timer_ui)
	uipp.add_element(expedition_ui)

	add_child(G.timer_manager)
	
	uipp.set_layout(UIPP.Layouts.BASE)
#	var expedition_ui = new_scene(EXPEDITION_UI_SCENE, "ExpeditionUI")
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
