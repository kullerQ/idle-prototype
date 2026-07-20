extends HBoxContainer
class_name ButtonContainer

## Owns highlight badges for upgrade / level-up buttons (not G).

var button_scene: PackedScene = preload("res://ui/shared/panel_button/panel_button.tscn")
var upgrades_highlight_label: Label
var lvl_upgrades_highlight_label: Label

var ui: UI
var economy: Economy
var player_cell_manager: PlayerCellManager
var upgrade_menu: UpgradeMenu
var lvl_up_button: PanelButton
var upgrade_menu_button: PanelButton


func setup(
	p_ui: UI,
	p_economy: Economy,
	p_player_cell_manager: PlayerCellManager,
	p_upgrade_menu: UpgradeMenu,
) -> void:
	ui = p_ui
	economy = p_economy
	player_cell_manager = p_player_cell_manager
	upgrade_menu = p_upgrade_menu
	_wire_highlight_labels()


func upgrade_menu_button_func() -> void:
	G.toggle_menu(UI.Menus.UPGRADE)


func expedition_func() -> void:
	G.toggle_menu(UI.Menus.EXPEDITION)


func wood_func() -> void:
	economy.add_resource(Economy.Currencies.WOOD, 1000)


func xp_func() -> void:
	economy.add_resource(Economy.Currencies.XP, 100)


func zero_func() -> void:
	economy.set_resource(Economy.Currencies.WOOD, 0)
	economy.set_resource(Economy.Currencies.XP, 0)


func lvl_up_func() -> void:
	if G.opened_menu_type:
		return

	var cell: PlayerCell = player_cell_manager.get_cell_to_upgrade()
	if !cell:
		return

	if player_cell_manager.highlighted_cell:
		player_cell_manager.highlighted_cell.set_highlight(false)

	cell.set_highlight(true)
	player_cell_manager.highlighted_cell = cell
	G.level_upgrade_menu_open_requested.emit(cell)


func _make_button(text: String, pressed_func: Callable, xsize: int = 25) -> PanelButton:
	var button: PanelButton = button_scene.instantiate()
	button.setup(self)
	button.initialize(text, pressed_func, xsize)
	add_child(button)
	return button


func _ready() -> void:
	_make_button("expedition", expedition_func, 33)
	lvl_up_button = _make_button("level up", lvl_up_func, 32)
	upgrade_menu_button = _make_button("upgrades", upgrade_menu_button_func, 32)
	_make_button("w+1000", wood_func)
	_make_button("xp+100", xp_func)
	_make_button("0", zero_func, 12)


func _wire_highlight_labels() -> void:
	lvl_upgrades_highlight_label = ui.add_label(lvl_up_button, Vector2.ZERO, "")
	upgrades_highlight_label = ui.add_label(upgrade_menu_button, Vector2.ZERO, "")

	player_cell_manager.lvl_upgrades_highlight_label = lvl_upgrades_highlight_label
	upgrade_menu.highlight_label = upgrades_highlight_label

	call_deferred("_position_highlight_labels")


func _position_highlight_labels() -> void:
	lvl_upgrades_highlight_label.global_position = lvl_up_button.global_position - Vector2(14, 10)
	upgrades_highlight_label.global_position = upgrade_menu_button.global_position - Vector2(14, 10)
