extends GridContainer
class_name PlayerCellManager

var cells: Dictionary = {}
var all_data: Dictionary = {
	PlayerCellData.Types.SHOOTER: load("uid://d1lppkhdp8brh")
}
var start_pos: Vector2i = Vector2i(4, 6)

func _enter_tree() -> void:
	G.upgrade_manager.player_cell_manager = self

func _ready() -> void:
#	print(all_data[PlayerCellData.Types.SHOOTER].cooldown)
	var pos: Vector2i = Vector2i.ZERO
	for c in get_children():
		cells[pos] = c
		if pos.x + 1 == columns:
			pos.x = 0
			pos.y += 1
			continue
			
		pos.x += 1
		
	cells[start_pos].set_data(all_data[PlayerCellData.Types.SHOOTER])

func get_data(type: PlayerCellData.Types) -> PlayerCellData:
	return all_data[type]
