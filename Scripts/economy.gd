class_name Economy

var resources: Dictionary = {
	CellResourceData.Types.WOOD: 0
}

signal res_changed(type: CellResourceData.Types, value: int)

func get_resource(type: CellResourceData.Types) -> int:
	return resources[type]

func add_resource(type: CellResourceData.Types, amount: int) -> void:
	var new_v: int = resources[type] + amount
	set_resource(type, new_v)
	
func sub_resource(type: CellResourceData.Types, amount: int) -> void:
	var new_v: int = resources[type] - amount
	set_resource(type, new_v)

func set_resource(type: CellResourceData.Types, new_v: int) -> void:
	resources[type] = new_v
	res_changed.emit(type, new_v)
	
