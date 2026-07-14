extends Node

var menu_signals: Dictionary = {
	UI.Menus.UPGRADE: [upgrade_menu_open_requested, upgrade_menu_close_requested],
	UI.Menus.EXPEDITION: [expedition_menu_open_requested, expedition_menu_close_requested],
	UI.Menus.EXPEDITION_END: [expedition_end_open_requested, expedition_end_close_requested],
}

var economy: Economy
var damage_manager: DamageManager
var ui: UI
var uipp: UIPP
var upgrade_manager: UpgradeManager
var player_cell_manager: PlayerCellManager
var timer_manager: TimerManager
var cell_manager: CellManager
var projectile_manager: ProjectileManager
var building_manager: BuildingManager
var level_upgrade_manager: LevelUpgradeManager
var expedition_manager: ExpeditionManager
var upgrades_highlight_label: Label
var lvl_upgrades_highlight_label: Label

var opened_menu_type: UI.Menus = 0
var in_expedition: bool = false

signal upgrade_menu_open_requested
signal upgrade_menu_close_requested
signal expedition_menu_open_requested
signal expedition_menu_close_requested
signal expedition_end_open_requested
signal expedition_end_close_requested
signal tooltip_requested(text: String)
signal tooltip_close_required
signal crit_label_requested(pos: Vector2)
signal cell_hitted(type: CellManager.Types, _name: CellManager.Names)
signal player_cell_pressed(cell: PlayerCell)
signal level_upgrade_menu_close_requested
signal level_upgrade_menu_open_requested(cell: PlayerCell)
signal ui_layout_change_requested(new_layout: UIPP.Layouts)

func initialize() -> void:
	economy = Economy.new()

	UpgradeNode.economy = economy
	BuildingCell.economy = economy

	damage_manager = DamageManager.new()
	damage_manager.initialize()

	cell_manager = load("uid://b14oi7hhj8hew").instantiate()
	cell_manager.name = "CellManager"
	cell_manager.economy = economy
	
	player_cell_manager = load("uid://ctck6suxq5bcj").instantiate()
	player_cell_manager.name = "PlayerCellManager"
	player_cell_manager.economy = economy
	player_cell_manager.damage_manager = damage_manager
	player_cell_manager.cell_manager = cell_manager

	timer_manager = load("uid://bd2s6jemxrplh").instantiate()
	timer_manager.name = "TimerManager"
	timer_manager.cell_manager = cell_manager
	
	building_manager = load("uid://4wswmpgy5skt").instantiate()
	building_manager.name = "BuildingManager"

	upgrade_manager = UpgradeManager.new()
	upgrade_manager.cell_manager = cell_manager
	upgrade_manager.building_manager = building_manager
	upgrade_manager.player_cell_manager = player_cell_manager
	upgrade_manager.timer_manager = timer_manager
	upgrade_manager.damage_manager = damage_manager
	UpgradeNode.upgrade_manager = upgrade_manager
	
	PlayerCell.manager = player_cell_manager
	TimerResource.cell_manager = cell_manager
	
	projectile_manager = ProjectileManager.new()
	projectile_manager.damage_manager = damage_manager
	projectile_manager.cell_manager = cell_manager
	PlayerCell.projectile_manager = projectile_manager
	upgrade_manager.projectile_manager = projectile_manager

	level_upgrade_manager = LevelUpgradeManager.new()

	expedition_manager = ExpeditionManager.new()
	expedition_manager.name = "ExpeditionManager"
	expedition_manager.cell_manager = cell_manager
	expedition_manager.projectile_manager = projectile_manager
	expedition_manager.timer_manager = timer_manager
	ExpeditionButton.manager = expedition_manager


	Axe.bounce = false

func toggle_menu(menu_type: UI.Menus) -> void:
	if opened_menu_type:
		if opened_menu_type == menu_type:
			menu_signals[menu_type][1].emit() # close signal
			opened_menu_type = 0
			return
		else:
			menu_signals[opened_menu_type][1].emit() # close signal
	
	menu_signals[menu_type][0].emit() # open signal
	opened_menu_type = menu_type

func open_menu(menu_type: UI.Menus) -> void:
	if opened_menu_type == menu_type:
		return
	
	menu_signals[menu_type][0].emit() # open signal
	opened_menu_type = menu_type	

func close_menu(menu_type: UI.Menus) -> void:
	if opened_menu_type != menu_type:
		return
	
	menu_signals[opened_menu_type][1].emit() # close signal
	opened_menu_type = 0
