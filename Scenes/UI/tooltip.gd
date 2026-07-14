extends Control
class_name Tooltip

@onready var label: Label = $LabelTooltip

var tw: Tween


func _ready() -> void:
	G.tooltip_requested.connect(_on_tooltip_requested)
	G.tooltip_close_required.connect(_on_tooltip_close_required)
	visibility_changed.connect(_on_visibility_changed)
	hide()


func _on_visibility_changed() -> void:
	set_physics_process(visible)


func _physics_process(delta: float) -> void:
	global_position = get_global_mouse_position()


func _on_tooltip_requested(_text: String) -> void:
	show()
	label.text = _text
	if tw:
		tw.kill()
		
	tw = create_tween()
	label.modulate.a = 0
	label.position.y = 4
	tw.set_parallel()
	tw.tween_property(label, "modulate:a", 1, 0.15).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "position:y", 0, 0.25).set_ease(Tween.EASE_OUT)


func _on_tooltip_close_required() -> void:
	if tw:
		tw.kill()
		
	tw = create_tween()
	tw.set_parallel()
	tw.tween_property(label, "modulate:a", 0, 0.15).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "position:y", 4, 0.25).set_ease(Tween.EASE_OUT)
	await tw.finished
	hide()
