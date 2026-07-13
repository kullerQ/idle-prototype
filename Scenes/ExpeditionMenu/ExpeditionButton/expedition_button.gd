extends Control
class_name ExpeditionButton

@export var type: ExpeditionManager.Types
static var manager: ExpeditionManager

func _ready() -> void:
	$Button.pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	manager.select_expedition(type)
