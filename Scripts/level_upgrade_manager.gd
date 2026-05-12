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
}

var descriptions: Dictionary = {
	Types.NULL: "no description",
	Types.SHOOTER_SUPPORT: "40% chance to make a cell weaken on hit",
	Types.SHOOTER_DPS: "+50% dmg agains weakened",
	Types.SHOOTER_WEAK_RIC: "if bullet is weakening, it ricochets off the weakened cell",
	Types.SHOOTER_WEAK: "+25% chance to make a cell weaken on hit",
	Types.SHOOTER_AUTO_WEAK: "50% chance to shoot an additional weaking bullet in a direction of a random cell",
	Types.SHOOTER_DPS_CD_RESET_WEAK: "if hits weakened cell, reduce cooldown by 1 second",
	Types.SHOOTER_DPS_BULLET_SPD: "bullet speed +30",
}

func apply_upgrade(type: Types, cell: PlayerCell) -> void:
	match type:
		Types.SHOOTER_SUPPORT:
			cell.projectile_mod_data.weakening_chance += 0.4
			
		Types.SHOOTER_DPS:
			cell.projectile_mod_data.weakened_dmg_mod += 0.5
		
		Types.SHOOTER_WEAK_RIC:
			cell.projectile_mod_data.ricohcet_if_weakened = true
			
		Types.SHOOTER_WEAK:
			cell.projectile_mod_data.weakening_chance += 0.2
			
		Types.SHOOTER_AUTO_WEAK:
			cell.auto_weakening_chance += 0.5
			
		Types.SHOOTER_DPS_CD_RESET_WEAK:
			cell.projectile_mod_data.reduce_cd_if_weakened += 1

		Types.SHOOTER_DPS_BULLET_SPD:
			cell.projectile_mod_data.add_bullet_spd += 30

	G.player_cell_manager.cell_upgraded.emit(cell)
		
func get_description(type: Types) -> String:
	return descriptions[type]
