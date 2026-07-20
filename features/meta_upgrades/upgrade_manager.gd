class_name UpgradeManager

enum Types {
	NULL,
	ADD_TOWER_CELL,
	SHOOTER,
	SHOOTER_COOLDOWN,
	SHOOTER_ACCURACY,
	SHOOTER_CRIT,
	SHOOTER_CRIT_MULT,
	BULLET_DMG,
	BULLET_DIST,
	BULLET_SPD,
	UNLOCK_LUMBERJACK,
	ADD_LUMBERJACK,
	LUMBERJACK_AUTOMATION,
	LUMBERJACK_CD,
	LUMBERJACK_WOOD,
	LUMBERJACK_CRIT,
	LUMBERJACK_DMG,
	LUMBERJACK_CHARGE,
	WOOD_SPAWNRATE,
	TREE_LIFETIME,
	TREE_DURABILITY,
	GROVE_ADD,
	GROVE_SPAWN,
	GROVE_VALUE,
	SHOOTER_XP,
	AXE_BOUNCE,
	AXE_SPD,
	DRUID,
	DRUID_COOLDOWN,
	DRUID_CRIT,
	DRUID_CRIT_MULT,
	DRUID_MAGIC_DMG,
	DRUID_MAGIC_SPD,
	DRUID_XP,
	LUMBERJACK_WOOD_SPAWN,
	ROGUE,
	ROGUE_COOLDOWN,
	ROGUE_CRIT,
	ROGUE_CRIT_MULT,
	ROGUE_XP,
	KNIFE_DMG,
	KNIFE_SPD,
	KNIFE_PIERCING,
	EXECUTIONER,
	EXECUTIONER_COOLDOWN,
	EXECUTIONER_CRIT,
	EXECUTIONER_CRIT_MULT,
	EXECUTIONER_XP,
	GREATAXE_DMG,
	GREATAXE_BACKSTAB,
	GREATAXE_BACKSTAB_DMG,
	GREATAXE_SPD,
	GREATAXE_PIERCING,
	KNIFE_RANGE,
	GREATAXE_RANGE,
	UNLOCK_OUTPOST,
	OUTPOST_WEAKENING_CHANCE,
	OUTPOST_MULTIATTACKS,
	GROVE_BUFFED,
	FOREST_ADD,
	}

const _META_DEFINITIONS_DIR: String = "res://data/upgrades/meta/"

const _SPECIAL_SPAWN_TIMER_TYPES: Array = [
	Types.UNLOCK_LUMBERJACK,
	Types.UNLOCK_OUTPOST,
]

var cell_manager : CellManager
var damage_manager: DamageManager
var player_cell_manager : PlayerCellManager
var timer_manager: TimerManager
var projectile_manager: ProjectileManager
var building_manager: BuildingManager

var applier: UpgradeApplier
var _definitions: Dictionary = {} # Types -> UpgradeDefinition
var _levels: Dictionary = {} # Types -> int

signal upgrade_purchased(type: Types)


func _init():
	upgrade_purchased.connect(_on_upgrade_purchased)


## Call after manager refs are assigned (from G._wire_upgrades).
func setup() -> void:
	applier = UpgradeApplier.new()
	applier.cell_manager = cell_manager
	applier.timer_manager = timer_manager
	applier.player_cell_manager = player_cell_manager
	applier.building_manager = building_manager
	applier.projectile_manager = projectile_manager
	applier.damage_manager = damage_manager
	_register_definitions_from_dir(_META_DEFINITIONS_DIR)


func _register_definitions_from_dir(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("UpgradeManager: failed to open %s" % dir_path)
		return
	for file_name in dir.get_files():
		if !file_name.ends_with(".tres"):
			continue
		var path := dir_path.path_join(file_name)
		var def: UpgradeDefinition = load(path) as UpgradeDefinition
		if def == null:
			push_error("UpgradeManager: failed to load definition %s" % path)
			continue
		_definitions[def.id] = def


func get_description(type: Types) -> String:
	if _definitions.has(type):
		return (_definitions[type] as UpgradeDefinition).description
	push_error("UpgradeManager: no description for type %s" % type)
	return "no description"


func get_level(type: Types) -> int:
	return _levels.get(type, 0)


func to_save_dict() -> Dictionary:
	var result: Dictionary = {}
	for type in _levels:
		var level: int = _levels[type]
		if level <= 0:
			continue
		result[Types.keys()[type]] = level
	return result


func load_from_dict(d: Dictionary) -> void:
	_reset_modifier_baseline()
	_levels.clear()
	for key in d:
		if !Types.has(key):
			push_warning("UpgradeManager: unknown upgrade id '%s' in save data" % key)
			continue
		var type: Types = Types[key]
		var level: int = int(d[key])
		if level <= 0:
			continue
		if !_definitions.has(type):
			push_error("UpgradeManager: no UpgradeDefinition for type %s" % type)
			continue
		_levels[type] = level
		applier.apply(_definitions[type], level, true)
	_restore_special_spawn_timers()


func _restore_special_spawn_timers() -> void:
	for type in _SPECIAL_SPAWN_TIMER_TYPES:
		if get_level(type) <= 0 || !_definitions.has(type):
			continue
		applier.apply_special_spawn_timers(_definitions[type])


func _reset_modifier_baseline() -> void:
	timer_manager.reset_upgrade_timers()
	player_cell_manager.reset_upgrade_data()
	cell_manager.reset_upgrade_data()
	projectile_manager.reset_upgrade_data()
	damage_manager.reset_upgrade_modifiers()
	building_manager.reset_upgrade_data()


func _on_upgrade_purchased(type: Types) -> void:
	_levels[type] = get_level(type) + 1
	if _definitions.has(type):
		applier.apply(_definitions[type])
		return
	push_error("UpgradeManager: no UpgradeDefinition for type %s" % type)
