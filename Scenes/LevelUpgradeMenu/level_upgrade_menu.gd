extends Control
class_name LevelUpgradeMenu

@onready var close_button: Button = $Graphics/Panel/Button
var cell: PlayerCell
@onready var label_tokens: Label = $Graphics/LabelTokens
@onready var upgrade_paths: Dictionary = {
	PlayerCellData.Types.SHOOTER: $Graphics/Panel/MarginContainer/UpgradesContainer/ShooterUpgrades,
	PlayerCellData.Types.ROGUE: $Graphics/Panel/MarginContainer/UpgradesContainer/RogueUpgrades,
	PlayerCellData.Types.DRUID: $Graphics/Panel/MarginContainer/UpgradesContainer/DruidUpgrades,
}
var nodes_to_hide: Array = []
var upgrade_path_type: Control
var upgrade_path: Control
var current_root: Control
@onready var panel = $Graphics/Panel

var manager: LevelUpgradeManager
#todo remove G dependency
@onready var economy: Economy = G.economy


signal upgrade_button_pressed(node: LevelUpgradeNode)

func _ready() -> void:
	hide()
	for i in $Graphics/Panel/MarginContainer/UpgradesContainer.get_children():
		i.hide()
		
	G.level_upgrade_menu_close_requested.connect(_on_level_upgrade_menu_close_requested)
	G.level_upgrade_menu_open_requested.connect(_on_level_upgrade_menu_open_requested)
	G.player_cell_manager.cell_lvled_up.connect(_on_cell_lvled_up)
	close_button.pressed.connect(_on_close_button_pressed)
	upgrade_button_pressed.connect(_on_upgrade_button_pressed)
	set_physics_process(false)
	
func _on_upgrade_button_pressed(node: LevelUpgradeNode) -> void:
	if node.locked_for.has(cell):
		return
		
#	if economy.get_resource(Economy.Currencies.XP) < node.cost:
#		return

	var type: LevelUpgradeManager.Types = node.type
	var path: int = node.path
	
	change_path(path)
		
#	node.unlock_next_node()
	economy.sub_resource(Economy.Currencies.XP, node.cost)
#	cell.sub_tokens()
	node.locked_for.append(cell)
	manager.apply_upgrade(type, cell)
#	label_tokens.text = "%d" %cell.lvl_tokens

func show_tooltip(type: LevelUpgradeManager.Types, cost: int) -> void:
	G.tooltip_requested.emit("%d xp\n%s" %[cost, manager.get_description(type)])

func hide_tooltip(type: LevelUpgradeManager.Types) -> void:
	G.tooltip_close_required.emit()

func change_path(path: int) -> void:
	for i in current_root.get_children():
		nodes_to_hide.append(i)
		if i.name == "Path_%d" %path:
			var node_root: Control = i.get_node_or_null("Root")
			if !node_root:
				return
				
			current_root = node_root
			for ii in current_root.get_children():
				nodes_to_hide.append(ii)
				ii.show()
				
			current_root.show()
			nodes_to_hide.append(current_root)
			continue
		
		i.hide()
		
#	current_root = current_root.get_node("Path_%d" %path).get_node("Root")
#	current_root.show()
	cell.upgrade_path.append(path)# = path
#	upgrade_path.hide()
#	nodes_to_hide.erase(upgrade_path)
##	upgrade_path = get_upgrade_path()
#	upgrade_path.show()
#	nodes_to_hide.append(upgrade_path)
	
func _on_cell_lvled_up(_cell: PlayerCell, lvl: int) -> void:
	if cell != _cell:
		return
	
	label_tokens.text = "%d" %cell.lvl_tokens
	
func _on_close_button_pressed() -> void:
	G.level_upgrade_menu_close_requested.emit()
	
func _on_level_upgrade_menu_close_requested() -> void:
	set_physics_process(false)
	cell = null
	hide_paths()
	hide()
	
func hide_paths() -> void:
	for i in nodes_to_hide:
		i.hide()
	
	nodes_to_hide = []

func show_upgrade_path() -> void:
	# dumb but works i guess 
	var init_root: Control = upgrade_path_type.get_node("Root")
	init_root.show()
	current_root = init_root
	if cell.upgrade_path.is_empty():
		for i in init_root.get_children():
			i.show()
		
		return
	
	for idx in cell.upgrade_path:
		for i in current_root.get_children():
			nodes_to_hide.append(i)
			if i.name == "Path_%d" %idx:
				i.show()
				var node_root: Control = i.get_node_or_null("Root")
				if !node_root:
					return
					
				current_root = node_root
				for ii in current_root.get_children():
					nodes_to_hide.append(ii)
					ii.show()
					
				current_root.show()
				nodes_to_hide.append(current_root)
				continue
			
			i.hide()
			
	
func _on_level_upgrade_menu_open_requested(_cell: PlayerCell) -> void:
	if G.upgrade_menu_opened:
		return
		
	if !nodes_to_hide.is_empty():
		hide_paths()
	
#	await get_tree().process_frame
	panel.call_deferred("set", "size", Vector2.ZERO)
#	panel.size = Vector2.ZERO
		
	cell = _cell
	var cell_type: PlayerCellData.Types = cell.data.type
	if !upgrade_paths.has(cell_type):
		G.level_upgrade_menu_close_requested.emit()
		return
		
	upgrade_path_type = upgrade_paths[cell_type]
	upgrade_path_type.show()
	nodes_to_hide.append(upgrade_path_type)
	show_upgrade_path()
#	upgrade_path = get_upgrade_path()
#	upgrade_path.show()
#	nodes_to_hide.append(upgrade_path)
	
	global_position = cell.global_position + Vector2(12, 0)
	label_tokens.text = "%d" %cell.lvl_tokens
	show()
