extends Node


func _ready() -> void:
	var failures: int = 0

	for script in _UNIT_TESTS:
		var test: TestCase = script.new()
		var test_failures: int = test.run()
		if test_failures:
			print("[FAIL] %s (%d)" % [script.resource_path, test_failures])
			failures += test_failures
		else:
			print("[PASS] %s" % script.resource_path)

	var boot: BootSmoke = BootSmoke.new()
	failures += await boot.run_on_tree(get_tree())
	if boot.failures:
		print("[FAIL] boot_smoke (%d)" % boot.failures)
	else:
		print("[PASS] boot_smoke")

	if failures:
		print("Tests finished: %d failure(s)" % failures)
	else:
		print("Tests finished: all passed")

	get_tree().quit(1 if failures else 0)


const _UNIT_TESTS: Array = [
	preload("res://tests/unit/test_damage_compile.gd"),
	preload("res://tests/unit/test_spawn_roll.gd"),
	preload("res://tests/unit/test_upgrade_effect.gd"),
	preload("res://tests/unit/test_level_upgrade_effect.gd"),
	preload("res://tests/unit/test_run_state.gd"),
	preload("res://tests/unit/test_load_bugs.gd"),
]
