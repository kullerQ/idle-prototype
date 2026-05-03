class_name UpgradeManager

enum Types {
	NULL,
	SHOOTER_COOLDOWN,
	TREE_SPAWNRATE,
	BULLET_DMG,
	BULLET_DIST,
	BULLER_SPD,
	SHOOTER_ACCURACY,
}

var cell_manager : CellManager
var player_cell_manager : PlayerCellManager
var timer_manager: TimerManager
var projectile_manager: ProjectileManager

var descriptions: Dictionary = {
	Types.NULL: "add 1 shooter",
	Types.SHOOTER_COOLDOWN: "shooter cooldown -1",
	Types.TREE_SPAWNRATE: "tree spawntime -1",
	Types.BULLET_DMG: "bullet dmg +1",
	Types.BULLET_DIST: "bullet max distance +10",
	Types.BULLER_SPD: "bullet speed +10",
	Types.SHOOTER_ACCURACY: "shooter accuracy +1",
	}

signal upgrade_purchased(type: Types)

func _init():
	upgrade_purchased.connect(_on_upgrade_purchased)
		
func get_description(type: Types) -> String:
	return descriptions[type]
		
func _on_upgrade_purchased(type: Types) -> void:
	match type:
		Types.SHOOTER_COOLDOWN:
			player_cell_manager.get_data(PlayerCellData.Types.SHOOTER).cooldown -= 0.1
			
		Types.TREE_SPAWNRATE:
			print(timer_manager.get_timer(CellResourceData.Types.WOOD).wait_time)
			timer_manager.get_timer(CellResourceData.Types.WOOD).wait_time -= 0.1
	
		Types.BULLET_DMG:
			print(projectile_manager.get_data(ProjectileManager.Types.BULLET).dmg)
			projectile_manager.get_data(ProjectileManager.Types.BULLET).dmg += 1
			
		Types.BULLET_DIST:
			projectile_manager.get_data(ProjectileManager.Types.BULLET).max_range += 20
			
		Types.BULLER_SPD:
			projectile_manager.get_data(ProjectileManager.Types.BULLET).spd += 10
			
