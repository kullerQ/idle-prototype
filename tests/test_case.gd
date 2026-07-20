class_name TestCase
extends RefCounted
## Minimal test helper for headless runs (no GUT). Subclass and add test_* methods.


var failures: int = 0


func run() -> int:
	failures = 0
	for method_info in get_method_list():
		var method_name: String = method_info.name
		if !method_name.begins_with("test_"):
			continue

		call(method_name)

	return failures


func assert_true(condition: bool, message: String = "") -> void:
	if condition:
		return

	failures += 1
	var prefix: String = "%s: " % get_script().resource_path.get_file() if get_script() else ""
	push_error("%s%s" % [prefix, message if message else "assert_true failed"])


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual == expected:
		return

	failures += 1
	var prefix: String = "%s: " % get_script().resource_path.get_file() if get_script() else ""
	var detail: String = message if message else "expected %s, got %s" % [expected, actual]
	push_error("%s%s" % [prefix, detail])
