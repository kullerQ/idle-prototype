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

var cell_manager : CellManager
var damage_manager: DamageManager
var player_cell_manager : PlayerCellManager
var timer_manager: TimerManager
var projectile_manager: ProjectileManager
var building_manager: BuildingManager

var applier: UpgradeApplier
var _definitions: Dictionary = {} # Types -> UpgradeDefinition

## Legacy descriptions for upgrades not yet migrated to UpgradeDefinition .tres.
var descriptions: Dictionary = {
	Types.NULL: "no description",
	Types.ADD_TOWER_CELL: "+1 additional cell for towers",
	Types.SHOOTER: "+1 shooter",
	Types.SHOOTER_COOLDOWN: "shooter cooldown -0.1s",
	Types.SHOOTER_ACCURACY: "shooter accuracy +1",
	Types.SHOOTER_CRIT: "shooter crit chance +10%",
	Types.SHOOTER_CRIT_MULT: "shooter crit multiplier +1",
	Types.BULLET_DMG: "bullet dmg +1",
	Types.BULLET_DIST: "bullet max distance +10",
	Types.BULLET_SPD: "bullet speed +5",
	Types.UNLOCK_LUMBERJACK: "every 15 seconds lumberjack builds his hut",
	Types.ADD_LUMBERJACK: "lumberjack stays in place for 10 more seconds",
	Types.LUMBERJACK_AUTOMATION: "lumberjack produces wood automatically",
	Types.LUMBERJACK_CD: "lumberjack's cooldown -2",
	Types.LUMBERJACK_WOOD: "lumberjack produces +10 more wood",
	Types.LUMBERJACK_CRIT: "lumberjack crit chance +10",
	Types.LUMBERJACK_DMG: "lumberjack deals 5% more damage from tree's hp",
	Types.LUMBERJACK_CHARGE: "lumberjack charge increase +1",
	Types.SHOOTER_XP: "shooters get +1 xp",
	Types.AXE_BOUNCE: "axe bounces off empty cells",
	Types.AXE_SPD: "axe speed +5",
	Types.DRUID: "+1 druid",
	Types.DRUID_COOLDOWN: "druid cooldown -0.5s",
	Types.DRUID_CRIT: "druid crit chance +5%",
	Types.DRUID_CRIT_MULT: "druid crit mult +1",
	Types.DRUID_MAGIC_DMG: "druid magic dmg +1",
	Types.DRUID_MAGIC_SPD: "druid magic speed +15",
	Types.DRUID_XP: "druid get +1 xp",
	Types.LUMBERJACK_WOOD_SPAWN: "chance to spawn wood cell after lumberjack +25%",
	Types.ROGUE: "+1 rogue",
	Types.ROGUE_COOLDOWN: "rogue cooldown -0.2s",
	Types.ROGUE_CRIT: "rogue crit chance +5%",
	Types.ROGUE_CRIT_MULT: "rogue crit multiplier +1",
	Types.ROGUE_XP: "rogue get +1 xp",
	Types.KNIFE_DMG: "knife damage +1",
	Types.KNIFE_SPD: "knife speed +5",
	Types.KNIFE_RANGE: "knife max range +10",
	Types.KNIFE_PIERCING: "knife piercing +1",
	Types.EXECUTIONER: "executioner +1",
	Types.EXECUTIONER_COOLDOWN: "executioner cooldown -0.5s",
	Types.EXECUTIONER_CRIT: "executioner crit chance +10%",
	Types.EXECUTIONER_CRIT_MULT: "executioner crit multiplier +1",
	Types.EXECUTIONER_XP: "executioner gets +1xp",
	Types.GREATAXE_DMG: "greataxe damage +2",
	Types.GREATAXE_BACKSTAB: "greataxe deals 5 more damage and doesnt break if damages a cell from behind",
	Types.GREATAXE_BACKSTAB_DMG: "greataxe deals +5 more damage from behind",
	Types.GREATAXE_SPD: "greataxe speed +5",
	Types.GREATAXE_PIERCING: "greataxe piercing +1",
	Types.GREATAXE_RANGE: "greataxe max range +1 cell and piercing +1",
	Types.UNLOCK_OUTPOST: "every 20 seconds a shooter outpost appears",
	Types.OUTPOST_WEAKENING_CHANCE: "outpost chance to shoot weakening bullet +20%",
	Types.OUTPOST_MULTIATTACKS: "outpost shoots +1 bullet%",
	}

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
	for path in _WOOD_DEFINITION_PATHS:
		var def: UpgradeDefinition = load(path) as UpgradeDefinition
		if def == null:
			push_error("UpgradeManager: failed to load definition %s" % path)
			continue
		_definitions[def.id] = def


