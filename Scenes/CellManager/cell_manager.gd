extends GridContainer
class_name CellManager

var free_cells: Array = []
var all_data: Dictionary = {
	CellResourceData.Types.WOOD: load("uid://flg8f2dfjch1")
}

func _ready():
	free_cells = get_children()
	add_resource(CellResourceData.Types.WOOD)

func add_resource(type: CellResourceData.Types) -> void:
	if free_cells.is_empty():
		return
		
	free_cells.pick_random().set_data(all_data[type])

func free_cell(cell: CellResource) -> void:
	if free_cells.has(cell):
		return
		
	free_cells.append(cell)
	cell.set_disabled(true)
	

func occupy_cell(cell: CellResource) -> void:
	if !free_cells.has(cell):
		return
		
	free_cells.erase(cell)
