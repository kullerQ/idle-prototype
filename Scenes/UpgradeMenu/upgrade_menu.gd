extends NodePopupMenu
class_name UpgradeMenu

var nodes: Dictionary = {}
var unlocked_node_count: int = 0
@onready var highlight_label: Label = G.upgrades_highlight_label
# TODO: remove G dependency
@onready var economy: Economy = G.economy
@onready var upgrade_manager: UpgradeManager = G.upgrade_manager


func _ready() -> void:
	super()
	_inject_node_deps()
	graphics.clip_contents = true
	for i in range(1, Economy.Currencies.size()):
		block_expensive(i, economy.resources[i])
	
	economy.res_changed.connect(block_expensive)


func _inject_node_deps() -> void:
	for key in nodes:
		for node in nodes[key]:
			node.economy = economy
			node.upgrade_manager = upgrade_manager


# TODO: remove bullshit 💩
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
