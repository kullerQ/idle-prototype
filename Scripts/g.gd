extends Node

var economy: Economy
var ui: UI
var upgrade_menu_opened: bool = false
var upgrade_manager: UpgradeManager
var player_cell_manager: PlayerCellManager
var cell_manager: CellManager
var timer_manager: TimerManager
var projectile_manager: ProjectileManager

signal upgrade_menu_open_requested
signal upgrade_menu_close_requested
signal tooltip_requested(text: String)
signal tooltip_close_required

func initialize() -> void:
	economy = Economy.new()
	CellResource.economy = economy
	UpgradeNode.economy = economy
	########################################
	upgrade_manager = UpgradeManager.new()
	UpgradeNode.upgrade_manager = upgrade_manager
	#||||||||||||||||||||||||||||||||||
	cell_manager = load("uid://b14oi7hhj8hew").instantiate()
	cell_manager.name = "CellManager"
	player_cell_manager = load("uid://ctck6suxq5bcj").instantiate()
	player_cell_manager.name = "PlauerCellManager"
	timer_manager = load("uid://bd2s6jemxrplh").instantiate()
	timer_manager.name = "TimerManager"
	#||||||||||||||||||||||||||||||||||
	upgrade_manager.cell_manager = cell_manager
	upgrade_manager.player_cell_manager = player_cell_manager
	upgrade_manager.timer_manager = timer_manager
	PlayerCell.manager = player_cell_manager
	TimerResource.cell_manager = cell_manager
	########################################
	projectile_manager = ProjectileManager.new()
	PlayerCell.projectile_manager = projectile_manager
	upgrade_manager.projectile_manager = projectile_manager
