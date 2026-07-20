class_name RunState

const SAVE_VERSION: int = 1

const KEY_VERSION := "version"
const KEY_ECONOMY := "economy"
const KEY_UPGRADES := "upgrades"
const KEY_TOWER_GRID := "tower_grid"

var data: Dictionary = {}
var economy_data: Dictionary = {}
var upgrades_data: Dictionary = {}
var tower_grid_data: Array = []
var save_version: int = SAVE_VERSION


func to_dict() -> Dictionary:
	var result: Dictionary = data.duplicate()
	result[KEY_VERSION] = SAVE_VERSION
	result[KEY_ECONOMY] = economy_data.duplicate()
	result[KEY_UPGRADES] = upgrades_data.duplicate()
	result[KEY_TOWER_GRID] = tower_grid_data.duplicate(true)
	return result


static func from_dict(d: Dictionary) -> RunState:
	var state: RunState = RunState.new()
	state.save_version = int(d.get(KEY_VERSION, 0))
	if state.save_version > SAVE_VERSION:
		push_warning(
			"RunState: save version %d is newer than supported %d" % [state.save_version, SAVE_VERSION]
		)
	if d.has(KEY_ECONOMY):
		state.economy_data = d[KEY_ECONOMY].duplicate()
	if d.has(KEY_UPGRADES):
		state.upgrades_data = d[KEY_UPGRADES].duplicate()
	if d.has(KEY_TOWER_GRID):
		state.tower_grid_data = d[KEY_TOWER_GRID].duplicate(true)
	state.data = d.duplicate()
	for key in [KEY_VERSION, KEY_ECONOMY, KEY_UPGRADES, KEY_TOWER_GRID]:
		state.data.erase(key)
	return state


func snapshot_economy(economy: Economy) -> void:
	economy_data = economy.to_save_dict()


func restore_economy(economy: Economy) -> void:
	if !economy_data.is_empty():
		economy.load_from_dict(economy_data)


func snapshot_upgrades(upgrade_manager: UpgradeManager) -> void:
	upgrades_data = upgrade_manager.to_save_dict()


func restore_upgrades(upgrade_manager: UpgradeManager) -> void:
	if !upgrades_data.is_empty():
		upgrade_manager.load_from_dict(upgrades_data)


func snapshot_tower_grid(player_cell_manager: PlayerCellManager) -> void:
	tower_grid_data = player_cell_manager.to_save_dict()


func restore_tower_grid(player_cell_manager: PlayerCellManager) -> void:
	if !tower_grid_data.is_empty():
		player_cell_manager.load_from_dict(tower_grid_data)


## Load order matters: stat baseline + upgrades, then grid placements,
## then economy last so nothing mutates saved currency values.
func restore_all(upgrade_manager: UpgradeManager, player_cell_manager: PlayerCellManager, economy: Economy) -> void:
	restore_upgrades(upgrade_manager)
	restore_tower_grid(player_cell_manager)
	restore_economy(economy)
	player_cell_manager.sync_free_cells_from_economy(economy)


## Single entry for restoring a save into live managers (+ optional UI sync).
## managers keys: upgrade_manager, player_cell_manager, economy, upgrade_menu (optional).
func apply_to(managers: Dictionary) -> void:
	var upgrade_manager: UpgradeManager = managers.get("upgrade_manager")
	var player_cell_manager: PlayerCellManager = managers.get("player_cell_manager")
	var economy: Economy = managers.get("economy")
	if upgrade_manager == null or player_cell_manager == null or economy == null:
		push_error("RunState.apply_to: managers dict requires upgrade_manager, player_cell_manager, and economy")
		return
	restore_all(upgrade_manager, player_cell_manager, economy)
	var upgrade_menu: UpgradeMenu = managers.get("upgrade_menu")
	if upgrade_menu != null:
		upgrade_menu.sync_levels_from(upgrade_manager)
