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
var tiers: Dictionary = {
	Types.WOOD: {
		0: 0, # total weight
		Names.WOOD_TREE: {"weight": 20, "tier": 1},
		Names.WOOD_GROVE: {"weight": 0, "tier": 2},
		Names.WOOD_FOREST: {"weight": 0, "tier": 3},
		
	},
}

var obelisk_links: Dictionary = {}  	 # key: obelisk: owner
var druid_obelisks: Dictionary = {} 	 # key: DriodObeliskCelll values:  [buffed_cells ...]
var free_druid_obelisks: Dictionary = {} # key: obelisk; value available buffs amount

var first_forest_broken: bool = false

var separation: Vector2
var max_lumberjack_count: int = 1
var economy : Economy

signal cell_hitted(cell: CellResource, damage_data: Dictionary, spread_damage_data: Dictionary)
signal hit_handled(cell: CellResource, data: CellResourceData)
signal cell_died(cell: CellResource)
signal cell_occupied(cell: CellResource) 


func _ready():
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
	for curr in tiers.values():
		var values: Array = curr.values()
		for i in range(1, curr.size()):
			curr[0] += values[i].weight
	
	for i in range(1, Types.size()):
		occupied_cells_types[i] = []
	
	cell_hitted.connect(_on_cell_hitted)
	cell_died.connect(_on_cell_died)
	cell_occupied.connect(_on_cell_occupied)
	add_start_cells()


func add_start_cells() -> void:
	add_rand_resource(Types.WOOD)
#	add_resource(Names.WOOD_GROVE)
#	add_resource(Names.SPECIAL_LUMBERJACK)


func add_res(type: Types, amount: int) -> void:
	if G.in_expedition:
		return
		
	match type:
		Types.WOOD:
			economy.add_resource(Economy.Currencies.WOOD, amount)


func _on_cell_died(cell: CellResource) -> void:
	var data: CellResourceData = cell.data
	if data.break_value:
		add_res(data.type, data.break_value)
		
	free_cell(cell)


# TODO: Fix data-type inconsistency
func _award_resources_for_hit(cell: CellResource, cell_data: CellResourceData, value: float) -> void:
	if !cell_data.value:
		return
	if cell.is_buffed():
		value *= 2
	add_res(cell_data.type, cell_data.value * value)


func _handle_druid_overheal_procs(damage_data_owner: PlayerCell, healed_cell: CellResource, overheal: float) -> void:
	if damage_data_owner.data.type != PlayerCellData.Types.DRUID:
		return

	if overheal > 0.1:
		var obelisk_spawn_chance: int = damage_data_owner.obelisk_spawn_chance
		if obelisk_spawn_chance > 0:
			if damage_data_owner.obelisks.size() < damage_data_owner.max_obelisks:
				if randi() % 100 < obelisk_spawn_chance:
					var obelisk: CellResource = add_resource(Names.SPECIAL_DRUID_OBELISK)
					if obelisk:
						damage_data_owner.obelisks.append(obelisk)
						obelisk_links[obelisk] = damage_data_owner

		var cell_lvlup_chance: int = damage_data_owner.cell_lvlup_chance
		if cell_lvlup_chance > 0:
			if randi() % 100 < cell_lvlup_chance:
				lvlup_cell(healed_cell)

		var spawn_tree_on_overheal_chance: int = damage_data_owner.spawn_tree_on_overheal_chance
		if spawn_tree_on_overheal_chance > 0:
			if randi() % 100 < spawn_tree_on_overheal_chance:
				var new_cell: CellResource = add_rand_resource(Types.WOOD)
				if new_cell && randi() % 100 < damage_data_owner.weakening_chance:
					new_cell.set_effect(EffectManager.Effects.WEAKENED, true)

	var spawn_wood_to_the_right_chance: int = damage_data_owner.spawn_wood_to_the_right_chance
	if spawn_wood_to_the_right_chance > 0:
		if randi() % 100 < spawn_wood_to_the_right_chance:
			add_rand_resource_at(cells.find_key(healed_cell) + Vector2i.RIGHT, Types.WOOD)

	var reduce_cd_if_heal: float = damage_data_owner.reduce_cd_if_heal
	if reduce_cd_if_heal:
		damage_data_owner.reduce_cd_time(reduce_cd_if_heal)


func _apply_compiled_damage(cell: CellResource, ratio: float, compiled: Array, damage_data_owner: PlayerCell) -> void:
	var cell_data: CellResourceData = cell.data
	for i in compiled:
		var value: float = i.damage_value * ratio
		match i.type:
			DamageManager.Types.HIT:
				match i.stat:
					DamageManager.Stats.HP:
						cell.sub_hp(value)
						_award_resources_for_hit(cell, cell_data, value)
					DamageManager.Stats.LIFE_TIME:
						cell.sub_life_time(value)
			DamageManager.Types.HEAL:
				match i.stat:
					DamageManager.Stats.HP:
						cell.add_hp(value)
					DamageManager.Stats.LIFE_TIME:
						var overheal: float = cell.add_life_time(value)
						if damage_data_owner:
							_handle_druid_overheal_procs(damage_data_owner, cell, overheal)


