extends Control
class_name NodePopupMenu

## Menu host contract (Phase 6): subclasses connect open/close via G.menu_signals in _ready.
## Manager deps are injected by the composition root (Main/UI or Game) through setup() or
## assigned fields before _ready — not @onready G.* reads in leaf menus.

@onready var graphics = $Graphics
@onready var init_graphics_y: float = graphics.position.y
@export var type: UI.Menus
var tw: Tween


func _ready() -> void:
	hide()
	var arr: Array = G.menu_signals[type]
	arr[0].connect(_on_open_requested)
	arr[1].connect(_on_close_requested)


func _on_open_requested() -> void:
	G.level_upgrade_menu_close_requested.emit()
	show()
	if tw:
		tw.kill()
		
	tw = create_tween()
	graphics.modulate.a = 0
	graphics.position.y = init_graphics_y + 4
	tw.set_parallel()
	tw.tween_property(graphics, "position:y", init_graphics_y, 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(graphics, "modulate:a", 1, 0.19).set_ease(Tween.EASE_OUT)


func _on_close_requested() -> void:
	if tw:
		tw.kill()
		
	tw = create_tween()
	graphics.position.y = init_graphics_y
	tw.set_parallel()
	tw.tween_property(graphics, "position:y", init_graphics_y + 4, 0.19).set_ease(Tween.EASE_OUT)
	tw.tween_property(graphics, "modulate:a", 0, 0.14).set_ease(Tween.EASE_OUT)
	await tw.finished
	hide()
