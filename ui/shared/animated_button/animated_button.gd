extends Control
class_name AnimatedButton

var label: Label
@export var text: String
@onready var button = $Button
var pressed_func: Callable
@onready var _owner: Node = owner
var label_factory: Callable

var tw: Tween


func initialize(_text: String, _pressed_func: Callable, xsize: int = 25) -> void:
	text = _text
	custom_minimum_size.x = xsize
	pressed_func = _pressed_func


func setup_label_factory(factory: Callable) -> void:
	label_factory = factory


func _ready() -> void:
	if !_owner.is_node_ready():
		await _owner.ready

	await get_tree().process_frame

	if text != "":
		label = _create_label()

	_owner.visibility_changed.connect(_on_visibility_changed)
	if label:
		label.visible = _owner.visible
	button.pressed.connect(_on_pressed)


func _create_label() -> Label:
	var pos: Vector2 = global_position - Vector2(0, 1)
	if label_factory.is_valid():
		return label_factory.call(self, pos, text)
	if G.ui:
		if OS.is_debug_build():
			push_warning(
				"AnimatedButton '%s': using G.ui fallback; inject label_factory from host" % name
			)
		return G.ui.add_label(self, pos, text)
	if OS.is_debug_build():
		push_warning("AnimatedButton '%s': no label_factory and G.ui unavailable" % name)
	return null


func _on_visibility_changed() -> void:
	if label:
		label.visible = _owner.visible


func _on_pressed() -> void:
	if tw:
		tw.kill()
		
	tw = create_tween()
	button.position.y = 3
	button.pivot_offset = button.size / 2
	button.rotation = deg_to_rad(-15)
	if label:
		label.position.y = 3
	tw.set_parallel()
	tw.tween_property(button, "position:y", 0, 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(button, "rotation", 0, 0.45).set_ease(Tween.EASE_OUT)
	if label:
		tw.tween_property(label, "position:y", 0, 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		pressed_func.call()).set_delay(0.05)
