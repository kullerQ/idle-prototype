extends Node
class_name TimerManager

enum Types {
	NULL,
	CELL_SPAWN,

}
var timers: Dictionary = {}
var _default_wood_timer: DisplayableTimer
var _default_wood_wait_time: float = 8.0
## Injected by G; spawn timeouts call CellManager façade methods.
var cell_manager: CellManager
var expedition_manager: ExpeditionManager

signal timer_added(timer: Timer)
signal timer_removed(timer: Timer)


func _enter_tree() -> void:
	for i in range(1, Types.size()):
		timers[i] = {}

	add_cell_spawn_timer(DisplayableTimer.new(
		_default_wood_wait_time, Color(0.471, 0.404, 0.267)), CellManager.Types.WOOD)
	_default_wood_timer = get_res_timer(CellManager.Types.WOOD)


func _ready() -> void:
	for i in timers.values():
		for timer in i:
			timer.start()


func add_cell_spawn_timer(timer: DisplayableTimer, res_type: CellManager.Types) -> void:
	timers[Types.CELL_SPAWN][timer] = res_type
	timer.mytimeout.connect(_on_cell_spawn_timeout)
	add_timer(timer)


func add_special_cell_spawn_timer(res_name: CellManager.Names, wait_t: float, color: Color = Color("#9c0a00") ) -> Timer:
	var timer: DisplayableTimer = DisplayableTimer.new( wait_t, color )
	timers[Types.CELL_SPAWN][timer] = res_name
	timer.mytimeout.connect(_on_special_cell_spawn_timeout)
	add_timer(timer)
	if !expedition_manager or !expedition_manager.is_active:
		timer.start()

	return timer


func stop_timers() -> void:
	for i in timers.values():
		for timer in i:
			timer.stop()


func start_timers() -> void:
	for i in timers.values():
		for timer in i:
			timer.start()


func _on_special_cell_spawn_timeout(timer: DisplayableTimer) -> void:
	cell_manager.add_resource(timers[Types.CELL_SPAWN][timer])


func _on_cell_spawn_timeout(timer: DisplayableTimer) -> void:
	cell_manager.add_rand_resource(timers[Types.CELL_SPAWN][timer])


func add_timer(timer: DisplayableTimer) -> void:
	add_child(timer)
	timer_added.emit(timer)


func get_timer(timer_type: Types, value: int) -> DisplayableTimer:
	return timers[timer_type].find_key(value)


func get_res_timer(res_type: CellManager.Types) -> DisplayableTimer:
	return get_timer(Types.CELL_SPAWN, res_type)


func get_special_cell_timer(res_name: CellManager.Names) -> DisplayableTimer:
	return get_timer(Types.CELL_SPAWN, res_name)


func sub_timer_wait_t(timer_type: Types, value: int, amount: float) -> void:
	var timer: DisplayableTimer = get_timer(timer_type, value)
	timer.wait_time = max(0.1, timer.wait_time - amount)


func reset_upgrade_timers() -> void:
	if _default_wood_timer:
		_default_wood_timer.wait_time = _default_wood_wait_time
	var cell_spawn_timers: Dictionary = timers[Types.CELL_SPAWN]
	for timer in cell_spawn_timers.duplicate():
		if timer == _default_wood_timer:
			continue
		cell_spawn_timers.erase(timer)
		if is_instance_valid(timer):
			timer_removed.emit(timer)
			timer.queue_free()
