extends TestCase


func test_has_save_and_delete() -> void:
	var had_save: bool = SaveService.has_save()
	var backup: Dictionary = SaveService.load_from_file() if had_save else {}

	SaveService.delete_save()
	assert_true(!SaveService.has_save())

	SaveService.save_to_file({"version": 1})
	assert_true(SaveService.has_save())

	var loaded: Dictionary = SaveService.load_from_file()
	assert_eq(loaded.get("version"), 1)

	if had_save:
		SaveService.save_to_file(backup)
	else:
		SaveService.delete_save()
