extends GridContainer
class_name CellManager

const CELL_SIZE: Vector2 = Vector2(16, 16)
enum Names {
	NULL,
	WOOD_TREE,
	WOOD_GROVE,
	SPECIAL_LUMBERJACK
}
enum Types {
	NULL,
	WOOD,
	SPECIAL
}

var all_data: Dictionary = {
	Names.WOOD_TREE: load("uid://flg8f2dfjch1"),
	Names.WOOD_GROVE: load("uid://cfyepdnjigkxa"),
	Names.SPECIAL_LUMBERJACK: load("uid://tcqsywu5xh4d"),
}

var cells: Dictionary = {}
var free_cells: Array = []
var occupied_cells: Array = []
var occupied_cells_types: Dictionary = {}
var spawned_special_cells: Dictionary = {
	Names.SPECIAL_LUMBERJACK: [],
}
var far_cells: Array
var weights: Dictionary = {
	Types.WOOD:
		{
			0: 0, # total weight
			Names.WOOD_TREE: 20,
			Names.WOOD_GROVE: 0,
		},
}
var separation: Vector2
var max_lumberjack_count: int = 1
var economy : Economy

signal cell_hitted(cell: CellResource, dmg_data: DamageData)
signal cell_died(cell: CellResource)
signal cell_occupied(cell: CellResource) 

func _ready():
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
	
	for curr in weights.values():
		for i in range(1, curr.size()):
			curr[0] += curr[i]
	
	for i in range(1, Types.size()):
		occupied_cells_types[i] = []
	
	cell_hitted.connect(_on_cell_hitted)
	cell_died.connect(_on_cell_died)
	cell_occupied.connect(_on_cell_occupied)
	add_rand_resource(Types.WOOD)
#	add_resource(Names.WOOD_GROVE)
#	add_resource(Names.SPECIAL_LUMBERJACK)
	
func add_res(type: Types, amount: int) -> void:
	match type:
		Types.WOOD:
			economy.add_resource(Economy.Currencies.WOOD, amount)

func _on_cell_died(cell: CellResource) -> void:
	var data: CellResourceData = cell.data
	add_res(data.type, data.break_value)
	free_cell(cell)
	
func _on_cell_hitted(cell: CellResource, dmg_data: DamageData) -> void:
	var data: CellResourceData = cell.data
	if !handle_hit_function(data, cell):
		return

	var hp: int = cell.hp
	
	match data._name:
		Names.SPECIAL_LUMBERJACK:
			return
	
	var sub_data: Dictionary = dmg_data.sub
	var add_data: Dictionary = dmg_data.add
################################
	for value in sub_data:
		var dmg: float = sub_data[value]
		if cell.weakened:
			dmg = round(dmg * dmg_data.weakened_mod)
		
		match value:
			DamageData.Values.HP:
				cell.sub_hp(dmg)
				add_res(data.type, min(hp, data.value * dmg))
				print(dmg)
		
			DamageData.Values.LIFE_TIME:
				var overkill: float = cell.sub_life_time(dmg)
				
####################################
	for value in add_data:
		var dmg: float = add_data[value]
		if cell.weakened:
			dmg = round(dmg * dmg_data.weakened_mod)
			
		match value:
			DamageData.Values.HP:
				cell.add_hp(dmg)

			DamageData.Values.LIFE_TIME:
				var overheal: float = cell.add_life_time(dmg)
				if overheal:
					var other_cell: CellResource = get_rand_occupied_cell(cell)
					if !other_cell:
						return

					for i in occupied_cells:
						overheal = i.add_life_time(overheal)
						if overheal <= 0:
							break

				return
		

func handle_hit_function(data: CellResourceData, cell: CellResource) -> bool:
	match data._name:
		Names.SPECIAL_LUMBERJACK:
			var cell_pos: Vector2 = cell.global_position + CELL_SIZE / 2
			var crit_mult: int = 2 if randf_range(0, 100) <= data.crit_chance else 1
			G.projectile_manager.add_resource_axe(cell_pos, crit_mult, data.dmg_percent,
			get_rand_occupied_cell_global_center(cell, Types.WOOD), ProjectileDataModifiers.new(1.5, 0), [cell])
			free_cell(cell)
			return false
			
	return true

func get_cell_coords_from_global_pos(pos: Vector2) -> Vector2i:
	return floor((pos - global_position) / (CELL_SIZE + separation))

func get_cell_global_pos(coords: Vector2i) -> Vector2:
	return cells[coords].global_position
	
func get_cell_global_center(coords: Vector2i) -> Vector2:
	return cells[coords].global_position + CELL_SIZE / 2
	
func get_rand_occupied_cell(exclude: CellResource = null, type: Types = 0) -> CellResource:
	if occupied_cells.is_empty():
		return null

	var target_arr: Array = occupied_cells if type == 0 else occupied_cells_types[type]
	if target_arr.is_empty():
		return null
	
	if exclude:
		var temp_occupied_cells = target_arr.duplicate()
		if temp_occupied_cells.has(exclude):
			temp_occupied_cells.erase(exclude)
	
		if temp_occupied_cells.is_empty():
			return null
			
		target_arr = temp_occupied_cells
	
	return target_arr.pick_random()
	
