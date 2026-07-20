extends TestCase


func test_can_afford_single_currency() -> void:
	var economy: Economy = Economy.new()
	economy.set_resource(Economy.Currencies.WOOD, 50)

	var node: UpgradeNode = UpgradeNode.new()
	node.cost = {Economy.Currencies.WOOD: PackedInt64Array([10])}

	assert_true(node.can_afford(economy))

	economy.set_resource(Economy.Currencies.WOOD, 5)
	assert_true(!node.can_afford(economy))


func test_can_afford_multi_currency() -> void:
	var economy: Economy = Economy.new()
	economy.set_resource(Economy.Currencies.WOOD, 100)
	economy.set_resource(Economy.Currencies.FREE_CELLS, 2)

	var node: UpgradeNode = UpgradeNode.new()
	node.cost = {
		Economy.Currencies.WOOD: PackedInt64Array([50]),
		Economy.Currencies.FREE_CELLS: PackedInt64Array([3]),
	}

	assert_true(!node.can_afford(economy))

	economy.set_resource(Economy.Currencies.FREE_CELLS, 3)
	assert_true(node.can_afford(economy))


func test_evaluate_blocks_and_counts_unlocked() -> void:
	var economy: Economy = Economy.new()
	economy.set_resource(Economy.Currencies.WOOD, 20)

	var affordable: UpgradeNode = UpgradeNode.new()
	affordable.cost = {Economy.Currencies.WOOD: PackedInt64Array([10])}
	affordable.locked = false

	var expensive: UpgradeNode = UpgradeNode.new()
	expensive.cost = {Economy.Currencies.WOOD: PackedInt64Array([100])}
	expensive.locked = false

	var maxed: UpgradeNode = UpgradeNode.new()
	maxed.cost = {Economy.Currencies.WOOD: PackedInt64Array([5])}
	maxed.max_lvl = 1
	maxed.lvl = 1
	maxed.locked = false

	var key: Array = [Economy.Currencies.WOOD]
	var nodes: Dictionary = {key: [affordable, expensive, maxed]}

	var result: Dictionary = UpgradeAffordability.evaluate(
		nodes, economy, Economy.Currencies.WOOD
	)

	assert_eq(result["unlocked_count"], 1)
	assert_eq(result["unblocked"].size(), 1)
	assert_eq(result["unblocked"][0], affordable)
	assert_eq(result["blocked"].size(), 1)
	assert_eq(result["blocked"][0], expensive)
