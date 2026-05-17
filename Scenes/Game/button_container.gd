extends HBoxContainer
class_name ButtonContainer

var button_scene: PackedScene = load("uid://tb22m3814na3")

func _enter_tree() -> void:
	PanelButton.container = self

func upgrade_menu_button_func() -> void:
	if !G.upgrade_menu_opened:
		G.upgrade_menu_open_requested.emit()
		return
		
	G.upgrade_menu_close_requested.emit()

func wood_func() -> void:
	G.economy.add_resource(Economy.Currencies.WOOD, 1000)

func xp_func() -> void:
	G.economy.add_resource(Economy.Currencies.XP, 100)

func zero_func() -> void:
	G.economy.set_resource(Economy.Currencies.WOOD, 0)
	G.economy.set_resource(Economy.Currencies.XP, 0)

func lvl_up_func() -> void:
	if G.upgrade_menu_opened:
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

func _ready() -> void:
	var b: PanelButton = button_scene.instantiate()
	
	var lvl_up_button: PanelButton = b.duplicate()
	lvl_up_button.initialize("level up", lvl_up_func, 32)
	add_child(lvl_up_button)
	
	var upgrade_menu_button: PanelButton = b.duplicate()
	upgrade_menu_button.initialize("upgrades", upgrade_menu_button_func, 32)
	add_child(upgrade_menu_button)
	var wood_button: PanelButton = b.duplicate()
	wood_button.initialize("w+1000", wood_func)
	add_child(wood_button)
	var xp_button: PanelButton = b.duplicate()
	xp_button.initialize("xp+100", xp_func)
	add_child(xp_button)
	var zero: PanelButton = b.duplicate()
	zero.initialize("0", zero_func, 12)
	add_child(zero)
	G.lvl_upgrades_highlight_label = G.ui.add_label(lvl_up_button, Vector2.ZERO, "")
	G.upgrades_highlight_label = G.ui.add_label(upgrade_menu_button, Vector2.ZERO, "")
	await get_tree().process_frame
	G.lvl_upgrades_highlight_label.global_position = lvl_up_button.global_position - Vector2(14, 10)
	G.upgrades_highlight_label.global_position = upgrade_menu_button.global_position - Vector2(14, 10)
