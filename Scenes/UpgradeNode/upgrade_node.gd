extends Control
class_name UpgradeNode

@export var data: UpgradeNodeData
var nodes: Array = []
@export var lvl: int = 0
@export var locked: bool = true

@onready var label_cost: Label = $VBoxContainer/LabelCost
@onready var label_lvl : Label = $VBoxContainer/LabelLvl
@onready var button: Button = $Button

static var economy: Economy
static var upgrade_manager: UpgradeManager

func _ready() -> void:
	if locked:
		hide()
	else:
		add_lvl()
		
	var parent: Node = get_parent()
	if parent is UpgradeNode:
		parent.nodes.append(self)
	
	label_lvl.text = "%d/%d" %[lvl, data.max_lvl]
	label_cost.text = "%d" %data.cost
	button.pressed.connect(_on_pressed)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	
func _on_mouse_entered() -> void:
	G.tooltip_requested.emit(upgrade_manager.get_description(data.type))
	
func _on_mouse_exited() -> void:
	G.tooltip_close_required.emit()
	
func unlock() -> void:
	show()
	
func add_lvl() -> void:
	lvl += 1
	if lvl >= data.max_lvl:
		label_cost.hide()

	label_lvl.text = "%d/%d" %[lvl, data.max_lvl]
	for n in range(nodes.size() - 1, -1, -1):
		var node: UpgradeNode = nodes[n]
		if node.data.unlock_lvl <= lvl:
			node.unlock()
			nodes.remove_at(n)
	
func _on_pressed() -> void:
	if data.type == 0:
		return
		
	if lvl == data.max_lvl:
		return
		
	if data.cost > economy.get_resource(data.resource):
		return
	
	add_lvl()
	economy.sub_resource(data.resource, data.cost)
	upgrade_manager.upgrade_purchased.emit(data.type)
