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
	BULLER_SPD,
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
	LUMBERJACK_WOOD_SPANW,
	}

var cell_manager : CellManager
var damage_manager: DamageManager
var player_cell_manager : PlayerCellManager
var timer_manager: TimerManager
var projectile_manager: ProjectileManager
var building_manager: BuildingManager

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
	Types.BULLER_SPD: "bullet speed +5",
	Types.UNLOCK_LUMBERJACK: "every 15 seconds lumberjack builds his hut",
	Types.ADD_LUMBERJACK: "lumberjack stays in place for 10 more seconds",
	Types.LUMBERJACK_AUTOMATION: "lumberjack produces wood automatically",
	Types.LUMBERJACK_CD: "lumberjack's cooldown -2",
	Types.LUMBERJACK_WOOD: "lumberjack produces +10 more wood",
	Types.LUMBERJACK_CRIT: "lumberjack crit chance +10",
	Types.LUMBERJACK_DMG: "lumberjack deals 5% more damage from tree's hp",
	Types.LUMBERJACK_CHARGE: "lumberjack charge increase +1",
	Types.WOOD_SPAWNRATE: "wood resource spawnrate +1",
	Types.TREE_LIFETIME: "trees live longer for 0.5s",
	Types.TREE_DURABILITY: "tree durability +20, wood whey destroyed +10",
	Types.GROVE_ADD: "tree has a chance to become a grove",
	Types.GROVE_SPAWN: "grove spawn chance +1",
	Types.GROVE_VALUE: "grove value per hit +1",
	Types.SHOOTER_XP: "shooters get +1 xp",
	Types.AXE_BOUNCE: "axe bounces off empty cells",
	Types.AXE_SPD: "axe speed +10",
	Types.DRUID: "+1 druid",
	Types.DRUID_COOLDOWN: "druid cooldown -0.5s",
	Types.DRUID_CRIT: "druid crit chance +5",
	Types.DRUID_CRIT_MULT: "druid crit mult +1",
	Types.DRUID_MAGIC_DMG: "druid magic dmg +1",
	Types.DRUID_MAGIC_SPD: "druid magic speed +15",
	Types.DRUID_XP: "druid get +1 xp",
	Types.LUMBERJACK_WOOD_SPANW: "chance to spawn wood cell after lumberjack +25%",
	}

signal upgrade_purchased(type: Types)

func _init():
	upgrade_purchased.connect(_on_upgrade_purchased)
		
func get_description(type: Types) -> String:
	return descriptions[type]
		
func _on_upgrade_purchased(type: Types) -> void:
	match type:
		Types.ADD_TOWER_CELL:
			player_cell_manager.add_free_cell()
			
		Types.SHOOTER:
			player_cell_manager.add_tower(PlayerCellData.Types.SHOOTER)
			
		Types.SHOOTER_COOLDOWN:
			player_cell_manager.get_data(PlayerCellData.Types.SHOOTER).cooldown -= 0.1
			
		Types.SHOOTER_ACCURACY:
			player_cell_manager.get_data(PlayerCellData.Types.SHOOTER).accuracy += 1
			
		Types.SHOOTER_CRIT:
			player_cell_manager.get_data(PlayerCellData.Types.SHOOTER).crit_chance += 10
			
		Types.SHOOTER_CRIT_MULT:
			player_cell_manager.get_data(PlayerCellData.Types.SHOOTER).crit_mult += 1
			
		Types.BULLET_DMG:
			add_projectile_damage(ProjectileManager.Types.BULLET, 1)
			
		Types.BULLET_DIST:
			projectile_manager.get_data(ProjectileManager.Types.BULLET).max_range += 10
			
		Types.BULLER_SPD:
			projectile_manager.get_data(ProjectileManager.Types.BULLET).spd += 5
			
		Types.UNLOCK_LUMBERJACK:
			timer_manager.add_lumberjack_timer()
			
		Types.ADD_LUMBERJACK:
			cell_manager.get_data(CellManager.Names.SPECIAL_LUMBERJACK).life_time *= 2
			
		Types.LUMBERJACK_AUTOMATION:
			building_manager.set_automated(BuildingManager.Buildings.LUMBERJACK, true)
			
		Types.LUMBERJACK_CD:
			building_manager.get_data(BuildingManager.Buildings.LUMBERJACK).cooldown -= 0.2
			
		Types.LUMBERJACK_WOOD:
			building_manager.add_production(BuildingManager.Buildings.LUMBERJACK, Economy.Currencies.WOOD, 10)
			
		Types.LUMBERJACK_CRIT:
			cell_manager.get_data(CellManager.Names.SPECIAL_LUMBERJACK).crit_chance += 10
			
		Types.LUMBERJACK_DMG:
			cell_manager.get_data(CellManager.Names.SPECIAL_LUMBERJACK).dmg_ratio += 0.05
			
		Types.LUMBERJACK_CHARGE:
			building_manager.get_data(BuildingManager.Buildings.LUMBERJACK).charge_per_hit += 1
			
		Types.WOOD_SPAWNRATE:
			timer_manager.sub_timer_wait_t(TimerManager.Types.CELL_SPAWN, CellManager.Types.WOOD, 0.5)

		Types.TREE_LIFETIME:
			cell_manager.get_data(CellManager.Names.WOOD_TREE).life_time += 0.5
			
		Types.TREE_DURABILITY:
			var data: CellResourceData = cell_manager.get_data(CellManager.Names.WOOD_TREE)
			data.break_value += 10
			data.durability += 20
		
		Types.GROVE_ADD:
			cell_manager.add_cell_weight(CellManager.Names.WOOD_GROVE, 3, CellManager.Types.WOOD)
			cell_manager.add_resource(CellManager.Names.WOOD_GROVE)
			
		Types.GROVE_SPAWN:
			cell_manager.add_cell_weight(CellManager.Names.WOOD_GROVE, 1, CellManager.Types.WOOD)
			
		Types.GROVE_VALUE:
			cell_manager.get_data(CellManager.Names.WOOD_GROVE).value += 1
			
		Types.SHOOTER_XP:
			player_cell_manager.get_data(PlayerCellData.Types.SHOOTER).xp_increase += 1
			
		Types.AXE_BOUNCE:
			Axe.bounce = true
			
		Types.AXE_SPD:
			projectile_manager.get_data(ProjectileManager.Types.AXE).spd += 10
			
		Types.DRUID:
			player_cell_manager.add_tower(PlayerCellData.Types.DRUID)
			
		Types.DRUID_COOLDOWN:
			player_cell_manager.get_data(PlayerCellData.Types.DRUID).cooldown -= 0.1
			
		Types.DRUID_CRIT:
			player_cell_manager.get_data(PlayerCellData.Types.DRUID).crit_chance += 5
			
		Types.DRUID_CRIT_MULT:
			player_cell_manager.get_data(PlayerCellData.Types.DRUID).crit_mult += 1
			
		Types.DRUID_MAGIC_DMG:
			add_projectile_damage(ProjectileManager.Types.DRUID_MAGIC, 1)
			
		Types.DRUID_MAGIC_SPD:
			projectile_manager.get_data(ProjectileManager.Types.DRUID_MAGIC).spd += 15
			
		Types.DRUID_XP:
			player_cell_manager.get_data(PlayerCellData.Types.DRUID).xp_increase += 1
			
		Types.LUMBERJACK_WOOD_SPANW:
			cell_manager.get_data(CellManager.Names.SPECIAL_LUMBERJACK).spawn_wood_chance += 25
			
func add_projectile_damage(type: ProjectileManager.Types, amount: int) -> void:
	damage_manager.add_flat_damage_bonus(type, 1)
	
