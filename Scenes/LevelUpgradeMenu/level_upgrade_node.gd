extends Control
class_name LevelUpgradeNode

@export var type: LevelUpgradeManager.Types
var path: int
@export var locked: bool = false
@export var next_node: LevelUpgradeNode
@export var cost: int = 100
var locked_for: Array = []
static var manager: UpgradeManager


func _ready() -> void:
	path = int(get_parent().name.split("_")[1])
	var button: Button = $Button
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	button.pressed.connect(_on_pressed)


func _on_mouse_entered() -> void:
	owner.show_tooltip(type, cost)


func _on_mouse_exited() -> void:
	owner.hide_tooltip(type)


func _on_pressed() -> void:
	if locked:
		return

	owner.upgrade_button_pressed.emit(self)


func unlock() -> void:
	locked = false


func unlock_next_node() -> void:
	if !next_node:
		return
		
	next_node.unlock()


func lock() -> void:
	locked = true
