extends Node

var economy: Economy
var damage_manager: DamageManager
var ui: UI
var upgrade_menu_opened: bool = false
var upgrade_manager: UpgradeManager
var player_cell_manager: PlayerCellManager
var cell_manager: CellManager
var timer_manager: TimerManager
var projectile_manager: ProjectileManager
var building_manager: BuildingManager
var timer_ui: TimerUI
var upgrades_highlight_label: Label
var lvl_upgrades_highlight_label: Label
var level_upgrade_manager: LevelUpgradeManager

signal upgrade_menu_open_requested
signal upgrade_menu_close_requested
signal tooltip_requested(text: String)
signal tooltip_close_required
signal crit_label_requested(pos: Vector2)
signal cell_hitted(type: CellManager.Types, _name: CellManager.Names)
signal player_cell_pressed(cell: PlayerCell)
signal level_upgrade_menu_close_requested
signal level_upgrade_menu_open_requested(cell: PlayerCell)

func initialize() -> void:
	upgrade_menu_opened = false
	########################################
	economy = Economy.new()
#	CellResource.economy = economy
	UpgradeNode.economy = economy
	BuildingCell.economy = economy
	########################################
	damage_manager = DamageManager.new()
	damage_manager.initialize()
	########################################
	cell_manager = load("uid://b14oi7hhj8hew").instantiate()
	cell_manager.name = "CellManager"
	cell_manager.economy = economy
	#
	player_cell_manager = load("uid://ctck6suxq5bcj").instantiate()
	player_cell_manager.name = "PlayerCellManager"
	player_cell_manager.economy = economy
	player_cell_manager.damage_manager = damage_manager
	#
	timer_manager = load("uid://bd2s6jemxrplh").instantiate()
	timer_manager.name = "TimerManager"
	timer_manager.cell_manager = cell_manager
	#
	building_manager = load("uid://4wswmpgy5skt").instantiate()
	building_manager.name = "BuildingManager"
	########################################
	upgrade_manager = UpgradeManager.new()
	upgrade_manager.cell_manager = cell_manager
	upgrade_manager.building_manager = building_manager
	upgrade_manager.player_cell_manager = player_cell_manager
	upgrade_manager.timer_manager = timer_manager
	upgrade_manager.damage_manager = damage_manager
	UpgradeNode.upgrade_manager = upgrade_manager
	#
	PlayerCell.manager = player_cell_manager
	TimerResource.cell_manager = cell_manager
	########################################
	projectile_manager = ProjectileManager.new()
	projectile_manager.damage_manager = damage_manager
	projectile_manager.cell_manager = cell_manager
	PlayerCell.projectile_manager = projectile_manager
	upgrade_manager.projectile_manager = projectile_manager
	########################################
	timer_ui = load("uid://cd2muxujuqyi3").instantiate()
	timer_ui.name = "TimerUI"
	timer_ui.initialize(timer_manager)
	########################################
	level_upgrade_manager = LevelUpgradeManager.new()
	
	Axe.bounce = false