func _on_cell_hitted(cell: CellResource, damage_data: Dictionary, spread_damage_data: Dictionary) -> void:
	var cells_to_damage: Dictionary = {cell: 1}
	if !spread_damage_data.is_empty():
		if spread_damage_data.to > 0 && spread_damage_data.ratio > 0:
			cells_to_damage.merge(get_cells_to_spread_damage(cell, spread_damage_data.to, spread_damage_data.ratio))

	var base_damage_data: Dictionary = damage_data[DamageManager.DamageDataTypes.BASE]
	var bonus_damage_data: Dictionary = damage_data.get(DamageManager.DamageDataTypes.BONUS, {})
	var damage_mult: float = damage_data.get(DamageManager.DamageDataTypes.MULT, 1)
	var compiled_damage: Array = []
	for type in base_damage_data:
		var base_type_data: Dictionary = base_damage_data[type]
		var bonus_type_data: Dictionary = bonus_damage_data.get(type, {})
		for stat in base_type_data:
			var damage_value: int = round((base_type_data[stat] + bonus_type_data.get(stat, 0)) * damage_mult)
			if damage_value != 0:
				compiled_damage.append({"type": type, "stat": stat, "damage_value": damage_value})

	var damage_data_owner: PlayerCell = damage_data.get("owner")
	for c in cells_to_damage:
		_apply_compiled_damage(c, cells_to_damage[c], compiled_damage, damage_data_owner)
		var cell_data: CellResourceData = c.data
		hit_handled.emit(c, cell_data)
		if c.hp <= 0:
			handle_cell_death_func(cell_data, c)
			cell_died.emit(c)


func handle_cell_death_func(data: CellResourceData, cell: CellResource) -> void:
	match data._name:
		Names.WOOD_FOREST:
			if first_forest_broken:
				return
			
			first_forest_broken = true
			
		Names.SPECIAL_LUMBERJACK:
			var cell_pos: Vector2 = cell.global_position + CELL_SIZE / 2
			G.projectile_manager.add_resource_axe(cell_pos, data.crit_chance, 2, data.dmg_ratio,
			get_rand_occupied_cell_global_center([cell], Types.WOOD), ProjectileDataModifiers.new(1.5, 0), [cell])
			if data.spawn_wood_chance > 0:
				if randi() % 100 < data.spawn_wood_chance:
					call_deferred("add_rand_resource_at", cells.find_key(cell), Types.WOOD)
			return
				
		Names.SPECIAL_OUTPOST:
			for i in data.attacks:
				var cell_pos: Vector2 = cell.global_position + CELL_SIZE / 2
				G.projectile_manager.add_resource_bullet(cell_pos, 0, 2,
				cell_pos.direction_to(get_rand_occupied_cell_global_center([cell])), 
				ProjectileDataModifiers.new(1.5, data.weakening_chance), [cell], 0.1 * i)
			return


func kill_grid() -> void:
	for i in range(occupied_cells.size() - 1, -1, -1):
		var c: CellResource = occupied_cells[i]
		c._on_hitted({DamageManager.DamageDataTypes.BASE: DamageManager.new_damage_data({}, DamageManager.new_data(c.data.durability))}, {})


func kill_cell(target: CellResource) -> void:
	target._on_hitted({DamageManager.DamageDataTypes.BASE: DamageManager.new_damage_data({}, DamageManager.new_data(target.data.durability))}, {})


func get_cells_to_spread_damage(exclude: CellResource, amount: int, ratio: float) -> Dictionary:
	if occupied_cells.is_empty():
		return {}
		
	var cells_to_damage: Dictionary = {}
	var temp_occupied_cells: Array = occupied_cells.duplicate()
	for i in amount:
		if temp_occupied_cells.has(exclude):
			temp_occupied_cells.erase(exclude)
			
		if temp_occupied_cells.is_empty():
			return cells_to_damage
			
		var cell: CellResource = temp_occupied_cells.pick_random()
		cells_to_damage[cell] = ratio
		exclude = cell

	return cells_to_damage


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


func add_resource_at(coords: Vector2i, _name: Names) -> CellResource:
	var cell: CellResource = cells.get(coords, null)
	if !is_instance_valid(cell) || !free_cells.has(cell):
		return null
	
	set_cell_data(cell, all_data[_name])
	return cell


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
		"effects": []
	}

	# Temporary fix
	args.effects.append(EffectManager.Effects.BUFFED) if cell.is_buffed() else null
	args.effects.append(EffectManager.Effects.WEAKENED) if cell.is_weakened() else null

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
	
	var druid: PlayerCell = obelisk_links.get(obelisk)
	if is_instance_valid(druid): 
		druid.obelisks.erase(obelisk)
		
	obelisk_links.erase(obelisk)
	if free_druid_obelisks.has(obelisk):
		free_druid_obelisks.erase(obelisk)
		
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
		Names.WOOD_FOREST:
			var data: ForestData = all_data[Names.WOOD_FOREST]
			var coords: Vector2i = cells.find_key(cell)
			var directions: Array = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
			for i in range(randi_range(data.min_add_cells, data.max_add_cells)):
				if directions.is_empty():
					return
					
				var dir: Vector2i = directions.pick_random()
				directions.erase(dir)
				add_resource_at(coords + dir, Names.WOOD_GROVE)
			
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


func free_grid() -> void:
	for i in range(occupied_cells.size() - 1, -1, -1):
		free_cell(occupied_cells[i])


func get_exclude_for_druid_obelisk() -> Array:
	var exclude: Array = druid_obelisks.keys()
	for i in occupied_cells:
		if !i.is_buffed():
			continue
		
		exclude.append(i)
	
	return exclude


func get_grid_total_hp() -> int:
	var total: int = 0
	for i in occupied_cells:
		total += i.hp
	
	return total
