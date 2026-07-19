class_name CellCombatResolver
extends RefCounted

## Hit/damage resolve for the resource grid. Emits via CellManager signals.

var _manager: CellManager


func _init(manager: CellManager) -> void:
	_manager = manager


func on_cell_hitted(cell: CellResource, damage_data: Dictionary, spread_damage_data: Dictionary) -> void:
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
		_manager.hit_handled.emit(c, cell_data)
		if c.hp <= 0:
			_manager.specials.handle_cell_death_func(cell_data, c)
			_manager.cell_died.emit(c)


func kill_grid() -> void:
	for i in range(_manager.occupied_cells.size() - 1, -1, -1):
		var c: CellResource = _manager.occupied_cells[i]
		c._on_hitted({DamageManager.DamageDataTypes.BASE: DamageManager.new_damage_data({}, DamageManager.new_data(c.data.durability))}, {})


func kill_cell(target: CellResource) -> void:
	target._on_hitted({DamageManager.DamageDataTypes.BASE: DamageManager.new_damage_data({}, DamageManager.new_data(target.data.durability))}, {})


func get_cells_to_spread_damage(exclude: CellResource, amount: int, ratio: float) -> Dictionary:
	if _manager.occupied_cells.is_empty():
		return {}

	var cells_to_damage: Dictionary = {}
	var temp_occupied_cells: Array = _manager.occupied_cells.duplicate()
	for i in amount:
		if temp_occupied_cells.has(exclude):
			temp_occupied_cells.erase(exclude)

		if temp_occupied_cells.is_empty():
			return cells_to_damage

		var cell: CellResource = temp_occupied_cells.pick_random()
		cells_to_damage[cell] = ratio
		exclude = cell

	return cells_to_damage


# TODO: Fix data-type inconsistency
func _award_resources_for_hit(cell: CellResource, cell_data: CellResourceData, value: float) -> void:
	if !cell_data.value:
		return
	if cell.is_buffed():
		value *= 2
	_manager.add_res(cell_data.type, cell_data.value * value)


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
							_manager.druid.handle_druid_overheal_procs(damage_data_owner, cell, overheal)
