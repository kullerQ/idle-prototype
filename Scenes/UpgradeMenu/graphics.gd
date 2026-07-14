extends Control
class_name UpgradeMenuGraphics

@onready var rect: Rect2 = get_rect()
var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var min_scale: float = 0.7
var scroll_speed: float = 0.03
@onready var parent: UpgradeMenu = owner


func _input(event: InputEvent) -> void:
	if !rect.has_point(get_global_mouse_position()) && !is_dragging:
		return

	if !parent.visible:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			resize_container(scroll_speed)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			resize_container(-scroll_speed)

		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				last_mouse_pos = event.position
			else:
				is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		var delta = -event.relative / scale
		position -= delta


func resize_container(amount: float) -> void:
	var new_scale = scale + Vector2(amount, amount)
	pivot_offset = get_local_mouse_position()
	new_scale.x = clamp(new_scale.x, min_scale, 1)
	new_scale.y = clamp(new_scale.y, min_scale, 1)
	scale = new_scale
