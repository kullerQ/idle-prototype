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
	G.economy.add_resource(Economy.Currencies.WOOD, 10)

func _ready() -> void:
	var b: PanelButton = button_scene.instantiate()
	var upgrade_menu_button: PanelButton = b.duplicate()
	upgrade_menu_button.initialize("upgrades", upgrade_menu_button_func, 32)
	add_child(upgrade_menu_button)
	var wood_button: PanelButton = b.duplicate()
	wood_button.initialize("+10", wood_func)
	add_child(wood_button)
