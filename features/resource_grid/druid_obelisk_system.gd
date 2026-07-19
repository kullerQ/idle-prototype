class_name DruidObeliskSystem
extends RefCounted

## Druid obelisk graph: links, buffs, overheal procs.

var _manager: CellManager

var obelisk_links: Dictionary = {} # key: obelisk → owner PlayerCell
var druid_obelisks: Dictionary = {} # key: obelisk → [buffed_cells ...]
var free_druid_obelisks: Dictionary = {} # key: obelisk → available buff slots


func _init(manager: CellManager) -> void:
	_manager = manager


func handle_druid_overheal_procs(damage_data_owner: PlayerCell, healed_cell: CellResource, overheal: float) -> void:
	if damage_data_owner.data.type != PlayerCellData.Types.DRUID:
		return

	if overheal > 0.1:
		var obelisk_spawn_chance: int = damage_data_owner.obelisk_spawn_chance
		if obelisk_spawn_chance > 0:
			if damage_data_owner.obelisks.size() < damage_data_owner.max_obelisks:
				if randi() % 100 < obelisk_spawn_chance:
					var obelisk: CellResource = _manager.add_resource(CellManager.Names.SPECIAL_DRUID_OBELISK)
					if obelisk:
						damage_data_owner.obelisks.append(obelisk)
						obelisk_links[obelisk] = damage_data_owner

		var cell_lvlup_chance: int = damage_data_owner.cell_lvlup_chance
		if cell_lvlup_chance > 0:
			if randi() % 100 < cell_lvlup_chance:
				_manager.lvlup_cell(healed_cell)

		var spawn_tree_on_overheal_chance: int = damage_data_owner.spawn_tree_on_overheal_chance
		if spawn_tree_on_overheal_chance > 0:
			if randi() % 100 < spawn_tree_on_overheal_chance:
				var new_cell: CellResource = _manager.add_rand_resource(CellManager.Types.WOOD)
				if new_cell && randi() % 100 < damage_data_owner.weakening_chance:
					new_cell.set_effect(EffectManager.Effects.WEAKENED, true)

	var spawn_wood_to_the_right_chance: int = damage_data_owner.spawn_wood_to_the_right_chance
	if spawn_wood_to_the_right_chance > 0:
		if randi() % 100 < spawn_wood_to_the_right_chance:
			_manager.add_rand_resource_at(_manager.cells.find_key(healed_cell) + Vector2i.RIGHT, CellManager.Types.WOOD)

	var reduce_cd_if_heal: float = damage_data_owner.reduce_cd_if_heal
	if reduce_cd_if_heal:
		damage_data_owner.reduce_cd_time(reduce_cd_if_heal)


func on_obelisk_occupied(cell: CellResource) -> void:
	druid_obelisks[cell] = []
	var buff_cell_amount: int = cell.data.buff_cell_amount
	if buff_cell_amount <= 0:
		return

	var remain: int = handle_obelisk_buff(cell, cell.data.buff_cell_amount)
	if remain:
		free_druid_obelisks[cell] = remain


func on_wood_cell_occupied() -> void:
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


func on_cell_freed(cell: CellResource, _name: CellManager.Names) -> void:
	if druid_obelisks.is_empty():
		return

	if _name == CellManager.Names.SPECIAL_DRUID_OBELISK:
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


func handle_obelisk_buff(obelisk: CellResource, buff_cell_amount: int) -> int:
	if !is_instance_valid(obelisk):
		free_druid_obelisk(obelisk)
		return 0

	var available_cell_amount: int = _manager.occupied_cells.size() - druid_obelisks.size()
	if available_cell_amount <= 0:
		return buff_cell_amount

	var exclude: Array = get_exclude_for_druid_obelisk()
	if buff_cell_amount > 1:

		for i in available_cell_amount:
			var target_cell: CellResource = _manager.get_rand_occupied_cell(exclude)
			if target_cell:
				target_cell.set_effect(EffectManager.Effects.BUFFED, true)
				druid_obelisks[obelisk].append(target_cell)
				exclude.append(target_cell)
				buff_cell_amount -= 1
				if buff_cell_amount == 0:
					break

	else:
		var target_cell: CellResource = _manager.get_rand_occupied_cell(exclude)
		if target_cell:
			target_cell.set_effect(EffectManager.Effects.BUFFED, true)
			druid_obelisks[obelisk].append(target_cell)
			return 0

	return buff_cell_amount


func get_exclude_for_druid_obelisk() -> Array:
	var exclude: Array = druid_obelisks.keys()
	for i in _manager.occupied_cells:
		if !i.is_buffed():
			continue

		exclude.append(i)

	return exclude
