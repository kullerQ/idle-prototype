extends NodePopupMenu
class_name ExpeditionMenu


func _ready() -> void:
	super()
	_inject_button_deps()
	var expedition_manager: ExpeditionManager = G.expedition_manager
	expedition_manager.expedition_selected.connect(_on_expedition_selected)


func _inject_button_deps() -> void:
	var expedition_manager: ExpeditionManager = G.expedition_manager
	for button in find_children("*", "ExpeditionButton", true, false):
		button.manager = expedition_manager


func _on_expedition_selected(_type: ExpeditionManager.Types) -> void:
	G.close_menu(type)
