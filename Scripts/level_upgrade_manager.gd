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
	SHOOTER_DPS_5,
	SHOOTER_DPS_6,
	SHOOTER_SUP_4,
	SHOOTER_SUP_5,
	SHOOTER_SUP_6,
	DRUID_OVERHEAL_SPAWN_WEAK,
}

var descriptions: Dictionary = {
	Types.NULL: "no description",
	Types.SHOOTER_SUPPORT: "40% chance to make a cell weakened on hit",
	Types.SHOOTER_DPS: "+50% dmg agains weakened",
	Types.SHOOTER_WEAK_RIC: "if bullet is weakening, it ricochets off the weakened cell",
	Types.SHOOTER_WEAK: "+25% chance to make a cell weakened on hit",
	Types.SHOOTER_AUTO_WEAK: "50% chance to shoot an additional weaking bullet in a direction of a random cell",
	Types.SHOOTER_DPS_CD_RESET_WEAK: "if hits weakened cell, reduce cooldown by 1 second",
	Types.SHOOTER_DPS_BULLET_SPD: "bullet speed +30",
	Types.DRUID_AUTOAIM: "druid shoots 2 projectiles in a direction of a random cell",
	Types.DRUID_SPREAD: "50% of heal spreads to 2 random cells",
	Types.SHOOTER_DPS_RICOCHET: "ricochets when kills cell",
	Types.SHOOTER_DPS_DMG: "bullet speed -30, bullet damage +10",
	Types.DRUID_OVERHEAL_SPAWN_WEAK: "if overheals: 25% chance to spawn weakened wood resource",
}

func apply_upgrade(type: Types, cell: PlayerCell) -> void:
	match type:
		Types.SHOOTER_SUPPORT:
			cell.projectile_mod_data.weakening_chance += 40
			
		Types.SHOOTER_DPS:
			cell.projectile_mod_data.weakened_dmg_mod += 0.5
		
		Types.SHOOTER_WEAK_RIC:
			cell.projectile_mod_data.ricohcet_if_weakened = true
			
		Types.SHOOTER_WEAK:
			cell.projectile_mod_data.weakening_chance += 20
			
		Types.SHOOTER_AUTO_WEAK:
			cell.auto_weakening_chance += 50
			
		Types.SHOOTER_DPS_CD_RESET_WEAK:
			cell.projectile_mod_data.reduce_cd_if_weakened += 1

		Types.SHOOTER_DPS_BULLET_SPD:
			cell.projectile_mod_data.bonus_bullet_spd += 30

		Types.SHOOTER_DPS_RICOCHET:
			cell.projectile_mod_data.ricochet_after_kill = true

		Types.DRUID_AUTOAIM:
			cell.auto_aim = true
			cell.bonus_attacks += 1

		Types.DRUID_SPREAD:
			cell.projectile_mod_data.spread_damage_ratio += 0.5
			cell.projectile_mod_data.spread_damage_to += 2
			
		Types.SHOOTER_DPS_DMG:
			cell.projectile_mod_data.bonus_bullet_spd -= 30
			DamageManager.add_hit_hp(cell.bonus_damage, 10)
			
		Types.DRUID_OVERHEAL_SPAWN_WEAK: 
			cell.weakening_chance = 100
			cell.spawn_tree_on_overheal_chance += 25
#			"if overheals: 25% chance to spawn weakened wood resource",
#			cell.projectile_mod_data.add_overwrite = {DamageData.Values.HP: 2}
#			cell.projectile_mod_data.sub_overwrite = {DamageData.Values.LIFE_TIME: 1}

	G.player_cell_manager.cell_upgraded.emit(cell)
		
func get_description(type: Types) -> String:
	return descriptions[type]
