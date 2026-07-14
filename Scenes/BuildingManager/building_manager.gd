extends VBoxContainer
class_name BuildingManager

enum Buildings {
	NULL,
	LUMBERJACK,
}

var all_data: Dictionary = {
	Buildings.LUMBERJACK: load("uid://cns5x6t2lsryk").duplicate()
}
var cells: Dictionary = {}


func _ready() -> void:
	for i in range(1, Buildings.size()):
		cells[i] = get_child(i - 1)


func set_automated(type: Buildings, enabled: bool) -> void:
	if enabled:
		cells[type].automate()


func add_building(type: Buildings) -> void:
	cells[type].set_data(all_data[type])


func get_data(type: Buildings) -> BuildingData:
	return all_data[type]


func add_production(type: Buildings, currency: Economy.Currencies, value: int) -> void:
	all_data[type].production[currency] += value
