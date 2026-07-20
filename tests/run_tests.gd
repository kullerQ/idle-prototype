extends SceneTree
## Headless test runner. Run: godot --headless -s res://tests/run_tests.gd
## Exit code 0 = all passed, 1 = failures.


func _init() -> void:
	var runner: Node = load("res://tests/test_runner.gd").new()
	root.add_child(runner)
