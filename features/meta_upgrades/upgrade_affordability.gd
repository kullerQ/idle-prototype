class_name UpgradeAffordability


static func evaluate(
	nodes: Dictionary,
	economy: Economy,
	changed_currency: Economy.Currencies
) -> Dictionary:
	var unlocked_count: int = 0
	var blocked: Array[UpgradeNode] = []
	var unblocked: Array[UpgradeNode] = []

	for key in nodes:
		if !key.has(changed_currency):
			continue

		for node in nodes[key]:
			if node.lvl == node.max_lvl || node.locked:
				continue

			if node.can_afford(economy):
				unblocked.append(node)
				unlocked_count += 1
			else:
				blocked.append(node)

	return {
		"blocked": blocked,
		"unblocked": unblocked,
		"unlocked_count": unlocked_count,
	}
