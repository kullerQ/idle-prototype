extends NodePopupMenu
class_name ExpeditionMenu

var manager: ExpeditionManager


func setup(p_manager: ExpeditionManager) -> void:
	manager = p_manager


func _ready() -> void:
	super()
	_inject_button_deps()
	manager.expedition_selected.connect(_on_expedition_selected)


func _inject_button_deps() -> void:
	for button in find_children("*", "ExpeditionButton", true, false):
		button.manager = manager


func _on_expedition_selected(_type: ExpeditionManager.Types) -> void:
	G.close_menu(type)
