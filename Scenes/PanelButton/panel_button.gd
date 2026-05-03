extends Control
class_name PanelButton

var label: Label
var text: String
@onready var button = $Button
var pressed_func: Callable
static var container: ButtonContainer

var tw: Tween

func initialize(_text: String, _pressed_func: Callable, xsize: int = 25) -> void:
	text = _text
	custom_minimum_size.x = xsize
	pressed_func = _pressed_func

func _ready() -> void:
	if !container.is_node_ready():
		await container.ready
	
	await get_tree().process_frame
	label = G.ui.add_label(self, global_position - Vector2(0, 1), text)
	button.pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	if tw:
		tw.kill()
		
	tw = create_tween()
	button.position.y = 3
	button.pivot_offset = button.size / 2
	button.rotation = deg_to_rad(-15)
	label.position.y = 3
	tw.set_parallel()
	tw.tween_property(button, "position:y", 0, 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(button, "rotation", 0, 0.45).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "position:y", 0, 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		pressed_func.call()).set_delay(0.05)
