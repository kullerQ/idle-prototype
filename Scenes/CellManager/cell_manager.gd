extends GridContainer
class_name CellManager

const CELL_SIZE: Vector2 = Vector2(16, 16)

enum Names {
	NULL,
	WOOD_TREE,
	WOOD_GROVE,
	WOOD_FOREST,
	SPECIAL_LUMBERJACK,
	SPECIAL_OUTPOST,
	SPECIAL_DRUID_OBELISK,
}

enum Types {
	NULL,
	WOOD,
	SPECIAL
}

const _DATA_WOOD_TREE: CellResourceData = preload("res://Resources/ResourceCells/cell_resource_tree.tres")
const _DATA_WOOD_GROVE: CellResourceData = preload("res://Resources/ResourceCells/cell_resource_grove.tres")
const _DATA_WOOD_FOREST: ForestData = preload("res://Resources/ResourceCells/cell_resource_forest.tres")
const _DATA_SPECIAL_LUMBERJACK: LumberjackData = preload("res://Resources/ResourceCells/cell_lumberjack.tres")
const _DATA_SPECIAL_OUTPOST: OutpostData = preload("res://Resources/ResourceCells/cell_outpost.tres")
const _DATA_SPECIAL_DRUID_OBELISK: DruidObeliskData = preload("res://Resources/ResourceCells/cell_druid_obelisk.tres")
const _DEFAULT_SPAWN_CONFIG = preload("res://Resources/cell_spawn_config.tres")

var all_data: Dictionary = {
	Names.WOOD_TREE: _DATA_WOOD_TREE.duplicate(),
	Names.WOOD_GROVE: _DATA_WOOD_GROVE.duplicate(),
	Names.WOOD_FOREST: _DATA_WOOD_FOREST.duplicate(),
	Names.SPECIAL_LUMBERJACK: _DATA_SPECIAL_LUMBERJACK.duplicate(),
	Names.SPECIAL_OUTPOST: _DATA_SPECIAL_OUTPOST.duplicate(),
	Names.SPECIAL_DRUID_OBELISK: _DATA_SPECIAL_DRUID_OBELISK.duplicate(),
}

var row_count: int = 0
var cells: Dictionary = {}
var free_cells: Array = []
var occupied_cells: Array = []
var occupied_cells_types: Dictionary = {}
var spawned_special_cells: Dictionary = {
	Names.SPECIAL_LUMBERJACK: [],
}

var far_cells: Array
## Runtime weight tables built from spawn_config in _ready. Key 0 = total weight.
var tiers: Dictionary = {}

@export var spawn_config: CellSpawnConfig

var separation: Vector2
var max_lumberjack_count: int = 1
var economy: Economy
var expedition_manager: ExpeditionManager
var projectile_manager: ProjectileManager

## Composed subsystems (set in _ready).
var combat: CellCombatResolver
var specials: CellSpecialBehaviors
var druid: DruidObeliskSystem

signal cell_hitted(cell: CellResource, damage_data: Dictionary, spread_damage_data: Dictionary)
signal hit_handled(cell: CellResource, data: CellResourceData)
signal cell_died(cell: CellResource)
signal cell_occupied(cell: CellResource)


func _ready() -> void:
	combat = CellCombatResolver.new(self)
	specials = CellSpecialBehaviors.new(self)
	specials.projectile_manager = projectile_manager
	druid = DruidObeliskSystem.new(self)

	for i in all_data:
		all_data[i]._name = i

	separation = Vector2i(get("theme_override_constants/h_separation"), get("theme_override_constants/v_separation"))
	free_cells = get_children()
	var coords: Vector2i = Vector2i.ZERO
	for c in get_children():
		cells[coords] = c
		if coords.x >= 7:
			far_cells.append(c)

		if coords.x + 1 == columns:
			coords.x = 0
			coords.y += 1
			continue

		coords.x += 1

	row_count = cells.keys().back().y
	_build_tiers_from_spawn_config()

	for i in range(1, Types.size()):
		occupied_cells_types[i] = []

	cell_hitted.connect(combat.on_cell_hitted)
	cell_died.connect(_on_cell_died)
	cell_occupied.connect(specials.on_cell_occupied)
	add_start_cells()


func _build_tiers_from_spawn_config() -> void:
	var config: CellSpawnConfig = spawn_config if spawn_config else _DEFAULT_SPAWN_CONFIG
	tiers.clear()
	for table in config.tables:
		var dict: Dictionary = {0: 0} # total weight
		for entry in table.entries:
			dict[entry.cell_name] = {"weight": entry.weight, "tier": entry.tier}
			dict[0] += entry.weight
		tiers[table.type] = dict


