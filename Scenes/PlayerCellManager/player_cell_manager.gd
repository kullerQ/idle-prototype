extends GridContainer
class_name PlayerCellManager

const CELLS_IN_COLUMN: int = 13
var cells: Dictionary = {}
var all_data: Dictionary = {
	PlayerCellData.Types.NULL: load("uid://cgk1kaetu6bsg").duplicate(),
	PlayerCellData.Types.SHOOTER: load("uid://d1lppkhdp8brh").duplicate(),
	PlayerCellData.Types.ROGUE: load("uid://cson3piyylqw0").duplicate(),
	PlayerCellData.Types.WIZARD: load("uid://ynurimwp8bik").duplicate(),
}
var free_cells: Array = []
var added_cells: int = 1
var up_added: int = 0
var down_added: int = 0
var h_idx: int = 0
var start_pos: Vector2i = Vector2i(4, 6)

var economy: Economy

func _enter_tree() -> void:
	G.upgrade_manager.player_cell_manager = self

func _input(event):
	if event is InputEventKey && event.is_pressed():
		match event.keycode:
			KEY_1:
				add_free_cell()
			KEY_S:
				add_tower(PlayerCellData.Types.SHOOTER)
			KEY_A:
				add_tower(PlayerCellData.Types.ROGUE)
			KEY_W:
				add_tower(PlayerCellData.Types.WIZARD)
				
	
func _ready() -> void:
	var pos: Vector2i = Vector2i.ZERO
	for c in get_children():
		cells[pos] = c
		if pos.x + 1 == columns:
			pos.x = 0
			pos.y += 1
			continue
			
		pos.x += 1
		
	cells[start_pos].set_data(all_data[PlayerCellData.Types.SHOOTER])
#	cells[Vector2i(3,1)].set_data(all_data[PlayerCellData.Types.SHOOTER])

func get_data(type: PlayerCellData.Types) -> PlayerCellData:
	return all_data[type]

func add_tower(type: PlayerCellData.Types) -> void:
	if free_cells.is_empty():
		return
		
	if type == 0:
		return
		
	var cell: PlayerCell = free_cells.pick_random()
	cell.set_data(all_data[type])
	free_cells.erase(cell)

func add_free_cell() -> void:
	if h_idx >= columns:
		return
		
	var sign: int = -1 if added_cells % 2 == 0  else 1
	var add_y: int = 0
	if added_cells > 0:
		if sign < 0:
			up_added += 1
			add_y = up_added
		
		else:
			down_added += 1
			add_y = down_added
			
	added_cells += 1 
	var cell: PlayerCell = cells[start_pos + Vector2i(-h_idx, sign * add_y)]
	cell.set_data(all_data[0])
	economy.add_resource(Economy.Currencies.FREE_CELLS, 1)
	free_cells.append(cell)
	if added_cells < CELLS_IN_COLUMN:
		return
	
	added_cells = 0
	up_added = 0
	down_added = 0
	h_idx += 1
