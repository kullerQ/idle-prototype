extends Control
class_name UpgradeNode

@export_group("data")
@export var type: UpgradeManager.Types
@export var max_lvl: int
@export var unlock_lvl: int
@export_subgroup("cost")
@export var wood: int = 0
@export var free_cells: int = 0
@export_enum(UpgradeManager.Types) var aa: UpgradeManager.Types
@export_group("")
var cost: Dictionary = {}

var nodes: Array = []
@export var lvl: int = 0
@export var locked: bool = true

@onready var label_cost: Label = $VBoxContainer/LabelCost
@onready var label_lvl : Label = $VBoxContainer/LabelLvl
@onready var button: Button = $Button
@onready var debugbtn = $Button2

static var economy: Economy
static var upgrade_manager: UpgradeManager

func _ready() -> void:
	if locked:
		hide()
	
	set_lvl(lvl)
	var parent: Node = get_parent()
	var currencies_names: Array = Economy.Currencies.keys()
	for i in range(1, Economy.Currencies.size()):
		var v: int = get(currencies_names[i].to_lower())
		if v == 0:
			continue
			
		cost[i] = v
	
		
	if parent is UpgradeNode:
		parent.nodes.append(self)
	
	label_lvl.text = "%d/%d" %[lvl, max_lvl]
	label_cost.text = get_cost_text()
	button.pressed.connect(_on_pressed)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	
func get_cost_text() -> String:
	print(cost)
	var cost_t: String = ""
	for i in cost:
		var v: int = cost[i]
		if v > 0:
			cost_t += "%d  |  " %v
	
	return cost_t
	
func _on_mouse_entered() -> void:
	G.tooltip_requested.emit(upgrade_manager.get_description(type))
	
func _on_mouse_exited() -> void:
	G.tooltip_close_required.emit()
	
func unlock() -> void:
	show()
	
func add_lvl() -> void:
	set_lvl(lvl + 1)

func set_lvl(new_lvl: int) -> void:
	lvl = new_lvl
	if lvl >= max_lvl:
		label_cost.hide()

	label_lvl.text = "%d/%d" %[lvl, max_lvl]
	for n in range(nodes.size() - 1, -1, -1):
		var node: UpgradeNode = nodes[n]
		if node.unlock_lvl <= lvl:
			node.unlock()
			nodes.remove_at(n)

func _on_pressed() -> void:
	if type == 0:
		return
		
	if lvl == max_lvl:
		return
		
	for k in cost:
		if cost[k] > economy.get_resource(k):
			return
	
	add_lvl()
	economy.sub_resource_dict(cost)
	upgrade_manager.upgrade_purchased.emit(type)

#func _on_debug_pressed() -> void:
#
##	= 	label_cost.text = get_cost_text()