func add_start_cells() -> void:
	add_rand_resource(Types.WOOD)


func add_res(type: Types, amount: int) -> void:
	if expedition_manager and expedition_manager.is_active:
		return

	match type:
		Types.WOOD:
			economy.add_resource(Economy.Currencies.WOOD, amount)


func _on_cell_died(cell: CellResource) -> void:
	var data: CellResourceData = cell.data
	if data.break_value:
		add_res(data.type, data.break_value)

	free_cell(cell)


# --- Combat façade ---

func kill_grid() -> void:
	combat.kill_grid()


func kill_cell(target: CellResource) -> void:
	combat.kill_cell(target)


# --- Grid coords ---

func get_cell_from_global_pos(pos: Vector2) -> CellResource:
	return cells[get_cell_coords_from_global_pos(pos)]


func get_cell_coords_from_global_pos(pos: Vector2) -> Vector2i:
	return floor((pos - global_position) / (CELL_SIZE + separation))


func get_cell_global_pos(coords: Vector2i) -> Vector2:
	return cells[coords].global_position


func get_cell_global_center(coords: Vector2i) -> Vector2:
	return cells[coords].global_position + CELL_SIZE / 2


func get_rand_occupied_cell(exclude: Array = [], type: Types = 0) -> CellResource:
	if occupied_cells.is_empty():
		return null

	var target_arr: Array = occupied_cells if type == 0 else occupied_cells_types[type]
	if target_arr.is_empty():
		return null

	if !exclude.is_empty():
		for node in exclude:
			target_arr = target_arr.filter(func(c: CellResource) -> bool: return c != node)

		if target_arr.is_empty():
			return null

	return target_arr.pick_random()


func get_rand_occupied_cell_global_center(exclude: Array = [], type: Types = 0) -> Vector2:
	var cell: CellResource = get_rand_occupied_cell(exclude, type)
	if !cell:
		return Vector2.ZERO

	return cell.global_position + CELL_SIZE / 2


func get_data(_name: Names) -> CellResourceData:
	return all_data[_name]


func add_life_time(_name: Names, amount: float) -> void:
	all_data[_name].life_time += amount


func multiply_life_time(_name: Names, factor: float) -> void:
	all_data[_name].life_time *= factor


func add_value(_name: Names, amount: int) -> void:
	all_data[_name].value += amount


func add_buffed_chance(_name: Names, amount: int) -> void:
	all_data[_name].buffed_chance += amount


func add_break_and_durability(_name: Names, break_amount: int, durability_amount: int) -> void:
	var data: CellResourceData = all_data[_name]
	data.break_value += break_amount
	data.durability += durability_amount


func add_lumberjack_crit(amount: int) -> void:
	(all_data[Names.SPECIAL_LUMBERJACK] as LumberjackData).crit_chance += amount


func add_lumberjack_dmg_ratio(amount: float) -> void:
	(all_data[Names.SPECIAL_LUMBERJACK] as LumberjackData).dmg_ratio += amount


func add_lumberjack_spawn_wood_chance(amount: int) -> void:
	(all_data[Names.SPECIAL_LUMBERJACK] as LumberjackData).spawn_wood_chance += amount


func add_outpost_weakening_chance(amount: int) -> void:
	(all_data[Names.SPECIAL_OUTPOST] as OutpostData).weakening_chance += amount


func add_outpost_attacks(amount: int) -> void:
	(all_data[Names.SPECIAL_OUTPOST] as OutpostData).attacks += amount


func unlock_weighted_resource(_name: Names, weight: int, type: Types) -> void:
	add_cell_weight(_name, weight, type)
	add_resource(_name)


func get_type_from_name(_name: Names) -> Types:
	return Types.get(Names.keys()[_name].split("_")[0])


func add_cell_weight(_name: Names, amount: int, type: Types = 0) -> void:
	if type == 0:
		type = get_type_from_name(_name)
		assert(type != 0)

	set_cell_weight(_name, tiers[type][_name].weight + amount, type)


func sub_cell_weight(_name: Names, amount: int, type: Types = 0) -> void:
	if type == 0:
		type = get_type_from_name(_name)
		assert(type != 0)

	set_cell_weight(_name, tiers[type][_name].weight - amount, type)


func set_cell_weight(_name: Names, value: int, type: Types = 0) -> void:
	if type == 0:
		type = get_type_from_name(_name)
		assert(type != 0)

	tiers[type][0] -= tiers[type][_name].weight - value # total weight
	tiers[type][_name].weight = value