func get_description(type: Types) -> String:
	if _definitions.has(type):
		return (_definitions[type] as UpgradeDefinition).description
	return descriptions[type]


func _on_upgrade_purchased(type: Types) -> void:
	if _definitions.has(type):
		applier.apply(_definitions[type])
		return
	if _apply_tower_upgrade(type):
		return
	if _apply_building_upgrade(type):
		return
	_apply_projectile_upgrade(type)


func _apply_tower_upgrade(type: Types) -> bool:
	match type:
		Types.ADD_TOWER_CELL:
			player_cell_manager.add_free_cell()
		Types.SHOOTER:
			player_cell_manager.add_tower(PlayerCellData.Types.SHOOTER)
		Types.SHOOTER_COOLDOWN:
			player_cell_manager.add_cooldown(PlayerCellData.Types.SHOOTER, -0.1)
		Types.SHOOTER_ACCURACY:
			player_cell_manager.add_accuracy(PlayerCellData.Types.SHOOTER, 1)
		Types.SHOOTER_CRIT:
			player_cell_manager.add_crit_chance(PlayerCellData.Types.SHOOTER, 10)
		Types.SHOOTER_CRIT_MULT:
			player_cell_manager.add_crit_mult(PlayerCellData.Types.SHOOTER, 1)
		Types.SHOOTER_XP:
			player_cell_manager.add_xp_increase(PlayerCellData.Types.SHOOTER, 1)
		Types.DRUID:
			player_cell_manager.add_tower(PlayerCellData.Types.DRUID)
		Types.DRUID_COOLDOWN:
			player_cell_manager.add_cooldown(PlayerCellData.Types.DRUID, -0.1)
		Types.DRUID_CRIT:
			player_cell_manager.add_crit_chance(PlayerCellData.Types.DRUID, 5)
		Types.DRUID_CRIT_MULT:
			player_cell_manager.add_crit_mult(PlayerCellData.Types.DRUID, 1)
		Types.DRUID_XP:
			player_cell_manager.add_xp_increase(PlayerCellData.Types.DRUID, 1)
		Types.ROGUE:
			player_cell_manager.add_tower(PlayerCellData.Types.ROGUE)
		Types.ROGUE_COOLDOWN:
			player_cell_manager.add_cooldown(PlayerCellData.Types.ROGUE, -0.2)
		Types.ROGUE_CRIT:
			player_cell_manager.add_crit_chance(PlayerCellData.Types.ROGUE, 5)
		Types.ROGUE_CRIT_MULT:
			player_cell_manager.add_crit_mult(PlayerCellData.Types.ROGUE, 1)
		Types.ROGUE_XP:
			player_cell_manager.add_xp_increase(PlayerCellData.Types.ROGUE, 1)
		Types.EXECUTIONER:
			player_cell_manager.add_tower(PlayerCellData.Types.EXECUTIONER)
		Types.EXECUTIONER_COOLDOWN:
			player_cell_manager.add_cooldown(PlayerCellData.Types.EXECUTIONER, -0.5)
		Types.EXECUTIONER_CRIT:
			player_cell_manager.add_crit_chance(PlayerCellData.Types.EXECUTIONER, 10)
		Types.EXECUTIONER_CRIT_MULT:
			player_cell_manager.add_crit_mult(PlayerCellData.Types.EXECUTIONER, 1)
		Types.EXECUTIONER_XP:
			player_cell_manager.add_xp_increase(PlayerCellData.Types.EXECUTIONER, 1)
		_:
			return false
	return true


