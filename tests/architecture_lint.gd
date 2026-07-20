extends TestCase
## Guards folder layout and G/static conventions. Run via tests/run_tests.gd.


const FEATURES_DIR: String = "res://features/"
const LEGACY_PATH_MARKERS: Array[String] = ["res://Scripts/", "res://Resources/"]
const G_ALLOWLIST_PATH: String = "res://tests/architecture_g_allowlist.txt"
const STATIC_VAR_ALLOWED_PREFIXES: Array[String] = ["res://core/"]


func test_no_legacy_resource_paths_in_project() -> void:
	var hits: PackedStringArray = _find_legacy_path_references("res://")
	for hit in hits:
		push_error("architecture_lint: legacy path reference: %s" % hit)
		failures += 1
	assert_true(hits.is_empty(), "legacy res://Scripts/ or res://Resources/ paths found")


func test_no_scripts_or_resources_folders() -> void:
	assert_true(!DirAccess.dir_exists_absolute("res://Scripts/"), "Scripts/ folder must not exist")
	assert_true(!DirAccess.dir_exists_absolute("res://Resources/"), "Resources/ folder must not exist")


func test_no_g_in_features_except_allowlist() -> void:
	var allowlist: Dictionary = _load_allowlist()
	var violations: PackedStringArray = _find_g_violations(FEATURES_DIR, allowlist)
	for violation in violations:
		push_error("architecture_lint: G. in features/: %s" % violation)
		failures += 1
	assert_true(violations.is_empty(), "G. references under features/ outside allowlist")


func test_no_static_var_outside_core() -> void:
	var violations: PackedStringArray = _find_static_var_violations("res://")
	for violation in violations:
		push_error("architecture_lint: static var outside core/: %s" % violation)
		failures += 1
	assert_true(violations.is_empty(), "static var found outside allowed prefixes")


func _load_allowlist() -> Dictionary:
	var allowed: Dictionary = {}
	var file := FileAccess.open(G_ALLOWLIST_PATH, FileAccess.READ)
	if file == null:
		push_error("architecture_lint: missing allowlist %s" % G_ALLOWLIST_PATH)
		failures += 1
		return allowed
	while !file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if line.is_empty() || line.begins_with("#"):
			continue
		allowed["res://" + line.replace("\\", "/")] = true
	return allowed


func _find_legacy_path_references(root: String) -> PackedStringArray:
	var hits: PackedStringArray = []
	_scan_files(root, func(path: String) -> void:
		if path.begins_with("res://tests/") || path.begins_with("res://.cursor/"):
			return
		if !path.ends_with(".gd") && !path.ends_with(".tscn") && !path.ends_with(".tres"):
			return
		var text: String = FileAccess.get_file_as_string(path)
		for marker in LEGACY_PATH_MARKERS:
			if marker in text:
				hits.append("%s contains %s" % [path, marker])
	)
	return hits


func _find_g_violations(root: String, allowlist: Dictionary) -> PackedStringArray:
	var violations: PackedStringArray = []
	_scan_files(root, func(path: String) -> void:
		if !path.ends_with(".gd"):
			return
		if allowlist.has(path):
			return
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return
		var line_no: int = 0
		while !file.eof_reached():
			line_no += 1
			var line: String = file.get_line()
			if _line_has_g_reference(line):
				violations.append("%s:%d: %s" % [path, line_no, line.strip_edges()])
	)
	return violations


func _find_static_var_violations(root: String) -> PackedStringArray:
	var violations: PackedStringArray = []
	_scan_files(root, func(path: String) -> void:
		if !path.ends_with(".gd"):
			return
		if path.begins_with("res://tests/"):
			return
		for prefix in STATIC_VAR_ALLOWED_PREFIXES:
			if path.begins_with(prefix):
				return
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return
		var line_no: int = 0
		while !file.eof_reached():
			line_no += 1
			var line: String = file.get_line()
			if _line_has_static_var(line):
				violations.append("%s:%d: %s" % [path, line_no, line.strip_edges()])
	)
	return violations


func _line_has_g_reference(line: String) -> bool:
	var code: String = line.strip_edges()
	if code.is_empty() || code.begins_with("#"):
		return false
	return "G." in code


func _line_has_static_var(line: String) -> bool:
	var code: String = line.strip_edges()
	if code.is_empty() || code.begins_with("#"):
		return false
	return code.contains("static var")


func _scan_files(root: String, visitor: Callable) -> void:
	var dir := DirAccess.open(root)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var entry: String = dir.get_next()
		if entry.is_empty():
			break
		if entry == "." || entry == "..":
			continue
		var path: String = root.path_join(entry)
		if dir.current_is_dir():
			_scan_files(path, visitor)
		else:
			visitor.call(path)
	dir.list_dir_end()
