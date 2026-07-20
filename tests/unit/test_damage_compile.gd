extends TestCase


func test_hit_damage_base_only() -> void:
	var hit: Dictionary = DamageManager.new_data(10)
	var damage_data: Dictionary = {
		DamageManager.DamageDataTypes.BASE: DamageManager.new_damage_data({}, hit),
		DamageManager.DamageDataTypes.MULT: 1.0,
	}
	var compiled: Array = DamageManager.compile_damage(damage_data)

	assert_eq(compiled.size(), 1)
	assert_eq(compiled[0].type, DamageManager.Types.HIT)
	assert_eq(compiled[0].stat, DamageManager.Stats.HP)
	assert_eq(compiled[0].damage_value, 10)


func test_hit_damage_bonus_and_mult() -> void:
	var base_hit: Dictionary = DamageManager.new_data(10)
	var bonus_hit: Dictionary = DamageManager.new_data(5)
	var damage_data: Dictionary = {
		DamageManager.DamageDataTypes.BASE: DamageManager.new_damage_data({}, base_hit),
		DamageManager.DamageDataTypes.BONUS: DamageManager.new_damage_data({}, bonus_hit),
		DamageManager.DamageDataTypes.MULT: 2.0,
	}
	var compiled: Array = DamageManager.compile_damage(damage_data)

	assert_eq(compiled.size(), 1)
	assert_eq(compiled[0].damage_value, 30)


func test_zero_damage_omitted() -> void:
	var damage_data: Dictionary = {
		DamageManager.DamageDataTypes.BASE: DamageManager.new_damage_data({}, DamageManager.new_data(0)),
		DamageManager.DamageDataTypes.MULT: 1.0,
	}
	var compiled: Array = DamageManager.compile_damage(damage_data)

	assert_eq(compiled.size(), 0)


func test_life_time_stat() -> void:
	var hit: Dictionary = DamageManager.new_data(0, 3)
	var damage_data: Dictionary = {
		DamageManager.DamageDataTypes.BASE: DamageManager.new_damage_data({}, hit),
		DamageManager.DamageDataTypes.MULT: 1.0,
	}
	var compiled: Array = DamageManager.compile_damage(damage_data)

	assert_eq(compiled.size(), 1)
	assert_eq(compiled[0].stat, DamageManager.Stats.LIFE_TIME)
	assert_eq(compiled[0].damage_value, 3)
