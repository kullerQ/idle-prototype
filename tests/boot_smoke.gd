class_name BootSmoke
extends RefCounted
## Instantiates Main and asserts composition-root wiring after a few frames.


const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")

var failures: int = 0


func run_on_tree(tree: SceneTree) -> int:
	failures = 0
	var main: Node = MAIN_SCENE.instantiate()
	tree.root.add_child(main)

	for _i in 3:
		await tree.process_frame

	_assert_manager(G.economy != null, "G.economy")
	_assert_manager(G.damage_manager != null, "G.damage_manager")
	_assert_manager(G.projectile_manager != null, "G.projectile_manager")
	_assert_manager(G.cell_manager != null, "G.cell_manager")
	_assert_manager(G.player_cell_manager != null, "G.player_cell_manager")
	_assert_manager(G.timer_manager != null, "G.timer_manager")
	_assert_manager(G.building_manager != null, "G.building_manager")
	_assert_manager(G.upgrade_manager != null, "G.upgrade_manager")
	_assert_manager(G.upgrade_manager.applier != null, "UpgradeManager.applier")
	_assert_manager(G.level_upgrade_manager != null, "G.level_upgrade_manager")
	_assert_manager(G.expedition_manager != null, "G.expedition_manager")
	_assert_manager(G.ui != null, "G.ui")
	_assert_manager(G.cell_manager.economy != null, "CellManager.economy")
	_assert_manager(G.player_cell_manager.damage_manager != null, "PlayerCellManager.damage_manager")

	main.queue_free()
	return failures


func _assert_manager(condition: bool, label: String) -> void:
	if condition:
		return

	failures += 1
	push_error("BootSmoke: %s is null after Main boot" % label)
