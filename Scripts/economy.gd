class_name Economy

enum Currencies {
	NULL,
	WOOD,
	FREE_CELLS,
	
}

var resources: Dictionary = {
	Currencies.WOOD: 0,
	Currencies.FREE_CELLS: 0,
}

signal res_changed(type: Currencies, value: int)

func get_resource(type: Currencies) -> int:
	return resources[type]

func add_resource(type: Currencies, amount: int) -> void:
	var new_v: int = resources[type] + amount
	set_resource(type, new_v)
	
func sub_resource_dict(dict: Dictionary, lvl: int) -> void:
	for i in dict:
		var v: int = dict[i][lvl]
		if v == 0:
			continue
			
		sub_resource(i, v)
	
func sub_resource(type: Currencies, amount: int) -> void:
	var new_v: int = resources[type] - amount
	set_resource(type, new_v)

func set_resource(type: Currencies, new_v: int) -> void:
	resources[type] = new_v
	res_changed.emit(type, new_v)
	
