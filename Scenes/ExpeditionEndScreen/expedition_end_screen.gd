extends NodePopupMenu
class_name ExpeditionEndScreen

@onready var button: AnimatedButton = $Graphics/MarginContainer/AnimatedButton
var manager: ExpeditionManager

func _ready():
	super()
	button.pressed_func = _on_end_pressed
	
func _on_end_pressed() -> void:
	await button.tw.finished
	G.close_menu(type)
	G.expedition_manager.end_expedition()
