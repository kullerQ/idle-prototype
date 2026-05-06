extends Node2D
class_name HitCircle

var tw: Tween

func _init(pos: Vector2) -> void:
	global_position = pos

func _ready() -> void:
	tw = create_tween()
	tw.tween_property(self, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	tw.kill()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 2, Color.WHITE)
