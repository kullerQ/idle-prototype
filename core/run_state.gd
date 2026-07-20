class_name RunState

var data: Dictionary = {}
var economy_data: Dictionary = {}
var upgrades_data: Dictionary = {}
var tower_grid_data: Array = []


func to_dict() -> Dictionary:
	var result: Dictionary = data.duplicate()
	if !economy_data.is_empty():
		result["economy"] = economy_data.duplicate()
	if !upgrades_data.is_empty():
		result["upgrades"] = upgrades_data.duplicate()
	if !tower_grid_data.is_empty():
		result["tower_grid"] = tower_grid_data.duplicate(true)
	return result


static func from_dict(d: Dictionary) -> RunState:
	var state: RunState = RunState.new()
	state.data = d.duplicate()
	if d.has("economy"):
		state.economy_data = d["economy"].duplicate()
	if d.has("upgrades"):
		state.upgrades_data = d["upgrades"].duplicate()
	if d.has("tower_grid"):
		state.tower_grid_data = d["tower_grid"].duplicate(true)
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
