extends TestCase


func _sample_table() -> Dictionary:
	return {
		0: 100,
		1: {"weight": 60, "tier": 1},
		2: {"weight": 40, "tier": 2},
	}


func test_roll_picks_first_bucket() -> void:
	assert_eq(CellSpawnRoll.pick_weighted(_sample_table(), 0), 1)
	assert_eq(CellSpawnRoll.pick_weighted(_sample_table(), 59), 1)


func test_roll_picks_second_bucket() -> void:
	assert_eq(CellSpawnRoll.pick_weighted(_sample_table(), 60), 2)
	assert_eq(CellSpawnRoll.pick_weighted(_sample_table(), 99), 2)


func test_single_entry_table() -> void:
	var table: Dictionary = {
		0: 25,
		5: {"weight": 25, "tier": 1},
	}
	assert_eq(CellSpawnRoll.pick_weighted(table, 0), 5)
	assert_eq(CellSpawnRoll.pick_weighted(table, 24), 5)