func _apply_building_upgrade(type: Types) -> bool:
	match type:
		Types.UNLOCK_LUMBERJACK:
			timer_manager.add_special_cell_spawn_timer(
				CellManager.Names.SPECIAL_LUMBERJACK,
				cell_manager.get_data(CellManager.Names.SPECIAL_LUMBERJACK).life_time,
				Color(0.714, 0.576, 0.373)
				)
		Types.ADD_LUMBERJACK:
			cell_manager.multiply_life_time(CellManager.Names.SPECIAL_LUMBERJACK, 2)
		Types.LUMBERJACK_AUTOMATION:
			building_manager.set_automated(BuildingManager.Buildings.LUMBERJACK, true)
		Types.LUMBERJACK_CD:
			building_manager.add_cooldown(BuildingManager.Buildings.LUMBERJACK, -0.2)
		Types.LUMBERJACK_WOOD:
			building_manager.add_production(BuildingManager.Buildings.LUMBERJACK, Economy.Currencies.WOOD, 10)
		Types.LUMBERJACK_CRIT:
			cell_manager.add_lumberjack_crit(10)
		Types.LUMBERJACK_DMG:
			cell_manager.add_lumberjack_dmg_ratio(0.05)
		Types.LUMBERJACK_CHARGE:
			building_manager.add_charge_per_hit(BuildingManager.Buildings.LUMBERJACK, 1)
		Types.LUMBERJACK_WOOD_SPAWN:
			cell_manager.add_lumberjack_spawn_wood_chance(25)
		Types.UNLOCK_OUTPOST:
			timer_manager.add_special_cell_spawn_timer(
				CellManager.Names.SPECIAL_OUTPOST,
				cell_manager.get_data(CellManager.Names.SPECIAL_OUTPOST).life_time,
				Color(0.302, 0.365, 0.388)
				)
		Types.OUTPOST_WEAKENING_CHANCE:
			cell_manager.add_outpost_weakening_chance(20)
		Types.OUTPOST_MULTIATTACKS:
			cell_manager.add_outpost_attacks(1)
		_:
			return false
	return true


func _apply_projectile_upgrade(type: Types) -> bool:
	match type:
		Types.BULLET_DMG:
			add_projectile_damage(ProjectileManager.Types.BULLET, 1)
		Types.BULLET_DIST:
			projectile_manager.add_max_range(ProjectileManager.Types.BULLET, 10)
		Types.BULLET_SPD:
			projectile_manager.add_spd(ProjectileManager.Types.BULLET, 5)
		Types.AXE_BOUNCE:
			projectile_manager.set_bounce(ProjectileManager.Types.AXE, true)
		Types.AXE_SPD:
			projectile_manager.add_spd(ProjectileManager.Types.AXE, 5)
		Types.DRUID_MAGIC_DMG:
			add_projectile_damage(ProjectileManager.Types.DRUID_MAGIC, 1)
		Types.DRUID_MAGIC_SPD:
			projectile_manager.add_spd(ProjectileManager.Types.DRUID_MAGIC, 15)
		Types.KNIFE_DMG:
			add_projectile_damage(ProjectileManager.Types.KNIFE, 1)
		Types.KNIFE_SPD:
			projectile_manager.add_spd(ProjectileManager.Types.KNIFE, 5)
		Types.KNIFE_PIERCING:
			projectile_manager.add_max_piercings(ProjectileManager.Types.KNIFE, 1)
		Types.KNIFE_RANGE:
			projectile_manager.add_max_range(ProjectileManager.Types.KNIFE, 10)
		Types.GREATAXE_DMG:
			add_projectile_damage(ProjectileManager.Types.GREATAXE, 2)
		Types.GREATAXE_BACKSTAB:
			projectile_manager.set_backstab(ProjectileManager.Types.GREATAXE, true)
		Types.GREATAXE_BACKSTAB_DMG:
			projectile_manager.add_backstab_bonus_dmg(ProjectileManager.Types.GREATAXE, 2)
		Types.GREATAXE_SPD:
			projectile_manager.add_spd(ProjectileManager.Types.GREATAXE, 10)
		Types.GREATAXE_PIERCING:
			projectile_manager.add_max_piercings(ProjectileManager.Types.GREATAXE, 1)
		Types.GREATAXE_RANGE:
			projectile_manager.add_max_piercings(ProjectileManager.Types.GREATAXE, 1)
			projectile_manager.add_max_range(ProjectileManager.Types.GREATAXE, 1)
		_:
			return false
	return true


func add_projectile_damage(type: ProjectileManager.Types, amount: int) -> void:
	damage_manager.add_flat_damage_bonus(type, amount)