func get_rand_occupied_cell_global_center(exclude: CellResource = null, type: Types = 0) -> Vector2:
	var cell: CellResource = get_rand_occupied_cell(exclude, type)
	if !cell:
		return Vector2.ZERO
		
	return cell.global_position + CELL_SIZE / 2
	
func get_data(_name: Names) -> CellResourceData:
	return all_data[_name]

func get_type_from_name(_name: Names) -> Types:
	return Types.get(Names.keys()[_name].split("_")[0])

func add_cell_weight(_name: Names, amount: int, type: Types = 0) -> void:
	if type == 0:
		type = get_type_from_name(_name)
		assert(type != 0)

	set_cell_weight(_name, weights[type][_name] + amount, type)

func sub_cell_weight(_name: Names, amount: int, type: Types = 0) -> void:
	if type == 0:
		type = get_type_from_name(_name)
		assert(type != 0)

	set_cell_weight(_name, weights[type][_name] - amount, type)

func set_cell_weight(_name: Names, value: int, type: Types = 0) -> void:
	if type == 0:
		type = get_type_from_name(_name)
		assert(type != 0)

	weights[type][0] -= weights[type][_name] - value # total weight
	weights[type][_name] = value

func get_rand_name(type: Types) -> Names:
	var w: Array = weights[type].values()
	var roll: int = randi_range(0, w[0] - 1)
	var _name: Names = 0
	for i in range(1, w.size()):
		var value: int = w[i]
		if roll < value:
			_name = i
			break
			
		roll -= value
	
	assert(_name != 0)
	return _name
	

func add_rand_resource(type: Types) -> void:
	if free_cells.is_empty():
		return
	
	set_cell_data(free_cells.pick_random(), all_data[get_rand_name(type)])

func add_rand_resource_at(coords: Vector2i, type: Types) -> void:
	var cell: CellResource = cells[coords]
	if !free_cells.has(cell):
		return
	
	set_cell_data(cell, all_data[get_rand_name(type)])

func add_resource(_name: Names) -> void:
	if free_cells.is_empty():
		return

	set_cell_data(free_cells.pick_random(), all_data[_name])
	
func add_resource_at(coords: Vector2i, _name: Names) -> void:
	var cell: CellResource = cells[coords]
	if !free_cells.has(cell):
		return
	
	set_cell_data(cell, all_data[_name])

func add_resource_at_global(pos: Vector2, _name: Names) -> void:
	add_resource_at(get_cell_coords_from_global_pos(pos), _name)

func before_set_cell_data(data: CellResourceData) -> bool:
	if !is_cell_special(data._name):
		return true
	
	match data._name:
		Names.SPECIAL_LUMBERJACK:
			var lumberjack_count: int = spawned_special_cells[Names.SPECIAL_LUMBERJACK].size()
			if lumberjack_count >= max_lumberjack_count:
				for i in range(lumberjack_count, 0, -1):
					respawn_res_at_rand_cell(spawned_special_cells[Names.SPECIAL_LUMBERJACK][i - 1])
			
				return false
				
	return true
	

func set_cell_data(cell: CellResource, data: CellResourceData) -> void:
#	if !before_set_cell_data(data):
#		return
#
	cell.set_data(data)
	
func free_cell(cell: CellResource) -> void:
	if free_cells.has(cell):
		return
		
	far_cells.append(cell)
	free_cells.append(cell)
	cell.set_disabled(true)
	var _name : Names = cell.data._name
	occupied_cells_types[cell.data.type].erase(cell)
	occupied_cells.erase(cell)
	cell.data = null

	if !is_cell_special(_name):
		return
		
	spawned_special_cells[_name].erase(cell)
	
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
		
	spawned_special_cells[cell.data._name].append(cell)

func respawn_res_at_rand_cell(cell: CellResource) -> void:
	if free_cells.is_empty():
		return
		
	var new_cell: CellResource = free_cells.pick_random()
	var data: CellResourceData = all_data[cell.data._name]
	free_cell(cell)
	set_cell_data(new_cell, data)

#func add_max_lumberjack_count(amount: int) -> void:
#	set_max_lumberjack_count(max_lumberjack_count + amount)
#
#func set_max_lumberjack_count(new_v: int) -> void:
#	max_lumberjack_count = new_v

func _on_cell_occupied(cell: CellResource) -> void:
	pass
#	var _name: Names = cell.data._name
#	if !is_cell_special(_name):
#		return
#
#	match _name:
#		Names.SPECIAL_LUMBERJACK:
					
#				for i in range(lumberjack_count, max_lumberjack_count, -1):
#					free_cell(spawned_special_cells[Names.SPECIAL_LUMBERJACK][i - 1]) 
				
		
