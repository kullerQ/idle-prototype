extends GridContainer
class_name CellManager

const CELL_SIZE: Vector2 = Vector2(16, 16)

var all_data: Dictionary = {
	Economy.Currencies.WOOD: load("uid://flg8f2dfjch1")
}
var cells: Dictionary = {}
var free_cells: Array = []
var occupied_cells: Array = [] 
var far_cells: Array

func _ready():
	free_cells = get_children()
	var pos: Vector2i = Vector2i.ZERO
	for c in get_children():
		cells[pos] = c
		if pos.x >= 7:
			far_cells.append(c)
			
		if pos.x + 1 == columns:
			pos.x = 0
			pos.y += 1
			continue
			
		pos.x += 1
	
	add_resource(Economy.Currencies.WOOD)
	add_resource(Economy.Currencies.WOOD)
#	add_resource_at(Vector2i(5,4), Economy.Currencies.WOOD)
#	add_resource_at(Vector2i(4,4), Economy.Currencies.WOOD)
	
func get_cell_global_pos(pos: Vector2i) -> Vector2:
	return cells[pos].global_position
	
func get_cell_global_center(pos: Vector2i) -> Vector2:
	return cells[pos].global_position + CELL_SIZE / 2
	
func get_rand_occupied_cell_global_center(exclude: CellResource = null) -> Vector2:
	if occupied_cells.is_empty():
		return Vector2.ZERO
	
	if exclude:
		var temp_occupied_cells = occupied_cells.duplicate()
		temp_occupied_cells.erase(exclude)
		if temp_occupied_cells.is_empty():
			return Vector2.ZERO
			
		return temp_occupied_cells.pick_random().global_position + CELL_SIZE / 2
	
		
	return occupied_cells.pick_random().global_position + CELL_SIZE / 2
	
func add_resource_at(pos: Vector2i, type: Economy.Currencies) -> void:
	var cell: CellResource = cells[pos]
	if !free_cells.has(cell):
		return
	
	cell.set_data(all_data[type])

func get_data(type: Economy.Currencies) -> CellResourceData:
	return all_data[type]

func add_resource(type: Economy.Currencies) -> void:
	if free_cells.is_empty():
		return
		
#	far_cells.pick_random().set_data(all_data[type])
	free_cells.pick_random().set_data(all_data[type])

func free_cell(cell: CellResource) -> void:
	if free_cells.has(cell):
		return
		
	far_cells.append(cell)
	free_cells.append(cell)
	cell.set_disabled(true)
	occupied_cells.erase(cell)
	

func occupy_cell(cell: CellResource) -> void:
	if !free_cells.has(cell):
		return
		
	far_cells.erase(cell)
	free_cells.erase(cell)
	occupied_cells.append(cell)
