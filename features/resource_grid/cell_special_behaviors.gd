class_name CellSpecialBehaviors
extends RefCounted

## Special cell death / occupy hooks (lumberjack, outpost, forest spawn).

var _manager: CellManager
var projectile_manager: ProjectileManager
var first_forest_broken: bool = false


func _init(manager: CellManager) -> void:
	_manager = manager


func handle_cell_death_func(data: CellResourceData, cell: CellResource) -> void:
	match data._name:
		CellManager.Names.WOOD_FOREST:
			if first_forest_broken:
				return

			first_forest_broken = true

		CellManager.Names.SPECIAL_LUMBERJACK:
			var cell_pos: Vector2 = cell.global_position + CellManager.CELL_SIZE / 2
			projectile_manager.add_resource_axe(cell_pos, data.crit_chance, 2, data.dmg_ratio,
			_manager.get_rand_occupied_cell_global_center([cell], CellManager.Types.WOOD), ProjectileDataModifiers.new(1.5, 0), [cell])
			if data.spawn_wood_chance > 0:
				if randi() % 100 < data.spawn_wood_chance:
					_manager.call_deferred("add_rand_resource_at", _manager.cells.find_key(cell), CellManager.Types.WOOD)
			return

		CellManager.Names.SPECIAL_OUTPOST:
			for i in data.attacks:
				var cell_pos: Vector2 = cell.global_position + CellManager.CELL_SIZE / 2
				projectile_manager.add_resource_bullet(cell_pos, 0, 2,
				cell_pos.direction_to(_manager.get_rand_occupied_cell_global_center([cell])),
				ProjectileDataModifiers.new(1.5, data.weakening_chance), [cell], 0.1 * i)
			return


func before_set_cell_data(data: CellResourceData) -> bool:
	if !_manager.is_cell_special(data._name):
		return true

	match data._name:
		CellManager.Names.SPECIAL_LUMBERJACK:
			var lumberjack_count: int = _manager.spawned_special_cells[CellManager.Names.SPECIAL_LUMBERJACK].size()
			if lumberjack_count >= _manager.max_lumberjack_count:
				for i in range(lumberjack_count, 0, -1):
					_manager.respawn_res_at_rand_cell(_manager.spawned_special_cells[CellManager.Names.SPECIAL_LUMBERJACK][i - 1])

				return false

	return true


func on_cell_occupied(cell: CellResource) -> void:
	var _name: CellManager.Names = cell.data._name

	match _name:
		CellManager.Names.WOOD_FOREST:
			var data: ForestData = _manager.all_data[CellManager.Names.WOOD_FOREST]
			var coords: Vector2i = _manager.cells.find_key(cell)
			var directions: Array = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
			for i in range(randi_range(data.min_add_cells, data.max_add_cells)):
				if directions.is_empty():
					return

				var dir: Vector2i = directions.pick_random()
				directions.erase(dir)
				_manager.add_resource_at(coords + dir, CellManager.Names.WOOD_GROVE)

		CellManager.Names.SPECIAL_DRUID_OBELISK:
			_manager.druid.on_obelisk_occupied(cell)
			return

	if _manager.is_cell_special(_name):
		return

	_manager.druid.on_wood_cell_occupied()
