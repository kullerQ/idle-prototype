extends CellResource
class_name ExpeditionEditorCellResource

@export var cell_name: CellManager.Names
@export var target: bool = false


func _ready() -> void:
	super()
	if cell_name:
		manager.call_deferred("set_cell_data", self, manager.get_data(cell_name))
