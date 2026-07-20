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

const _WOOD_DEFINITION_PATHS: PackedStringArray = [
	"res://data/upgrades/meta/upgrade_wood_spawnrate.tres",
	"res://data/upgrades/meta/upgrade_tree_lifetime.tres",
	"res://data/upgrades/meta/upgrade_tree_durability.tres",
	"res://data/upgrades/meta/upgrade_grove_add.tres",
	"res://data/upgrades/meta/upgrade_grove_spawn.tres",
	"res://data/upgrades/meta/upgrade_grove_value.tres",
	"res://data/upgrades/meta/upgrade_grove_buffed.tres",
	"res://data/upgrades/meta/upgrade_forest_add.tres",
]

const _TOWER_DEFINITION_PATHS: PackedStringArray = [
	"res://data/upgrades/meta/upgrade_add_tower_cell.tres",
	"res://data/upgrades/meta/upgrade_shooter.tres",
	"res://data/upgrades/meta/upgrade_shooter_cooldown.tres",
	"res://data/upgrades/meta/upgrade_shooter_accuracy.tres",
	"res://data/upgrades/meta/upgrade_shooter_crit.tres",
	"res://data/upgrades/meta/upgrade_shooter_crit_mult.tres",
	"res://data/upgrades/meta/upgrade_shooter_xp.tres",
	"res://data/upgrades/meta/upgrade_druid.tres",
	"res://data/upgrades/meta/upgrade_druid_cooldown.tres",
	"res://data/upgrades/meta/upgrade_druid_crit.tres",
	"res://data/upgrades/meta/upgrade_druid_crit_mult.tres",
	"res://data/upgrades/meta/upgrade_druid_xp.tres",
	"res://data/upgrades/meta/upgrade_rogue.tres",
	"res://data/upgrades/meta/upgrade_rogue_cooldown.tres",
	"res://data/upgrades/meta/upgrade_rogue_crit.tres",
	"res://data/upgrades/meta/upgrade_rogue_crit_mult.tres",
	"res://data/upgrades/meta/upgrade_rogue_xp.tres",
	"res://data/upgrades/meta/upgrade_executioner.tres",
	"res://data/upgrades/meta/upgrade_executioner_cooldown.tres",
	"res://data/upgrades/meta/upgrade_executioner_crit.tres",
	"res://data/upgrades/meta/upgrade_executioner_crit_mult.tres",
	"res://data/upgrades/meta/upgrade_executioner_xp.tres",
]

const _BUILDING_DEFINITION_PATHS: PackedStringArray = [
	"res://data/upgrades/meta/upgrade_unlock_lumberjack.tres",
	"res://data/upgrades/meta/upgrade_add_lumberjack.tres",
	"res://data/upgrades/meta/upgrade_lumberjack_automation.tres",
	"res://data/upgrades/meta/upgrade_lumberjack_cd.tres",
	"res://data/upgrades/meta/upgrade_lumberjack_wood.tres",
	"res://data/upgrades/meta/upgrade_lumberjack_crit.tres",
	"res://data/upgrades/meta/upgrade_lumberjack_dmg.tres",
	"res://data/upgrades/meta/upgrade_lumberjack_charge.tres",
	"res://data/upgrades/meta/upgrade_lumberjack_wood_spawn.tres",
	"res://data/upgrades/meta/upgrade_unlock_outpost.tres",
	"res://data/upgrades/meta/upgrade_outpost_weakening_chance.tres",
	"res://data/upgrades/meta/upgrade_outpost_multiattacks.tres",
]

const _SPECIAL_SPAWN_TIMER_TYPES: Array = [
	Types.UNLOCK_LUMBERJACK,
	Types.UNLOCK_OUTPOST,
]

const _PROJECTILE_DEFINITION_PATHS: PackedStringArray = [
	"res://data/upgrades/meta/upgrade_bullet_dmg.tres",
	"res://data/upgrades/meta/upgrade_bullet_dist.tres",
	"res://data/upgrades/meta/upgrade_bullet_spd.tres",
	"res://data/upgrades/meta/upgrade_axe_bounce.tres",
	"res://data/upgrades/meta/upgrade_axe_spd.tres",
	"res://data/upgrades/meta/upgrade_druid_magic_dmg.tres",
	"res://data/upgrades/meta/upgrade_druid_magic_spd.tres",
	"res://data/upgrades/meta/upgrade_knife_dmg.tres",
	"res://data/upgrades/meta/upgrade_knife_spd.tres",
	"res://data/upgrades/meta/upgrade_knife_piercing.tres",
	"res://data/upgrades/meta/upgrade_knife_range.tres",
	"res://data/upgrades/meta/upgrade_greataxe_dmg.tres",
	"res://data/upgrades/meta/upgrade_greataxe_backstab.tres",
	"res://data/upgrades/meta/upgrade_greataxe_backstab_dmg.tres",
	"res://data/upgrades/meta/upgrade_greataxe_spd.tres",
	"res://data/upgrades/meta/upgrade_greataxe_piercing.tres",
	"res://data/upgrades/meta/upgrade_greataxe_range.tres",
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
	_register_definitions(_WOOD_DEFINITION_PATHS)
	_register_definitions(_TOWER_DEFINITION_PATHS)
	_register_definitions(_BUILDING_DEFINITION_PATHS)
	_register_definitions(_PROJECTILE_DEFINITION_PATHS)


func _register_definitions(paths: PackedStringArray) -> void:
	for path in paths:
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
