class_name CellSpawnRoll
## Pure helpers for weighted cell spawn rolls. Used by CellManager.get_rand_name.


## Pick a weighted cell name from a tier table.
## Table shape matches CellManager.tiers[type]: key 0 = total weight; other keys = cell name
## with { "weight": int, "tier": int }.
static func pick_weighted(table: Dictionary, roll: int) -> int:
	for key in table:
		if key == 0:
			continue

		var value: int = table[key].weight
		if roll < value:
			return key

		roll -= value

	push_error(
		"CellSpawnRoll.pick_weighted: roll %d out of range (total %d)" % [roll, table.get(0, 0)]
	)
	return 0
