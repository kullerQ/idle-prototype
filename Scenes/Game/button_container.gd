extends HBoxContainer
class_name ButtonContainer

## Owns highlight badges for upgrade / level-up buttons (not G).

var button_scene: PackedScene = preload("res://Scenes/ButtonPanel/panel_button.tscn")
var upgrades_highlight_label: Label
var lvl_upgrades_highlight_label: Label


func upgrade_menu_button_func() -> void:
	G.toggle_menu(UI.Menus.UPGRADE)


func expedition_func() -> void:
	G.toggle_menu(UI.Menus.EXPEDITION)


func wood_func() -> void:
	G.economy.add_resource(Economy.Currencies.WOOD, 1000)


func xp_func() -> void:
	G.economy.add_resource(Economy.Currencies.XP, 100)


func zero_func() -> void:
	G.economy.set_resource(Economy.Currencies.WOOD, 0)
	G.economy.set_resource(Economy.Currencies.XP, 0)


func lvl_up_func() -> void:
	if G.opened_menu_type:
		return

	var player_cell_manager: PlayerCellManager = G.player_cell_manager
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
	var lvl_up_button: PanelButton = _make_button("level up", lvl_up_func, 32)
	var upgrade_menu_button: PanelButton = _make_button("upgrades", upgrade_menu_button_func, 32)
	_make_button("w+1000", wood_func)
	_make_button("xp+100", xp_func)
	_make_button("0", zero_func, 12)

	lvl_upgrades_highlight_label = G.ui.add_label(lvl_up_button, Vector2.ZERO, "")
	upgrades_highlight_label = G.ui.add_label(upgrade_menu_button, Vector2.ZERO, "")

	var player_cell_manager: PlayerCellManager = get_parent().get_node("PlayerCellManager")
	player_cell_manager.lvl_upgrades_highlight_label = lvl_upgrades_highlight_label

	var upgrade_menu: UpgradeMenu = G.ui.get_node("CanvasLayer/UpgradeMenu")
	upgrade_menu.highlight_label = upgrades_highlight_label

	await get_tree().process_frame
	lvl_upgrades_highlight_label.global_position = lvl_up_button.global_position - Vector2(14, 10)
	upgrades_highlight_label.global_position = upgrade_menu_button.global_position - Vector2(14, 10)
