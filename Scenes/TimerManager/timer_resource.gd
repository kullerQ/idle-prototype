extends Timer
class_name TimerResource

@export var type: Economy.Currencies
static var cell_manager: CellManager

func _init(_type: Economy.Currencies, wait_t: float) -> void:
	type = _type
	wait_time = wait_t

func _ready() -> void:
	timeout.connect(_on_timeout)
	
func _on_timeout() -> void:
	cell_manager.add_resource(type)