func get_rand_name(type: Types) -> Names:
	var table: Dictionary = tiers[type]
	var roll: int = randi_range(0, table[0] - 1)
	for key in table:
		if key == 0:
			continue

		var value: int = table[key].weight
		if roll < value:
			return key

		roll -= value

	assert(false, "get_rand_name: no entry for type %s" % type)
	return Names.NULL


func add_rand_resource(type: Types) -> CellResource:
	if free_cells.is_empty():
		return

	var cell: CellResource = free_cells.pick_random()
	set_cell_data(cell, all_data[get_rand_name(type)])
	return cell


func add_rand_resource_at(coords: Vector2i, type: Types) -> void:
	var cell: CellResource = cells.get(coords, null)
	if !free_cells.has(cell):
		return

	set_cell_data(cell, all_data[get_rand_name(type)])


func add_resource(_name: Names) -> CellResource:
	if free_cells.is_empty():
		return

	var cell: CellResource = free_cells.pick_random()
	set_cell_data(cell, all_data[_name])
	return cell


func add_resource_at(coords: Vector2i, _name: Names) -> CellResource:
	var cell: CellResource = cells.get(coords, null)
	if !is_instance_valid(cell) || !free_cells.has(cell):
		return null

	set_cell_data(cell, all_data[_name])
	return cell


func add_resource_at_global(pos: Vector2, _name: Names) -> void:
	add_resource_at(get_cell_coords_from_global_pos(pos), _name)


func before_set_cell_data(data: CellResourceData) -> bool:
	return specials.before_set_cell_data(data)


func reset_cell_data(cell: CellResource, data: CellResourceData, old_data: CellResourceData) -> void:
	var args: Dictionary = {
		"sub_hp": old_data.durability - cell.hp,
		"sub_life_time": old_data.life_time - cell.timer.time_left,
		"effects": []
	}

	# Temporary fix
	args.effects.append(EffectManager.Effects.BUFFED) if cell.is_buffed() else null
	args.effects.append(EffectManager.Effects.WEAKENED) if cell.is_weakened() else null

	set_cell_data(cell, data, args)


func set_cell_data(cell: CellResource, data: CellResourceData, args: Dictionary = {"sub_hp": 0, "sub_life_time": 0, "effects": [] }) -> void:
#	if !before_set_cell_data(data):
#		return
	if data.buffed_chance > 0 && !args.effects.has(EffectManager.Effects.BUFFED):
		if randi() % 100 < data.buffed_chance:
			args.effects.append(EffectManager.Effects.BUFFED)

	cell.set_data(data, args)


func free_cell(cell: CellResource) -> void:
	if free_cells.has(cell):
		return

	far_cells.append(cell)
	free_cells.append(cell)
	cell.set_disabled(true)
	var _name: Names = cell.data._name
	occupied_cells_types[cell.data.type].erase(cell)
	occupied_cells.erase(cell)
	cell.data = null

	druid.on_cell_freed(cell, _name)


func free_cell_at(coords: Vector2i) -> void:
	free_cell(cells[coords])


func free_cell_at_global(pos: Vector2) -> void:
	free_cell(cells[get_cell_coords_from_global_pos(pos)])


func is_cell_special(_name: Names) -> bool:
	if Names.keys()[_name].split("_")[0] == "SPECIAL":
		return true

	return false


func occupy_cell(cell: CellResource) -> void:
	if !free_cells.has(cell):
		return

	cell.set_disabled(false)
	far_cells.erase(cell)
	free_cells.erase(cell)
	occupied_cells.append(cell)
	occupied_cells_types[cell.data.type].append(cell)
	cell_occupied.emit(cell)
	if !is_cell_special(cell.data._name):
		return


func respawn_res_at_rand_cell(cell: CellResource) -> void:
	if free_cells.is_empty():
		return

	var new_cell: CellResource = free_cells.pick_random()
	var data: CellResourceData = all_data[cell.data._name]
	free_cell(cell)
	set_cell_data(new_cell, data)


func lvlup_cell(cell: CellResource) -> void:
	if !occupied_cells.has(cell):
		return

	var cell_data: CellResourceData = cell.data
	var tier_keys: Array = tiers[cell_data.type].keys()
	var tier: int = tiers[cell_data.type][cell_data._name].tier
	if tier >= tier_keys.size() - 1:
		return

	reset_cell_data(cell, get_data(tier_keys[tier + 1]), cell_data)


func lvlup_cell_at(coords: Vector2i) -> void:
	var cell: CellResource = cells[coords]
	if !cell.data:
		return

	lvlup_cell(cell)


func free_grid() -> void:
	for i in range(occupied_cells.size() - 1, -1, -1):
		free_cell(occupied_cells[i])


func get_grid_total_hp() -> int:
	var total: int = 0
	for i in occupied_cells:
		total += i.hp

	return total
