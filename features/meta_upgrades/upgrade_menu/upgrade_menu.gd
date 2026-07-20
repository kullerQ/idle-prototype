extends NodePopupMenu
class_name UpgradeMenu

var nodes: Dictionary = {}
var unlocked_node_count: int = 0
## Injected by ButtonContainer (owns the label).
var highlight_label: Label
# TODO: remove G dependency (Phase 6)
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

	if !highlight_label:
		return

	if unlocked > 0:
		highlight_label.text = str(unlocked)
	else:
		highlight_label.text = ""


func reg_node(key: Array, node: UpgradeNode) -> void:
	if !nodes.has(key):
		nodes[key] = []

	nodes[key].append(node)


func sync_levels_from(manager: UpgradeManager) -> void:
	var nodes_by_type: Dictionary = {}
	for node in find_children("*", "UpgradeNode", true, false):
		var upgrade_node: UpgradeNode = node as UpgradeNode
		if upgrade_node.type == UpgradeManager.Types.NULL:
			continue
		if !nodes_by_type.has(upgrade_node.type):
			nodes_by_type[upgrade_node.type] = []
		nodes_by_type[upgrade_node.type].append(upgrade_node)

	for type in nodes_by_type:
		var saved_lvl: int = manager.get_level(type)
		var type_nodes: Array = nodes_by_type[type]

		if type_nodes.size() == 1:
			var upgrade_node: UpgradeNode = type_nodes[0]
			if saved_lvl > 0:
				upgrade_node.unlock()
			upgrade_node.set_lvl(saved_lvl)
			continue

		var remaining: int = saved_lvl
		for upgrade_node in type_nodes:
			var node_lvl: int = mini(upgrade_node.max_lvl, remaining)
			if node_lvl > 0:
				upgrade_node.unlock()
			upgrade_node.set_lvl(node_lvl)
			remaining -= node_lvl

	for i in range(1, Economy.Currencies.size()):
		block_expensive(i, economy.resources[i])
