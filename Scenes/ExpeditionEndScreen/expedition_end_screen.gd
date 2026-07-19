extends NodePopupMenu
class_name ExpeditionEndScreen

@onready var button: AnimatedButton = $Graphics/MarginContainer/AnimatedButton
var manager: ExpeditionManager


func _ready():
	super()
	button.pressed_func = _on_end_pressed
	manager.expedition_completed.connect(_on_expedition_completed)


func _on_expedition_completed() -> void:
	G.call_deferred("open_menu", type)


func _on_end_pressed() -> void:
	await button.tw.finished
	G.close_menu(type)
	manager.end_expedition()
