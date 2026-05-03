extends Node
class_name TimerManager

@onready var timers: Dictionary = {
	CellResourceData.Types.WOOD: $TimerWood
}

func get_timer(type: CellResourceData.Types) -> TimerResource:
	return timers[type]
