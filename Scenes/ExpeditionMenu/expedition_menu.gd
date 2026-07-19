extends NodePopupMenu
class_name ExpeditionMenu


func _ready() -> void:
	super()
	_inject_button_deps()


func _inject_button_deps() -> void:
	var expedition_manager: ExpeditionManager = G.expedition_manager
	for button in find_children("*", "ExpeditionButton", true, false):
		button.manager = expedition_manager
