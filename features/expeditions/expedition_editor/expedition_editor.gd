extends CellManager
class_name ExpeditionEditor

## Standalone editor scene that extends CellManager.
## Relies on the public grid façade only: `cells`, `occupied_cells`, `get_data`, `set_cell_data`.
## Do not move those off CellManager without updating this editor.

@export var type: ExpeditionManager.Types
@export var goal: ExpeditionManager.Goals
@export var level: int = 1


func _input(event):
	if !(event is InputEventKey && event.is_pressed() && !event.echo):
		return

	if event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("editor_save"):
		save_expedition()


func save_expedition() -> void:
	if !type:
		return

	var path: String = ExpeditionManager.get_expedition_path(type, level)
	if path == "":
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var data: Dictionary = {}
	data["goal"] = goal
	data["cells"] = []
	data["target_cells"] = []
	for i in occupied_cells:
		var coords: Vector2i = cells.find_key(i)
		var cell_data: Dictionary = {"x": coords.x, "y": coords.y, "name": i.cell_name}
		if i.target && goal == ExpeditionManager.Goals.BREAK_TARGETS:
			data["target_cells"].append(cell_data)
			continue

		data["cells"].append(cell_data)

	var json_string: String = JSON.stringify(data)
	file.store_string(json_string)
	file.close()


func add_start_cells() -> void:
	pass
