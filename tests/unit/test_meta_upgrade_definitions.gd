extends TestCase


func test_all_live_meta_upgrade_types_have_definitions() -> void:
	var manager := UpgradeManager.new()
	manager.setup()

	for type_name in UpgradeManager.Types.keys():
		if type_name == "NULL":
			continue
		var type: int = UpgradeManager.Types[type_name]
		assert_true(
			manager.get_description(type) != "no description",
			"missing definition for %s" % type_name
		)
