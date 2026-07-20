extends Control
class_name UI

## Top-level HUD (currencies). Menu open/close API stays on G; listeners live here,
## on UIPP, Tooltip, and NodePopupMenu subclasses — not in gameplay managers.

enum Menus {
	NULL,
	UPGRADE,
	EXPEDITION,
	EXPEDITION_END,
}

var si_suffex: Array = ["", "K", "M", "B"]
var economy: Economy
var upgrade_manager: UpgradeManager
@onready var label_xp: Label = $HBoxContainer/LabelXP
@onready var label_wood: Label = $HBoxContainer/LabelWood


func _enter_tree() -> void:
	G.ui = self
	# Shell wiring: Game.bind_scene_managers runs before this node enters (SubViewport is first).
	economy = G.economy
	upgrade_manager = G.upgrade_manager


func _ready() -> void:
	economy.res_changed.connect(_on_resource_changed)


func register_upgrade_menu(menu: UpgradeMenu) -> void:
	menu.setup(economy, upgrade_manager)


func add_label(control: Control, pos: Vector2, text: String) -> Label:
	var container: Control = Control.new()
	container.size = control.size
	container.global_position = pos
	var label: Label = Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.set("theme_override_font_sizes/font_size", 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = text
	
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(container)
	container.add_child(label)
	return label


func format_number(number: float) -> String:
	if number < 1000:
		return str(number)
	
	var exp: int = floor(log(number) / log(1000))
	var v: float = number / pow(1000, exp)
	var suffex: String = si_suffex[exp] if exp < si_suffex.size() else "e%d" %(exp * 3)
	return "%0.2f%s" %[v, suffex]


func _on_resource_changed(type: Economy.Currencies, value: int) -> void:
	match type:
		Economy.Currencies.WOOD:
			label_wood.text = "w %s" %format_number(value)
		Economy.Currencies.XP:
			label_xp.text = "xp %s" %format_number(value)
