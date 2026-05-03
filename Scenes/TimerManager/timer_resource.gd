extends Timer
class_name TimerResource

@export var type: CellResourceData.Types
static var cell_manager: CellManager

func _ready() -> void:
	timeout.connect(_on_timeout)
	
func _on_timeout() -> void:
	cell_manager.add_resource(type)
