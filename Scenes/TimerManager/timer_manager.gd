extends Node
class_name TimerManager

var timers: Dictionary = {}

func _enter_tree() -> void:
	add_timers()

func _ready() -> void:
	for i in timers.values():
		i.start()

func add_timers() -> void:
	for i in Economy.Currencies.values():
		if i == 0 || Economy.exclusive_resources.has(i):
			continue
		
		var timer: TimerResource = TimerResource.new(i, 8)
		timers[i] = timer
		add_child(timer)
		
func get_timer(type: Economy.Currencies) -> TimerResource:
	return timers[type]
