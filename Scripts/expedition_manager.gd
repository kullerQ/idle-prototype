extends Node
class_name ExpeditionManager

enum Types {
	NULL,
	WHITE_TREE
}

enum Goals {
	NULL,
	FULL_CLEAR,
	BREAK_TARGETS,
}

const FOLDER_PATH: String = "res://Resources/Expeditions/"
const _REWARD_WHITE_TREE: ExpeditionRewardData = preload("res://Resources/ExpeditionRewards/expedition_reward_forest.tres")
const REWARD_DATA: Dictionary = {
	Types.WHITE_TREE: _REWARD_WHITE_TREE,
}

var cell_manager: CellManager
var projectile_manager: ProjectileManager
var timer_manager: TimerManager

var max_hp: float = 0
var current_expedition_info: Dictionary = {"type": Types.NULL, "level": 0, "goal": Goals.NULL}
var current_hp: float = 0
var connected_signals: Dictionary = {}
var target_cells: Array = []

signal expedition_selected(type: Types)
signal hp_changed(new_hp: float, max_hp: float)
signal expedition_started()
## Emitted when the expedition goal is met; UI opens the end screen.
signal expedition_completed()
signal expedition_ended()


static func get_expedition_path(type: ExpeditionManager.Types, level: int) -> String:
	if !type || level < 1:
		return ""

	var expedition_name: String = "%s_%d" %[Types.keys()[type].to_lower(), level]
	return FOLDER_PATH + expedition_name + ".json"


func select_expedition(type: Types, level: int = 1) -> void:
	expedition_selected.emit(type)
	cell_manager.free_grid()
	projectile_manager.free_all_projectiles()
	timer_manager.stop_timers()
	G.in_expedition = true
	call_deferred("start_expedition", type, level)


func start_expedition(type: Types, level: int = 1) -> void:
	load_expedition(type, level)
	expedition_started.emit()


func handle_expedition_result() -> void:
	var reward_data: ExpeditionRewardData = REWARD_DATA.get(current_expedition_info.type)
	if reward_data:
		print(reward_data.wood[current_expedition_info.level - 1])
	push_warning("WIP: Not implemented yet: expedition_reward")
	expedition_completed.emit()


func end_expedition() -> void:
	G.in_expedition = false
	max_hp = 0
	cell_manager.free_grid()
	expedition_ended.emit()
	timer_manager.start_timers()
	disconnect_signals()


func disconnect_signals() -> void:
	for i in connected_signals:
		var signal_and_callable: Array = connected_signals[i]
		var signal_name: StringName = signal_and_callable[0].get_name()
		var callable: Callable = signal_and_callable[1]
		if !i.is_connected(signal_name, callable):
			continue

		i.disconnect(signal_name, callable)


func load_expedition(type: Types, level: int = 1) -> void:
	if !type:
		return

	var data: Dictionary = get_data_from_json(get_expedition_path(type, level))
	if !data:
		return

	place_cells(data.cells)
	current_expedition_info.type = type
	current_expedition_info.level = level
	current_expedition_info.goal = int(data.goal)

	match int(data.goal):
		Goals.FULL_CLEAR:
			cell_manager.hit_handled.connect(_on_cell_hit_handled_full_clear)
			connected_signals[cell_manager] = [cell_manager.hit_handled, _on_cell_hit_handled_full_clear]
			max_hp = cell_manager.get_grid_total_hp()

		Goals.BREAK_TARGETS:
			target_cells = place_cells(data.target_cells)
			for i in target_cells:
				max_hp += i.data.durability

			cell_manager.hit_handled.connect(_on_cell_hit_handled_targets)
			connected_signals[cell_manager] = [cell_manager.hit_handled, _on_cell_hit_handled_targets]

	set_hp(max_hp)


func place_cells(data: Array) -> Array:
	var cells: Array = []
	for cell_data in data:
		cells.append(cell_manager.add_resource_at(Vector2i(cell_data.x, cell_data.y), cell_data.name))

	return cells


func get_data_from_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	var error: Error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			return data_received

		else:
			print("Unexpected data")
			return {}
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}


func _on_cell_hit_handled_full_clear(cell: CellResource, data: CellResourceData) -> void:
	if cell.hp <= 0:
		sub_hp(data.durability)
		return

	sub_hp(cell.hp)


func _on_cell_hit_handled_targets(cell: CellResource, data: CellResourceData) -> void:
	if !target_cells.has(cell):
		return

	if cell.hp <= 0:
		sub_hp(data.durability)
		target_cells.erase(cell)
		return

	sub_hp(cell.hp)


func sub_hp(amount: float) -> void:
	set_hp(current_hp - amount)


func set_hp(value: float) -> void:
	current_hp = value
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		handle_expedition_result()


# debug

func complete_expedition() -> void:
	match current_expedition_info.goal:
		Goals.FULL_CLEAR:
			cell_manager.kill_grid()

		Goals.BREAK_TARGETS:
			for i in target_cells:
				cell_manager.kill_cell(i)
