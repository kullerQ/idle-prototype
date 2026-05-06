extends Control
class_name UIPP

var label_crit_scene: PackedScene = load("uid://2ecp1ltsrumb")

func _ready() -> void:
	G.crit_label_requested.connect(_on_crit_label_requested)
	
func _on_crit_label_requested(pos: Vector2) -> void:
	var label: LabelCrit = label_crit_scene.instantiate()
	label.global_position = pos
	add_child(label)

