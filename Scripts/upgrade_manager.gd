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
	Types.AXE_SPD: "axe speed +5",
	Types.DRUID: "+1 druid",
	Types.DRUID_COOLDOWN: "druid cooldown -0.5s",
	Types.DRUID_CRIT: "druid crit chance +5%",
	Types.DRUID_CRIT_MULT: "druid crit mult +1",
	Types.DRUID_MAGIC_DMG: "druid magic dmg +1",
	Types.DRUID_MAGIC_SPD: "druid magic speed +15",
	Types.DRUID_XP: "druid get +1 xp",
	Types.LUMBERJACK_WOOD_SPANW: "chance to spawn wood cell after lumberjack +25%",
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
			timer_manager.add_special_cell_spawn_timer(
				CellManager.Names.SPECIAL_LUMBERJACK, 
				cell_manager.get_data(CellManager.Names.SPECIAL_LUMBERJACK).life_time,
				Color(0.714, 0.576, 0.373)
				).start()
			
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
			
		Types.UNLOCK_OUTPOST:
			timer_manager.add_special_cell_spawn_timer(
				CellManager.Names.SPECIAL_OUTPOST, 
				cell_manager.get_data(CellManager.Names.SPECIAL_OUTPOST).life_time,
				Color(0.302, 0.365, 0.388)
				).start()
			
		Types.OUTPOST_WEAKENING_CHANCE:
			cell_manager.get_data(CellManager.Names.SPECIAL_OUTPOST).weakening_chance += 20
			
		Types.OUTPOST_MULTIATTACKS:
			cell_manager.get_data(CellManager.Names.SPECIAL_OUTPOST).attacks += 1
			
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
			projectile_manager.get_data(ProjectileManager.Types.AXE).spd += 5
			
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
			
		Types.ROGUE:
			player_cell_manager.add_tower(PlayerCellData.Types.ROGUE)
			
		Types.ROGUE_COOLDOWN:
			player_cell_manager.get_data(PlayerCellData.Types.ROGUE).cooldown -= 0.2
			
		Types.ROGUE_CRIT:
			player_cell_manager.get_data(PlayerCellData.Types.ROGUE).crit_chance += 5
			
		Types.ROGUE_CRIT_MULT:
			player_cell_manager.get_data(PlayerCellData.Types.ROGUE).crit_mult += 1
			
		Types.ROGUE_XP:
			player_cell_manager.get_data(PlayerCellData.Types.ROGUE).xp_increase += 1
			
		Types.KNIFE_DMG:
			add_projectile_damage(ProjectileManager.Types.KNIFE, 1)
			
		Types.KNIFE_SPD:
			projectile_manager.get_data(ProjectileManager.Types.KNIFE).spd += 5
			
		Types.KNIFE_PIERCING:
			projectile_manager.get_data(ProjectileManager.Types.KNIFE).max_piercings += 1
			
		Types.KNIFE_RANGE:
			projectile_manager.get_data(ProjectileManager.Types.KNIFE).max_range += 10
			
		Types.EXECUTIONER:
			player_cell_manager.add_tower(PlayerCellData.Types.EXECUTIONER)
			
		Types.EXECUTIONER_COOLDOWN:
			player_cell_manager.get_data(PlayerCellData.Types.EXECUTIONER).cooldown -= 0.5
			
		Types.EXECUTIONER_CRIT:
			player_cell_manager.get_data(PlayerCellData.Types.EXECUTIONER).crit_chance += 10
			
		Types.EXECUTIONER_CRIT_MULT:
			player_cell_manager.get_data(PlayerCellData.Types.EXECUTIONER).crit_mult += 1
			
		Types.EXECUTIONER_XP:
			player_cell_manager.get_data(PlayerCellData.Types.EXECUTIONER).xp_increase += 1
			
		Types.GREATAXE_DMG:
			add_projectile_damage(ProjectileManager.Types.GREATAXE, 2)
			
		Types.GREATAXE_BACKSTAB:
			projectile_manager.get_data(ProjectileManager.Types.GREATAXE).backstab = true
			
		Types.GREATAXE_BACKSTAB_DMG:
			projectile_manager.get_data(ProjectileManager.Types.GREATAXE).backstab_bonus_dmg += 2
			
		Types.GREATAXE_SPD:
			projectile_manager.get_data(ProjectileManager.Types.GREATAXE).spd += 10
			
		Types.GREATAXE_PIERCING:
			projectile_manager.get_data(ProjectileManager.Types.GREATAXE).max_piercings += 1
			
		Types.GREATAXE_RANGE:
			projectile_manager.get_data(ProjectileManager.Types.GREATAXE).max_piercings += 1
			projectile_manager.get_data(ProjectileManager.Types.GREATAXE).max_range += 1
			
			
			
func add_projectile_damage(type: ProjectileManager.Types, amount: int) -> void:
	damage_manager.add_flat_damage_bonus(type, 1)
	
