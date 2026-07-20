extends TestCase


func test_to_dict_includes_version_and_sections() -> void:
	var state: RunState = RunState.new()
	state.economy_data = {"wood": 10}
	var d: Dictionary = state.to_dict()
	assert_eq(d.get("version"), RunState.SAVE_VERSION)
	assert_true(d.has("economy"))
	assert_true(d.has("upgrades"))
	assert_true(d.has("tower_grid"))


func test_from_dict_roundtrip() -> void:
	var original: RunState = RunState.new()
	original.economy_data = {"wood": 42, "free_cells": 3}
	original.upgrades_data = {"SHOOTER_CRIT": 2}
	original.tower_grid_data = [{"type": 1, "grid_pos": [0, 0], "xp": 0, "level": 1}]
	var restored: RunState = RunState.from_dict(original.to_dict())
	assert_eq(restored.save_version, RunState.SAVE_VERSION)
	assert_eq(restored.economy_data, original.economy_data)
	assert_eq(restored.upgrades_data, original.upgrades_data)
	assert_eq(restored.tower_grid_data, original.tower_grid_data)


func test_from_dict_legacy_without_version() -> void:
	var legacy: Dictionary = {
		"economy": {"wood": 5},
		"upgrades": {},
		"tower_grid": [],
	}
	var state: RunState = RunState.from_dict(legacy)
	assert_eq(state.save_version, 0)
	assert_eq(state.economy_data["wood"], 5)


func test_pending_consume() -> void:
	RunState.clear_pending()
	assert_eq(RunState.consume_pending(), null)

	var state: RunState = RunState.new()
	state.economy_data = {"wood": 1}
	RunState.set_pending(state)
	var consumed: RunState = RunState.consume_pending()
	assert_eq(consumed.economy_data["wood"], 1)
	assert_eq(RunState.consume_pending(), null)
