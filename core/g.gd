extends Node

## Thin autoload: service locator + menu / tooltip / crit-label UI bus.
## Game parents Node managers; G only holds refs and wires deps.

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

var opened_menu_type: UI.Menus = 0

signal upgrade_menu_open_requested
signal upgrade_menu_close_requested
signal expedition_menu_open_requested
signal expedition_menu_close_requested
signal expedition_end_open_requested
signal expedition_end_close_requested
signal tooltip_requested(text: String)
signal tooltip_close_required
signal crit_label_requested(pos: Vector2)
signal level_upgrade_menu_close_requested
signal level_upgrade_menu_open_requested(cell: PlayerCell)
signal ui_layout_change_requested(new_layout: UIPP.Layouts)


## Creates RefCounted core systems. Node managers come from Game's scene tree
## via bind_scene_managers (called from Game._enter_tree).
func initialize() -> void:
	_create_economy()
	_create_combat()


## Wires scene-placed managers and creates RefCounted dependents.
func bind_scene_managers(
	p_cell_manager: CellManager,
	p_player_cell_manager: PlayerCellManager,
	p_timer_manager: TimerManager,
	p_building_manager: BuildingManager,
	p_expedition_manager: ExpeditionManager,
) -> void:
	cell_manager = p_cell_manager
	cell_manager.economy = economy
	cell_manager.expedition_manager = p_expedition_manager
	cell_manager.projectile_manager = projectile_manager
	projectile_manager.cell_manager = cell_manager

	player_cell_manager = p_player_cell_manager
	player_cell_manager.economy = economy
	player_cell_manager.damage_manager = damage_manager
	player_cell_manager.cell_manager = cell_manager
	player_cell_manager.projectile_manager = projectile_manager

	timer_manager = p_timer_manager
	timer_manager.cell_manager = cell_manager
	timer_manager.expedition_manager = p_expedition_manager

	building_manager = p_building_manager
	building_manager.economy = economy

	expedition_manager = p_expedition_manager
	expedition_manager.economy = economy
	expedition_manager.cell_manager = cell_manager
	expedition_manager.projectile_manager = projectile_manager
	expedition_manager.timer_manager = timer_manager

	_wire_upgrades()
	_assert_wired()


func _create_economy() -> void:
	economy = Economy.new()


func _create_combat() -> void:
	damage_manager = DamageManager.new()
	damage_manager.initialize()

	projectile_manager = ProjectileManager.new()
	projectile_manager.damage_manager = damage_manager


func _wire_upgrades() -> void:
	upgrade_manager = UpgradeManager.new()
	upgrade_manager.cell_manager = cell_manager
	upgrade_manager.building_manager = building_manager
	upgrade_manager.player_cell_manager = player_cell_manager
	upgrade_manager.timer_manager = timer_manager
	upgrade_manager.damage_manager = damage_manager
	upgrade_manager.projectile_manager = projectile_manager
	upgrade_manager.setup()

	level_upgrade_manager = LevelUpgradeManager.new()
	level_upgrade_manager.player_cell_manager = player_cell_manager
	player_cell_manager.level_upgrade_manager = level_upgrade_manager


func _assert_wired() -> void:
	if !OS.is_debug_build():
		return

	assert(economy != null, "G.economy not wired")
	assert(damage_manager != null, "G.damage_manager not wired")
	assert(projectile_manager != null, "G.projectile_manager not wired")
	assert(cell_manager != null, "G.cell_manager not wired")
	assert(player_cell_manager != null, "G.player_cell_manager not wired")
	assert(timer_manager != null, "G.timer_manager not wired")
	assert(building_manager != null, "G.building_manager not wired")
	assert(upgrade_manager != null, "G.upgrade_manager not wired")
	assert(upgrade_manager.applier != null, "UpgradeManager.applier not setup")
	assert(level_upgrade_manager != null, "G.level_upgrade_manager not wired")
	assert(expedition_manager != null, "G.expedition_manager not wired")
	assert(cell_manager.economy != null, "CellManager.economy not wired")
	assert(cell_manager.expedition_manager != null, "CellManager.expedition_manager not wired")
	assert(cell_manager.projectile_manager != null, "CellManager.projectile_manager not wired")
	assert(player_cell_manager.economy != null, "PlayerCellManager.economy not wired")
	assert(player_cell_manager.damage_manager != null, "PlayerCellManager.damage_manager not wired")
	assert(player_cell_manager.cell_manager != null, "PlayerCellManager.cell_manager not wired")
	assert(player_cell_manager.projectile_manager != null, "PlayerCellManager.projectile_manager not wired")
	assert(projectile_manager.cell_manager != null, "ProjectileManager.cell_manager not wired")
	assert(projectile_manager.damage_manager != null, "ProjectileManager.damage_manager not wired")
	assert(timer_manager.cell_manager != null, "TimerManager.cell_manager not wired")
	assert(timer_manager.expedition_manager != null, "TimerManager.expedition_manager not wired")
	assert(building_manager.economy != null, "BuildingManager.economy not wired")
	assert(expedition_manager.economy != null, "ExpeditionManager.economy not wired")
	assert(expedition_manager.cell_manager != null, "ExpeditionManager.cell_manager not wired")
	assert(expedition_manager.projectile_manager != null, "ExpeditionManager.projectile_manager not wired")
	assert(expedition_manager.timer_manager != null, "ExpeditionManager.timer_manager not wired")
	assert(level_upgrade_manager.player_cell_manager != null, "LevelUpgradeManager.player_cell_manager not wired")
	assert(player_cell_manager.level_upgrade_manager != null, "PlayerCellManager.level_upgrade_manager not wired")


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
