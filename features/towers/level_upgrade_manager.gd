class_name LevelUpgradeManager

enum Types {
	NULL,
	SHOOTER_SUPPORT,
	SHOOTER_DPS,
	SHOOTER_WEAK_RIC,
	SHOOTER_WEAK,
	SHOOTER_AUTO_WEAK,
	SHOOTER_DPS_CD_RESET_WEAK,
	SHOOTER_DPS_BULLET_SPD,
	DRUID_AUTOAIM,
	DRUID_SPREAD,
	SHOOTER_DPS_RICOCHET,
	SHOOTER_DPS_DMG,
	DRUID_OVERHEAL_SPAWN_WEAK,
	DRUID_SPAWN_WOOD_RIGHT,
	DRUID_OVERHEAL_LVLUP,
	ROGUE_CRIT_WEAK,
	DRUID_ADD_RES_ON_ATTACK,
	DRUID_MULTIATTACK,
	DRUID_CD_FOR_HEALED,
	DRUID_OBELISK_CHANCE,
}

const _LEVEL_DEFINITIONS_DIR: String = "res://data/upgrades/level/"

## Remap pre-3a enum ints (dead slots 12–16 removed) for existing saves.
const _REMOVED_DEAD_TYPE_COUNT: int = 5
const _LEGACY_FIRST_DEAD_SLOT: int = 12
const _LEGACY_FIRST_TYPE_AFTER_DEAD_SLOTS: int = 17

var player_cell_manager: PlayerCellManager
var applier: LevelUpgradeApplier
var _definitions: Dictionary = {}


static func remap_legacy_type(saved_type: int) -> int:
	if saved_type >= _LEGACY_FIRST_TYPE_AFTER_DEAD_SLOTS:
		return saved_type - _REMOVED_DEAD_TYPE_COUNT
	if saved_type >= _LEGACY_FIRST_DEAD_SLOT && saved_type < _LEGACY_FIRST_TYPE_AFTER_DEAD_SLOTS:
		return Types.NULL
	return saved_type


func setup() -> void:
	applier = LevelUpgradeApplier.new()
	_register_definitions_from_dir(_LEVEL_DEFINITIONS_DIR)


func _register_definitions_from_dir(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("LevelUpgradeManager: failed to open %s" % dir_path)
		return
	for file_name in dir.get_files():
		if !file_name.ends_with(".tres"):
			continue
		var path := dir_path.path_join(file_name)
		var def: UpgradeDefinition = load(path) as UpgradeDefinition
		if def == null:
			push_error("LevelUpgradeManager: failed to load definition %s" % path)
			continue
		_definitions[def.id] = def


func apply_upgrade(type: Types, cell: PlayerCell) -> void:
	apply_for_load(type, cell)
	player_cell_manager.cell_upgraded.emit(cell)


func apply_for_load(type: Types, cell: PlayerCell) -> void:
	if type == Types.NULL:
		return
	if !_definitions.has(type):
		push_error("LevelUpgradeManager: no UpgradeDefinition for type %s" % type)
		return
	applier.apply(_definitions[type], cell)


## Re-applies saved level upgrades after reset_level_modifiers (load path).
## Saved ints are current enum values; pre-3a saves may use legacy ints remapped here.
func restore_saved_upgrades(cell: PlayerCell, saved_upgrades: Array) -> void:
	for upgrade_type in saved_upgrades:
		var remapped_type: int = remap_legacy_type(int(upgrade_type))
		if remapped_type == Types.NULL:
			continue
		var type: Types = remapped_type as Types
		apply_for_load(type, cell)
		cell.applied_level_upgrades.append(type)


func get_description(type: Types) -> String:
	if type == Types.NULL:
		return "no description"
	if _definitions.has(type):
		return (_definitions[type] as UpgradeDefinition).description
	push_error("LevelUpgradeManager: no description for type %s" % type)
	return "no description"
