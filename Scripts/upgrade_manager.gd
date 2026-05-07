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
	LUMBERJACK_CRIT_MULT,
	LUMBERJACK_CHARGE,
	TREE_SPAWNRATE,
	TREE_LIFETIME,
	TREE_DURABILITY, 
	}

var cell_manager : CellManager
var player_cell_manager : PlayerCellManager
var timer_manager: TimerManager
var projectile_manager: ProjectileManager
var building_manager: BuildingManager

var descriptions: Dictionary = {
	Types.NULL: "no description",
	Types.ADD_TOWER_CELL: "+1 additional cell for towers",
	Types.SHOOTER: "+1 shooter",
	Types.SHOOTER_COOLDOWN: "shooter cooldown -1",
	Types.SHOOTER_ACCURACY: "shooter accuracy +1",
	Types.SHOOTER_CRIT: "shooter crit chance +0.5",
	Types.SHOOTER_CRIT_MULT: "shooter crit multiplier +1",
	Types.BULLET_DMG: "bullet dmg +1",
	Types.BULLET_DIST: "bullet max distance +10",
	Types.BULLER_SPD: "bullet speed +10",
	Types.UNLOCK_LUMBERJACK: "clears the place for the lumberjack",
	Types.ADD_LUMBERJACK: "lumberjack builds his hut",
	Types.LUMBERJACK_AUTOMATION: "lumberjack produces wood automatically",
	Types.LUMBERJACK_CD: "lumberjack's cooldown -2",
	Types.LUMBERJACK_WOOD: "lumberjack produces +10 more wood",
	Types.LUMBERJACK_CRIT: "lumberjack crit chance +0.5",
	Types.LUMBERJACK_CRIT_MULT: "lumberjack crit multiplier +1",
	Types.LUMBERJACK_CHARGE: "lumberjack charge increase +1",
	Types.TREE_SPAWNRATE: "tree spawntime +5",
	Types.TREE_LIFETIME: "trees live longer for 0.5s",
	Types.TREE_DURABILITY: "tree durability +20, wood whey destroyed +10",
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
			player_cell_manager.get_data(PlayerCellData.Types.SHOOTER).crit_chance += 0.5
			
		Types.SHOOTER_CRIT_MULT:
			player_cell_manager.get_data(PlayerCellData.Types.SHOOTER).crit_mult += 1
			
		Types.BULLET_DMG:
			projectile_manager.get_data(ProjectileManager.Types.BULLET).dmg += 1
			
		Types.BULLET_DIST:
			projectile_manager.get_data(ProjectileManager.Types.BULLET).max_range += 10
			
		Types.BULLER_SPD:
			projectile_manager.get_data(ProjectileManager.Types.BULLET).spd += 10
			
		Types.UNLOCK_LUMBERJACK:
			pass
			
		Types.ADD_LUMBERJACK:
			building_manager.add_building(BuildingManager.Buildings.LUMBERJACK)
			
		Types.LUMBERJACK_AUTOMATION:
			building_manager.set_automated(BuildingManager.Buildings.LUMBERJACK, true)
			
		Types.LUMBERJACK_CD:
			building_manager.get_data(BuildingManager.Buildings.LUMBERJACK).cooldown -= 0.2
			
		Types.LUMBERJACK_WOOD:
			building_manager.add_production(BuildingManager.Buildings.LUMBERJACK, Economy.Currencies.WOOD, 10)
			
		Types.LUMBERJACK_CRIT:
			building_manager.get_data(BuildingManager.Buildings.LUMBERJACK).crit_chance += 0.5
			
		Types.LUMBERJACK_CRIT_MULT:
			building_manager.get_data(BuildingManager.Buildings.LUMBERJACK).crit_mult += 1
			
		Types.LUMBERJACK_CHARGE:
			building_manager.get_data(BuildingManager.Buildings.LUMBERJACK).charge_per_hit += 1
			
		Types.TREE_SPAWNRATE:
			timer_manager.get_timer(Economy.Currencies.WOOD).wait_time -= 0.5

		Types.TREE_LIFETIME:
			cell_manager.get_data(Economy.Currencies.WOOD).life_time += 0.5
			
		Types.TREE_DURABILITY:
			var data: CellResourceData = cell_manager.get_data(Economy.Currencies.WOOD)
			data.break_value += 10
			data.durability += 20
		

			
			
