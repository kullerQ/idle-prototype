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
var highlighted_cell: PlayerCell
var cells_to_upgrade: Array = []
var upgrade_cell_idx: int = 0
@onready var lvl_upgrades_highlight_label: Label = G.lvl_upgrades_highlight_label

var economy: Economy

signal cell_lvled_up(cell: PlayerCell, lvl: int)
signal cell_upgraded(cell: PlayerCell)

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
	
	add_starting_cell(PlayerCellData.Types.SHOOTER, 0, 0)
	cell_lvled_up.connect(_on_cell_lvled_up)
	cell_upgraded.connect(_on_cell_upgraded)
#	fill_grid(PlayerCellData.Types.SHOOTER)

	G.player_cell_pressed.connect(_on_cell_pressed)
	G.level_upgrade_menu_close_requested.connect(_on_level_upgrade_menu_close_requested)

func fill_grid(type: PlayerCellData.Types) -> void:
	for i in cells.values():
		i.call_deferred("set_data", all_data[type])
	
func _on_level_upgrade_menu_close_requested() -> void:
	if !highlighted_cell:
		return
	
	highlighted_cell.set_highlight(false)
	highlighted_cell = null
	

func _on_cell_pressed(cell: PlayerCell) -> void:
	if G.upgrade_menu_opened:
		return
	
	if highlighted_cell == cell:
		G.level_upgrade_menu_close_requested.emit()
		return
	
	if highlighted_cell:
		highlighted_cell.set_highlight(false)
		
	highlighted_cell = cell
	highlighted_cell.set_highlight(true)
	G.level_upgrade_menu_open_requested.emit(cell)
		

func add_starting_cell(type: PlayerCellData.Types, offset_x: int = 0, offset_y: int = 0) -> void:
	cells[start_pos + Vector2i(offset_x, offset_y)].call_deferred("set_data", all_data[type])

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

func _on_cell_lvled_up(cell: PlayerCell, lvl: int) -> void:
	if cells_to_upgrade.has(cell):
		return
		
	cells_to_upgrade.append(cell)
	lvl_upgrades_highlight_label.show()
	lvl_upgrades_highlight_label.text = "%d" %cells_to_upgrade.size()
	
func _on_cell_upgraded(cell: PlayerCell) -> void:
	if cell.lvl_tokens > 0:
		return
		
	cells_to_upgrade.erase(cell)
	lvl_upgrades_highlight_label.text = "%d" %cells_to_upgrade.size()
	if !cells_to_upgrade.is_empty():
		return
	
	lvl_upgrades_highlight_label.hide()

func get_cell_to_upgrade() -> PlayerCell:
	if cells_to_upgrade.is_empty():
		return null
	
	if upgrade_cell_idx >= cells_to_upgrade.size():
		upgrade_cell_idx = upgrade_cell_idx % cells_to_upgrade.size()
		
	var cell: PlayerCell = cells_to_upgrade[upgrade_cell_idx]
	upgrade_cell_idx = (upgrade_cell_idx + 1) % cells_to_upgrade.size()
	return cell
