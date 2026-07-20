class_name SaveService

const SAVE_PATH: String = "user://save.json"


static func save_to_file(data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveService: failed to open %s for writing (error %d)" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))
	file.close()


static func load_from_file() -> Dictionary:
	if !FileAccess.file_exists(SAVE_PATH):
		return {}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveService: failed to open %s for reading (error %d)" % [SAVE_PATH, FileAccess.get_open_error()])
		return {}

	var json: JSON = JSON.new()
	var error: Error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		push_error("SaveService: JSON parse error: %s" % json.get_error_message())
		return {}

	var parsed = json.data
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveService: expected Dictionary in save file")
		return {}

	return parsed
