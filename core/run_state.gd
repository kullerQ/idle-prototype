class_name RunState

var data: Dictionary = {}
var economy_data: Dictionary = {}
var upgrades_data: Dictionary = {}


func to_dict() -> Dictionary:
	var result: Dictionary = data.duplicate()
	if !economy_data.is_empty():
		result["economy"] = economy_data.duplicate()
	if !upgrades_data.is_empty():
		result["upgrades"] = upgrades_data.duplicate()
	return result


static func from_dict(d: Dictionary) -> RunState:
	var state: RunState = RunState.new()
	state.data = d.duplicate()
	if d.has("economy"):
		state.economy_data = d["economy"].duplicate()
	if d.has("upgrades"):
		state.upgrades_data = d["upgrades"].duplicate()
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
