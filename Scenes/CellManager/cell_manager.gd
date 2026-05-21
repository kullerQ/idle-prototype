extends GridContainer
class_name CellManager

const CELL_SIZE: Vector2 = Vector2(16, 16)

enum Names {
	NULL,
	WOOD_TREE,
	WOOD_GROVE,
	SPECIAL_LUMBERJACK,
	SPECIAL_OUTPOST,
	SPECIAL_DRUID_OBELISK,
}

enum Types {
	NULL,
	WOOD,
	SPECIAL
}

var all_data: Dictionary = {
	Names.WOOD_TREE: load("uid://flg8f2dfjch1").duplicate(),
	Names.WOOD_GROVE: load("uid://cfyepdnjigkxa").duplicate(),
	Names.SPECIAL_LUMBERJACK: load("uid://tcqsywu5xh4d").duplicate(),
	Names.SPECIAL_OUTPOST: load("uid://bkofoigt7mcgd").duplicate(),
	Names.SPECIAL_DRUID_OBELISK: load("uid://dim8xt8cu1j1i").duplicate(),
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
var tiers: Dictionary = {
	Types.WOOD: {
		0: 0, # total weight
		Names.WOOD_TREE: {"weight": 20, "tier": 1},
		Names.WOOD_GROVE: {"weight": 0, "tier": 2},
		
	},
}

var obelisk_links: Dictionary = {} # key: obelisk: owner
var druid_obelisks: Dictionary = {} # key: DriodObeliskCelll values:  [buffed_cells ...]
var free_druid_obelisks: Dictionary = {} # key: obelisk; value available buffs amount

var separation: Vector2
var max_lumberjack_count: int = 1
var economy : Economy

signal cell_hitted(cell: CellResource, damage: Dictionary)
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
	
	row_count = cells.keys().back().y
	for curr in tiers.values():
		for i in range(1, curr.size()):
			curr[0] += curr[i].weight
	
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
	if data.break_value:
		add_res(data.type, data.break_value)
		
	free_cell(cell)
			
#	if !buffed_by_druid_obelisk.has(cell):
#		return
#
#	buffed_by_druid_obelisk.erase(cell)
#	var new_buff_target: CellResource =  get_rand_occupied_cell(buffed_by_druid_obelisk)
#	if !new_buff_target:
#		return
#
#	buffed_by_druid_obelisk.append(new_buff_target)
#	new_buff_target.set_effect(EffectManager.Effects.BUFFED, true)
	
func _on_cell_hitted(cell: CellResource, damage_data: Dictionary, spread_damage_data: Dictionary) -> void:
#	if !handle_hit_function(cell.data, cell):
#		return
	
	var cells_to_damage: Dictionary = {cell: 1} # cell: damage_ratio
	if spread_damage_data.to > 0 && spread_damage_data.ratio > 0:
		cells_to_damage.merge(get_cells_to_spread_damage(cell, spread_damage_data.to, spread_damage_data.ratio))
	
	var base_damage_data: Dictionary = damage_data[DamageManager.DamageDataTypes.BASE]
	var bonus_damage_data: Dictionary = damage_data.get(DamageManager.DamageDataTypes.BONUS, {})
	var damage_mult: float = damage_data[DamageManager.DamageDataTypes.MULT]
	var compiled_damage: Array = []
	for type in base_damage_data:
		var base_type_data: Dictionary = base_damage_data[type]
		var bonus_type_data: Dictionary = bonus_damage_data[type]
		for stat in base_type_data:
			var damage_value: int = round((base_type_data[stat] + bonus_type_data[stat]) * damage_mult)#.get(type, {}).get(stat, 0)) * damage_mult
			if damage_value != 0:
				compiled_damage.append({"type": type, "stat": stat, "damage_value": damage_value})
	
	for c in cells_to_damage:
		var cell_data: CellResourceData = c.data
		var ratio: float = cells_to_damage[c]
		for i in compiled_damage:
			var value: float = i.damage_value * ratio
			match i.type:
				DamageManager.Types.HIT:
					match i.stat:
						DamageManager.Stats.HP:
							var init_cell_hp: int = c.hp
							c.sub_hp(value)
							if cell_data.value:
								if c.is_buffed():
									value *= 2

								add_res(cell_data.type, cell_data.value * value)
						
						DamageManager.Stats.LIFE_TIME:
							c.sub_life_time(value)

				DamageManager.Types.HEAL:
					match i.stat:
						DamageManager.Stats.HP:
							c.add_hp(value)
							
						DamageManager.Stats.LIFE_TIME:
							var overheal: float = c.add_life_time(value)
							var _owner: PlayerCell = damage_data.owner
							if _owner.data.type == PlayerCellData.Types.DRUID:
								if overheal > 0.1:
										var obelisk_spawn_chance: int = _owner.obelisk_spawn_chance
										if obelisk_spawn_chance > 0:
											if _owner.obelisks.size() < _owner.max_obelisks:
												if randi() % 100 < obelisk_spawn_chance:
													var obelisk: CellResource = add_resource(Names.SPECIAL_DRUID_OBELISK) 
													if obelisk:
														_owner.obelisks.append(obelisk)
														obelisk_links[obelisk] = _owner
										
										var cell_lvlup_chance: int = _owner.cell_lvlup_chance
										if cell_lvlup_chance > 0:
											if randi() % 100 < cell_lvlup_chance:
												lvlup_cell(c)
										
										var spawn_tree_on_overheal_chance: int = _owner.spawn_tree_on_overheal_chance
										if spawn_tree_on_overheal_chance > 0:
											if randi() % 100 < spawn_tree_on_overheal_chance:
												var new_cell: CellResource = add_rand_resource(Types.WOOD)
												if randi() % 100 < _owner.weakening_chance:
													new_cell.set_effect(EffectManager.Effects.WEAKENED, true)
													
								var spawn_wood_to_the_right_chance: int = _owner.spawn_wood_to_the_right_chance
								if spawn_wood_to_the_right_chance > 0:
									if randi() % 100 < spawn_wood_to_the_right_chance:
										add_rand_resource_at(cells.find_key(c) + Vector2i.RIGHT, Types.WOOD) 
								
								var reduce_cd_if_heal: float = _owner.reduce_cd_if_heal
								if reduce_cd_if_heal:
									_owner.reduce_cd_time(reduce_cd_if_heal)
									
	
		if c.hp <= 0:
			handle_cell_death_func(cell_data, c)
			cell_died.emit(c)

func handle_cell_death_func(data: CellResourceData, cell: CellResource) -> void:
	match data._name:
		Names.SPECIAL_LUMBERJACK:
			var cell_pos: Vector2 = cell.global_position + CELL_SIZE / 2
			G.projectile_manager.add_resource_axe(cell_pos, data.crit_chance, 2, data.dmg_ratio,
			get_rand_occupied_cell_global_center([cell], Types.WOOD), ProjectileDataModifiers.new(1.5, 0), [cell])
			if data.spawn_wood_chance > 0:
				print(data.spawn_wood_chance)
				if randi() % 100 < data.spawn_wood_chance:
					call_deferred("add_rand_resource_at", cells.find_key(cell), Types.WOOD)
				
			
		Names.SPECIAL_OUTPOST:
			for i in data.attacks:
				var cell_pos: Vector2 = cell.global_position + CELL_SIZE / 2
				G.projectile_manager.add_resource_bullet(cell_pos, 0, 2,
				cell_pos.direction_to(get_rand_occupied_cell_global_center([cell])), 
				ProjectileDataModifiers.new(1.5, data.weakening_chance), [cell], 0.1 * i)
	

func handle_hit_function(data: CellResourceData, cell: CellResource) -> void:
	pass
#			if data.spawn_wood_chance > 0:
#				if randi() % 100 < data.spawn_wood_chance:
#					add_rand_resource_at(cells.find_key(cell), Types.WOOD)
#

func get_cells_to_spread_damage(exclude: CellResource, amount: int, ratio: float) -> Dictionary:
	if occupied_cells.is_empty():
		return {}
		
	var cells: Dictionary = {}
	var temp_occupied_cells: Array = occupied_cells.duplicate()
	for i in amount:
		if temp_occupied_cells.has(exclude):
			temp_occupied_cells.erase(exclude)
			
		if temp_occupied_cells.is_empty():
			return cells
			
		var cell: CellResource = temp_occupied_cells.pick_random()
		cells[cell] = ratio
		exclude = cell

	return cells

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
	var w: Array = tiers[type].values()
	var roll: int = randi_range(0, w[0] - 1)
	var _name: Names = 0
	for i in range(1, w.size()):
		var value: int = w[i].weight
		if roll < value:
			_name = i
			break
			
		roll -= value
	
	assert(_name != 0)
	return _name
	
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

func reset_cell_data(cell: CellResource, data: CellResourceData, old_data: CellResourceData) -> void:
	var args: Dictionary = {
		"sub_hp": old_data.durability - cell.hp, 
		"sub_life_time": old_data.life_time - cell.timer.time_left, 
		"effects": [cell.is_weakened()]
	}
	set_cell_data(cell, data, args)

func set_cell_data(cell: CellResource, data: CellResourceData, args: Dictionary = {"sub_hp": 0, "sub_life_time": 0, "effects": [] })  -> void:
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
	var _name : Names = cell.data._name
	occupied_cells_types[cell.data.type].erase(cell)
	occupied_cells.erase(cell)
	cell.data = null
	
	if druid_obelisks.is_empty():
		return

	if _name == Names.SPECIAL_DRUID_OBELISK:
		free_druid_obelisk(cell)
		return
	
	for i in druid_obelisks:
		if druid_obelisks[i].has(cell):
			druid_obelisks[i].erase(cell)
			var buff_cell_amount: int
			var druid_obelisks_size: int = druid_obelisks[i].size()
			if druid_obelisks_size <= 0:
				buff_cell_amount = i.data.buff_cell_amount
			
			elif free_druid_obelisks.has(i):
				buff_cell_amount = free_druid_obelisks[i] + 1
			
			else:
				buff_cell_amount = i.data.buff_cell_amount - druid_obelisks_size
				
				
			var remain: int = handle_obelisk_buff(i, buff_cell_amount)
			if !remain:
				continue
			
			free_druid_obelisks[i] = remain

func free_druid_obelisk(obelisk: CellResource) -> void:
	if !druid_obelisks.has(obelisk):
		return
		
	obelisk_links[obelisk].obelisks.erase(obelisk)
	obelisk_links.erase(obelisk)
	
	for buffed_cell in druid_obelisks[obelisk]:
		buffed_cell.set_effect(EffectManager.Effects.BUFFED, false)
			
		druid_obelisks.erase(obelisk)
		

#	if !is_cell_special(_name):
#		return
		
#	spawned_special_cells[_name].erase(cell)
	
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
		
#	spawned_special_cells[cell.data._name].append(cell)

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

#func add_max_lumberjack_count(amount: int) -> void:
#	set_max_lumberjack_count(max_lumberjack_count + amount)
#
#func set_max_lumberjack_count(new_v: int) -> void:
#	max_lumberjack_count = new_v

func _on_cell_occupied(cell: CellResource) -> void:
	var _name: Names = cell.data._name
	
	match _name:
		Names.SPECIAL_DRUID_OBELISK:
			druid_obelisks[cell] = []#.append(cell)
			var buff_cell_amount: int = cell.data.buff_cell_amount
			if buff_cell_amount <= 0:
				return
			
			var remain: int = handle_obelisk_buff(cell, cell.data.buff_cell_amount)
			if remain:
				free_druid_obelisks[cell] = remain
			
			return
			
	if is_cell_special(_name):
		return
		
	if free_druid_obelisks.is_empty():
		return
	
	var keys: Array = free_druid_obelisks.keys() 
	keys.reverse()
	for i in keys:
		var remain: int = handle_obelisk_buff(i, free_druid_obelisks[i])
		if remain:
			free_druid_obelisks[i] = remain
			continue
		
		free_druid_obelisks.erase(i)
		
func handle_obelisk_buff(obelisk: CellResource, buff_cell_amount: int) -> int:
	if !is_instance_valid(obelisk):
		free_druid_obelisk(obelisk)
		return 0
		
	var available_cell_amount: int = occupied_cells.size() - druid_obelisks.size()
	if available_cell_amount <= 0:
		return buff_cell_amount
	
	var exclude: Array = get_exclude_for_druid_obelisk()
	if buff_cell_amount > 1:
			
		for i in available_cell_amount:
			var target_cell: CellResource = get_rand_occupied_cell(exclude)
			if target_cell:
				target_cell.set_effect(EffectManager.Effects.BUFFED, true)
				druid_obelisks[obelisk].append(target_cell)
				exclude.append(target_cell)
				buff_cell_amount -= 1
				if buff_cell_amount == 0:
					break
		
	else:
		var target_cell: CellResource = get_rand_occupied_cell(exclude)
		if target_cell:
			target_cell.set_effect(EffectManager.Effects.BUFFED, true)
			druid_obelisks[obelisk].append(target_cell)
			return 0

	return buff_cell_amount
		
func get_exclude_for_druid_obelisk() -> Array:
	var exclude: Array = druid_obelisks.keys()
	for i in occupied_cells:
		if !i.is_buffed():
			continue
		
		exclude.append(i)
	
	return exclude
	
#			var exclude: Array = druid_obelisks.keys()
#			for i in occupied_cells:
#				if !i.is_buffed():
#					continue
#
#				exclude.append(i)
			
			
			
#	var _name: Names = cell.data._name
#	if !is_cell_special(_name):
#		return
#
#	match _name:
#		Names.SPECIAL_LUMBERJACK:
					
#				for i in range(lumberjack_count, max_lumberjack_count, -1):
#					free_cell(spawned_special_cells[Names.SPECIAL_LUMBERJACK][i - 1]) 
				
		
