extends Node
class_name TimerManager

enum Types {
	NULL,
	CELL_SPAWN,

}
var timers: Dictionary = {}
var cell_manager: CellManager

signal timer_added(timer: Timer)


func _enter_tree() -> void:
	for i in range(1, Types.size()):
		timers[i] = {}
		
	add_cell_spawn_timer(DisplayableTimer.new( 
		8, Color(0.471, 0.404, 0.267)), CellManager.Types.WOOD)


func _ready() -> void:
	for i in timers.values():
		for timer in i:
			timer.start()


#func add_resource_timers() -> void:
#	var keys: PackedStringArray = CellManager.Types.keys()
#	for i in range(1, CellManager.Types.size()):
#		if keys[i] == "SPECIAL":
#			continue
#
#		var timer: TimerResource = TimerResource.new(8, Color(0.471, 0.404, 0.267))
#		timer.set_type(i)
#		add_timer(timer, i, Types.RESOURCES)


func add_cell_spawn_timer(timer: DisplayableTimer, res_type: CellManager.Types) -> void:
	timers[Types.CELL_SPAWN][timer] = res_type
	timer.mytimeout.connect(_on_cell_spawn_timeout)
	add_timer(timer)


func add_special_cell_spawn_timer(res_name: CellManager.Names, wait_t: float, color: Color = Color("#9c0a00") ) -> Timer:
	var timer: DisplayableTimer = DisplayableTimer.new( wait_t, color )
	timers[Types.CELL_SPAWN][timer] = res_name
	timer.mytimeout.connect(_on_special_cell_spawn_timeout)
	add_timer(timer)
	if !G.in_expedition:
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


#func add_lumberjack_timer() -> void:
#	var wait_t: float = cell_manager.get_data(CellManager.Names.SPECIAL_LUMBERJACK).life_time
#	var timer: DisplayableTimer = DisplayableTimer.new( wait_t,  )
#	add_special_cell_spawn_timer(timer, CellManager.Names.SPECIAL_LUMBERJACK)
#	timer.start()
#
#
#func add_outpost_timer() -> void:
#	var wait_t: float = cell_manager.get_data(CellManager.Names.SPECIAL_OUTPOST).life_time
#	var timer: DisplayableTimer = DisplayableTimer.new( wait_t, Color(0.714, 0.576, 0.373) )
#	add_special_cell_spawn_timer(timer, CellManager.Names.SPECIAL_LUMBERJACK)
#	timer.start()
	
		
#	var timer: DisplayableTimer = DisplayableTimer.new( 15, Color(0.714, 0.576, 0.373) )
#	add_timer(timer, CellManager.Names.SPECIAL_LUMBERJACK, Types.CELL_SPAWN)
