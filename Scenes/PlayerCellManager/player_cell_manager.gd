extends GridContainer
class_name PlayerCellManager

const CELLS_IN_COLUMN: int = 13
enum AttackEffects {
	RES_BREAK_VALUE,
}
var cells: Dictionary = {}
const _DATA_NULL: PlayerCellData = preload("res://Resources/PlayerCells/player_cell_empty.tres")
const _DATA_SHOOTER: PlayerCellData = preload("res://Resources/PlayerCells/player_cell_shooter.tres")
const _DATA_ROGUE: PlayerCellData = preload("res://Resources/PlayerCells/player_cell_rogue.tres")
const _DATA_WIZARD: PlayerCellData = preload("res://Resources/PlayerCells/player_cell_wizard.tres")
const _DATA_DRUID: PlayerCellData = preload("res://Resources/PlayerCells/player_cell_druid.tres")
const _DATA_EXECUTIONER: PlayerCellData = preload("res://Resources/PlayerCells/player_cell_executioner.tres")

var all_data: Dictionary = {
	PlayerCellData.Types.NULL: _DATA_NULL.duplicate(),
	PlayerCellData.Types.SHOOTER: _DATA_SHOOTER.duplicate(),
	PlayerCellData.Types.ROGUE: _DATA_ROGUE.duplicate(),
	PlayerCellData.Types.WIZARD: _DATA_WIZARD.duplicate(),
	PlayerCellData.Types.DRUID: _DATA_DRUID.duplicate(),
	PlayerCellData.Types.EXECUTIONER: _DATA_EXECUTIONER.duplicate(),
}
#var damage_data: Dictionary = {
#	PlayerCellData.Types.NULL: DamageData.new(),
#	PlayerCellData.Types.SHOOTER: load("uid://b25j3a61ph37i").duplicate(),
#}
#var damage_mod_data: Dictionary = {
#	PlayerCellData.Types.NULL: DamageModData.new(),
#	PlayerCellData.Types.SHOOTER: load("").duplicate(),
#
#}

var free_cells: Array = []
var added_cells: int = 0
var up_added: int = 0
var down_added: int = 0
var h_idx: int = 0
var start_pos: Vector2i = Vector2i(4, 6)
var highlighted_cell: PlayerCell
var cells_to_upgrade: Array = []
var upgrade_cell_idx: int = 0
@onready var lvl_upgrades_highlight_label: Label = G.lvl_upgrades_highlight_label

var economy: Economy
var cell_manager: CellManager
var damage_manager: DamageManager
var projectile_manager: ProjectileManager

signal cell_lvled_up(cell: PlayerCell, lvl: int)
signal cell_upgraded(cell: PlayerCell)
signal xp_added(cell: PlayerCell)
signal cell_attacked(cell: PlayerCell)


func _ready() -> void:
	var pos: Vector2i = Vector2i.ZERO
	for c in get_children():
		_configure_cell(c)
		cells[pos] = c
		if pos.x + 1 == columns:
			pos.x = 0
			pos.y += 1
			continue
			
		pos.x += 1
	
	await get_tree().process_frame
#	add_starting_cell(PlayerCellData.Types.DRUID, 0, 0)
	add_starting_cell(PlayerCellData.Types.SHOOTER, 0, 0)
#	add_starting_cell(PlayerCellData.Types.SHOOTER, 0, 1)
#	add_starting_cell(PlayerCellData.Types.EXECUTIONER, 0, 0)

	cell_lvled_up.connect(_on_cell_lvled_up)
	cell_upgraded.connect(_on_cell_upgraded)
	cell_attacked.connect(_on_cell_attacked)
	xp_added.connect(_on_xp_added)
#	fill_grid(PlayerCellData.Types.SHOOTER)

	G.player_cell_pressed.connect(_on_cell_pressed)
	G.level_upgrade_menu_close_requested.connect(_on_level_upgrade_menu_close_requested)


func _configure_cell(cell: PlayerCell) -> void:
	cell.manager = self
	cell.projectile_manager = projectile_manager


func fill_grid(type: PlayerCellData.Types) -> void:
	for i in cells.values():
		i.call_deferred("set_data", all_data[type])


func _on_level_upgrade_menu_close_requested() -> void:
	if !highlighted_cell:
		return
	
	highlighted_cell.set_highlight(false)
	highlighted_cell = null


func _on_cell_pressed(cell: PlayerCell) -> void:
	if G.opened_menu_type:
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
	add_free_cell()
	add_tower_at(type, start_pos + Vector2i(offset_x, offset_y))


func get_data(type: PlayerCellData.Types) -> PlayerCellData:
	return all_data[type]


func add_cooldown(type: PlayerCellData.Types, amount: float) -> void:
	all_data[type].cooldown += amount


func add_accuracy(type: PlayerCellData.Types, amount: float) -> void:
	all_data[type].accuracy += amount


func add_crit_chance(type: PlayerCellData.Types, amount: int) -> void:
	all_data[type].crit_chance += amount


func add_crit_mult(type: PlayerCellData.Types, amount: int) -> void:
	all_data[type].crit_mult += amount


func add_xp_increase(type: PlayerCellData.Types, amount: float) -> void:
	all_data[type].xp_increase += amount


func add_tower_at(type: PlayerCellData.Types, coords: Vector2i) -> void:
	add_tower(type, cells[coords])


func add_tower(type: PlayerCellData.Types, cell: PlayerCell = null) -> void:
	if free_cells.is_empty():
		return
		
	if type == 0:
		return
	
	if !cell:
		cell = free_cells.pick_random()

	
	cell.set_data(all_data[type])
	occupy_cell(cell)

#	if damage_mod_data.has(type):
#		cell.set_damage_data(damage_mod_data[type].duplicate())
#	else:
#		cell.set_damage_data(damage_mod_data[0])
#		print("null dmg data")


func _on_xp_added(cell: PlayerCell) -> void:
	economy.add_resource(Economy.Currencies.XP, cell.data.xp_increase)


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


func occupy_cell(cell: PlayerCell) -> void:
	free_cells.erase(cell)
	economy.sub_resource(Economy.Currencies.FREE_CELLS, 1)


func set_cell_bonus_damage_preset(cell: PlayerCell, preset: DamageManager.TowerPresets) -> void:
	cell.bonus_damage = damage_manager.tower_bonus_damage_presets[preset]


func get_cell_to_upgrade() -> PlayerCell:
	if cells_to_upgrade.is_empty():
		return null
	
	if upgrade_cell_idx >= cells_to_upgrade.size():
		upgrade_cell_idx = upgrade_cell_idx % cells_to_upgrade.size()
		
	var cell: PlayerCell = cells_to_upgrade[upgrade_cell_idx]
	upgrade_cell_idx = (upgrade_cell_idx + 1) % cells_to_upgrade.size()
	return cell


func _on_cell_attacked(cell: PlayerCell, attack_effects: Array) -> void:
	if attack_effects.is_empty():
		return
		
	for i in attack_effects:
		match i:
			AttackEffects.RES_BREAK_VALUE:
				var res_cell: CellResource = cell_manager.get_rand_occupied_cell()
				if res_cell:
					var cell_data: CellResourceData = res_cell.data
					cell_manager.add_res(cell_data.type, cell_data.break_value)
