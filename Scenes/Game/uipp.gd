extends Control
class_name UIPP

enum Layouts {
	NULL,
	BASE,
	EXPEDITION
}

var label_crit_scene: PackedScene = preload("res://Scenes/LabelCrit/label_crit.tscn")
var timer_ui: TimerUI
var expedition_ui: ExpeditionUI

var layouts_visibility: Dictionary = {
	Layouts.BASE: ["timer_ui"],
	Layouts.EXPEDITION: ["expedition_ui"],
}
var visible_ui: Array = []
var layout: Layouts


func _ready() -> void:
	G.crit_label_requested.connect(_on_crit_label_requested)
	G.ui_layout_change_requested.connect(set_layout)


func _on_crit_label_requested(pos: Vector2) -> void:
	var label: LabelCrit = label_crit_scene.instantiate()
	label.global_position = pos
	add_child(label)


func add_element(node: Node) -> void:
	add_child(node)
	var formatted_name: String = node.name.to_snake_case()
	set(formatted_name, node)
	if !get(formatted_name):
		print("uipp don't have var \"%s\" " %formatted_name)
		return
	
	visible_ui.append(node)


func set_layout(new_layout: Layouts) -> void:
	if layout == new_layout:
		return
	
	layout = new_layout
	if !visible_ui.is_empty():
		for i in range(visible_ui.size() - 1, -1, -1):
			visible_ui[i].hide()
			visible_ui.remove_at(i)
			
	for i in layouts_visibility[layout]:
		var node: Node = get(i)
		if !node:
			continue
			
		node.show()
		visible_ui.append(node)
