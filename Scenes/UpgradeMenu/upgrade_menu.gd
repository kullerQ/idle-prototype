extends Control
class_name UpgradeMenu

@onready var control = $Control
@onready var graphics = $Control/Graphics
var nodes: Dictionary = {}
var unlocked_node_count: int = 0
var tw: Tween
@onready var highlight_label: Label = G.upgrades_highlight_label
@onready var economy: Economy = G.economy

func _ready() -> void:
	control.clip_contents = true
	G.upgrade_menu_open_requested.connect(_on_open_requested)
	G.upgrade_menu_close_requested.connect(_on_close_requested)
	hide()
	for i in range(1, Economy.Currencies.size()):
		block_expensive(i, economy.resources[i])
	
	economy.res_changed.connect(block_expensive)
	
func _on_open_requested() -> void:
	G.upgrade_menu_opened = true
	G.level_upgrade_menu_close_requested.emit()
	show()
	if tw:
		tw.kill()
		
	tw = create_tween()
	control.modulate.a = 0
	control.position.y = 4
	tw.set_parallel()
	tw.tween_property(control, "position:y", 0, 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_property(control, "modulate:a", 1, 0.19).set_ease(Tween.EASE_OUT)
	
func block_expensive(currency: Economy.Currencies, value: int) -> void:
	# bullshit 💩
	var unlocked: int = 0
	for k in nodes:
		if !k.has(currency):
			continue
			
		for node in nodes[k]:
			if node.lvl == node.max_lvl || node.locked:
				continue

			if k.size() > 1:
				var success: bool = true
				for i in k:
					if economy.get_resource(i) < node.get_cost(i):
						node.block()
						success = false
						break
				
				if !success:
					continue
				
			else:
				if value < node.get_cost(currency):
					node.block()
					continue

			
			node.unblock()
			unlocked += 1
		
	if unlocked > 0:
		highlight_label.text = str(unlocked)
	else:
		highlight_label.text = ""
		
			
func reg_node(key: Array, node: UpgradeNode) -> void:
	if !nodes.has(key):
		nodes[key] = []
	
	nodes[key].append(node)

func _on_close_requested() -> void:
	G.upgrade_menu_opened = false
	if tw:
		tw.kill()
		
	tw = create_tween()
	control.position.y = 0
	tw.set_parallel()
	tw.tween_property(control, "position:y", 4, 0.19).set_ease(Tween.EASE_OUT)
	tw.tween_property(control, "modulate:a", 0, 0.14).set_ease(Tween.EASE_OUT)
	await tw.finished
	hide()
