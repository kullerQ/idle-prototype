extends Control
class_name UpgradeMenu

@onready var control = $Control

var tw: Tween

func _ready() -> void:
	G.upgrade_menu_open_requested.connect(_on_open_requested)
	G.upgrade_menu_close_requested.connect(_on_close_requested)
	hide()
	
func _on_open_requested() -> void:
	G.upgrade_menu_opened = true
	show()
	if tw:
		tw.kill()
		
	tw = create_tween()
	control.modulate.a = 0
	control.position.y = 4
	tw.set_parallel()
	tw.tween_property(control, "position:y", 0, 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(control, "modulate:a", 1, 0.19).set_ease(Tween.EASE_OUT)
	
func _on_close_requested() -> void:
	G.upgrade_menu_opened = false
	if tw:
		tw.kill()
		
	tw = create_tween()
	control.position.y = 0
	tw.set_parallel()
	tw.tween_property(control, "position:y", 4, 0.19).set_ease(Tween.EASE_OUT)
	tw.tween_property(control, "modulate:a", 0, 0.14).set_ease(Tween.EASE_OUT)
	await tw.finished
	hide()
