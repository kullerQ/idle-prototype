extends DisplayableTimer
class_name TimerResource

var type: CellManager.Types
var cell_manager: CellManager


func _init(wait_t: float, _color: Color, _type: CellManager.Types, _cell_manager: CellManager = null) -> void:
	super(wait_t, _color)
	type = _type
	cell_manager = _cell_manager


func set_type(_type: CellManager.Types) -> void:
	type = _type


func set_cell_manager(_cell_manager: CellManager) -> void:
	cell_manager = _cell_manager


func _ready() -> void:
	timeout.connect(_on_timeout)


func _on_timeout() -> void:
	cell_manager.add_rand_resource(type)
