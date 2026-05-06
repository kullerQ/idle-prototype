extends Control
class_name LabelCrit

@onready var label: Label = $Label
var tw: Tween

func _ready() -> void:
	tw = create_tween()
	tw.set_parallel()
	tw.tween_property(label, "modulate:a", 0, 0.12).set_delay(0.2)
	tw.tween_property(label, "position:y", -12, 0.35).set_ease(Tween.EASE_OUT)
	await tw.finished
	queue_free()
