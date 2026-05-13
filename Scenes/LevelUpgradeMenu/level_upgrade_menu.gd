extends Control
class_name LevelUpgradeMenu

@onready var close_button: Button = $Graphics/Button
@onready var progress_bar: ProgressBar = $Graphics/MarginContainer/VBoxContainer/ProgressBar
var cell: PlayerCell
@onready var label_lvl: Label = $Graphics/MarginContainer/VBoxContainer/ProgressBar/LabelLvl
@onready var label_tokens: Label = $Graphics/LabelTokens
@onready var upgrade_paths: Dictionary = {
	PlayerCellData.Types.SHOOTER: $Graphics/MarginContainer/VBoxContainer/ShooterUpgrades,
	PlayerCellData.Types.ROGUE: $Graphics/MarginContainer/VBoxContainer/RogueUpgrades,
	PlayerCellData.Types.DRUID: $Graphics/MarginContainer/VBoxContainer/DruidUpgrades,
}
var nodes_to_hide: Array = []
var upgrade_path_type: Control
var upgrade_path: Control
var manager: LevelUpgradeManager

signal upgrade_button_pressed(node: LevelUpgradeNode)

func _ready() -> void:
	hide()
	G.level_upgrade_menu_close_requested.connect(_on_level_upgrade_menu_close_requested)
	G.level_upgrade_menu_open_requested.connect(_on_level_upgrade_menu_open_requested)
	G.player_cell_manager.cell_lvled_up.connect(_on_cell_lvled_up)
	close_button.pressed.connect(_on_close_button_pressed)
	upgrade_button_pressed.connect(_on_upgrade_button_pressed)
	set_physics_process(false)
	
func _on_upgrade_button_pressed(node: LevelUpgradeNode) -> void:
	var type: LevelUpgradeManager.Types = node.type
	var path: int = node.path
	if node.locked_for.has(cell):
		return
		
	if cell.lvl_tokens < 1:
		return
	
	if path:
		change_path(path)
		
	node.unlock_next_node()
	cell.sub_tokens()
	node.locked_for.append(cell)
	manager.apply_upgrade(type, cell)
	label_tokens.text = "%d" %cell.lvl_tokens

func show_tooltip(type: LevelUpgradeManager.Types) -> void:
	G.tooltip_requested.emit(manager.get_description(type))

func hide_tooltip(type: LevelUpgradeManager.Types) -> void:
	G.tooltip_close_required.emit()

func change_path(path: int) -> void:
	cell.upgrade_path = path
	upgrade_path.hide()
	nodes_to_hide.erase(upgrade_path)
	upgrade_path = get_upgrade_path()
	upgrade_path.show()
	nodes_to_hide.append(upgrade_path)
	
func _on_cell_lvled_up(_cell: PlayerCell, lvl: int) -> void:
	if cell != _cell:
		return
	
	label_lvl.text = "lvl %d" %lvl
	label_tokens.text = "%d" %cell.lvl_tokens
	
func _on_close_button_pressed() -> void:
	G.level_upgrade_menu_close_requested.emit()
	
func _physics_process(delta: float) -> void:
	progress_bar.value = cell.xp
	
func _on_level_upgrade_menu_close_requested() -> void:
	set_physics_process(false)
	cell = null
	hide_paths()
	hide()
	
func hide_paths() -> void:
	for i in nodes_to_hide:
		i.hide()
	
	nodes_to_hide = []

func get_upgrade_path() -> Control:
	return upgrade_path_type.get_node("Path%d" %cell.upgrade_path)
	
func _on_level_upgrade_menu_open_requested(_cell: PlayerCell) -> void:
	if G.upgrade_menu_opened:
		return
	
	if !nodes_to_hide.is_empty():
		hide_paths()
		
	cell = _cell
	var cell_type: PlayerCellData.Types = cell.data.type
	if !upgrade_paths.has(cell_type):
		G.level_upgrade_menu_close_requested.emit()
		return
		
	set_physics_process(true)
	upgrade_path_type = upgrade_paths[cell_type]
	upgrade_path_type.show()
	nodes_to_hide.append(upgrade_path_type)
	upgrade_path = get_upgrade_path()
	upgrade_path.show()
	nodes_to_hide.append(upgrade_path)
	
	global_position = cell.global_position + Vector2(12, 0)
	label_lvl.text = "lvl %d" %cell.lvl
	label_tokens.text = "%d" %cell.lvl_tokens
	show()
