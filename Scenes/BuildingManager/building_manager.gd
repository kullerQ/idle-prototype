extends VBoxContainer
class_name BuildingManager

enum Buildings {
	NULL,
	LUMBERJACK,
}

const _DATA_LUMBERJACK: BuildingData = preload("res://Resources/building_cell_lumberjack.tres")

var all_data: Dictionary = {
	Buildings.LUMBERJACK: _DATA_LUMBERJACK.duplicate()
}
var cells: Dictionary = {}
var economy: Economy


func _ready() -> void:
	for i in range(1, Buildings.size()):
		var cell: BuildingCell = get_child(i - 1)
		cell.economy = economy
		cells[i] = cell


func set_automated(type: Buildings, enabled: bool) -> void:
	if enabled:
		cells[type].automate()


func add_building(type: Buildings) -> void:
	cells[type].set_data(all_data[type])


func get_data(type: Buildings) -> BuildingData:
	return all_data[type]


func add_production(type: Buildings, currency: Economy.Currencies, value: int) -> void:
	all_data[type].production[currency] += value
