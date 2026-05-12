extends Control
class_name LevelUpgradeNode

@export var type: LevelUpgradeManager.Types
@export var path: int
@export var locked: bool = true
@export var next_node: LevelUpgradeNode
static var manager: UpgradeManager

func _ready() -> void:
	var button: Button = $Button
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	button.pressed.connect(_on_pressed)
	
func _on_mouse_entered() -> void:
	owner.show_tooltip(type)
	
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
