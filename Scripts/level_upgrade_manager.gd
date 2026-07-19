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
	DRUID_SPAWN_WOOD_RIGHT,
	DRUID_OVERHEAL_LVLUP,
	ROGUE_CRIT_WEAK,
	DRUID_ADD_RES_ON_ATTACK,
	DRUID_MULTIATTACK,
	DRUID_CD_FOR_HEALED,
	DRUID_OBELISK_CHANCE,
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
	Types.DRUID_ADD_RES_ON_ATTACK: "when attacks give random cell's break value",
	Types.DRUID_MULTIATTACK: "multiattacks +2",
	Types.DRUID_CD_FOR_HEALED: "when reloads reduce cooldown for 0.05s for every healed cell",
	Types.SHOOTER_DPS_RICOCHET: "ricochets when kills cell",
	Types.SHOOTER_DPS_DMG: "bullet speed -30, bullet damage +10",
	Types.DRUID_OVERHEAL_SPAWN_WEAK: "if overheals: 25% chance to spawn weakened wood resource",
	Types.DRUID_SPAWN_WOOD_RIGHT: "+10% chance to spawn wood to the right of healed cell",
	Types.DRUID_OVERHEAL_LVLUP: "if overheals: 35% chance to upgrade cell",
	Types.ROGUE_CRIT_WEAK: "+30% crit chance if cell is weakened",
	Types.DRUID_OBELISK_CHANCE: "+10% chance to add 1 druid obelisk if overheals",
}


func apply_upgrade(type: Types, cell: PlayerCell) -> void:
	if _apply_shooter_upgrade(type, cell):
		pass
	elif _apply_druid_upgrade(type, cell):
		pass
	elif _apply_rogue_upgrade(type, cell):
		pass

	G.player_cell_manager.cell_upgraded.emit(cell)


func _apply_shooter_upgrade(type: Types, cell: PlayerCell) -> bool:
	match type:
		Types.SHOOTER_SUPPORT:
			cell.projectile_mod_data.weakening_chance += 40
		Types.SHOOTER_DPS:
			cell.projectile_mod_data.weakened_dmg_mod += 0.5
		Types.SHOOTER_WEAK_RIC:
			cell.projectile_mod_data.ricochet_if_weakened = true
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
		Types.SHOOTER_DPS_DMG:
			cell.projectile_mod_data.bonus_bullet_spd -= 30
			DamageManager.add_hit_hp(cell.bonus_damage, 10)
		_:
			return false
	return true


func _apply_druid_upgrade(type: Types, cell: PlayerCell) -> bool:
	match type:
		Types.DRUID_MULTIATTACK:
			cell.bonus_attacks += 2
		Types.DRUID_CD_FOR_HEALED:
			cell.reduce_cd_if_heal += 0.05
		Types.DRUID_AUTOAIM:
			cell.auto_aim = true
			cell.bonus_attacks += 1
		Types.DRUID_ADD_RES_ON_ATTACK:
			cell.attack_effects.append(PlayerCellManager.AttackEffects.RES_BREAK_VALUE)
		Types.DRUID_SPREAD:
			cell.projectile_mod_data.spread_damage_ratio += 0.5
			cell.projectile_mod_data.spread_damage_to += 2
		Types.DRUID_OVERHEAL_SPAWN_WEAK:
			cell.weakening_chance = 100
			cell.spawn_tree_on_overheal_chance += 25
		Types.DRUID_SPAWN_WOOD_RIGHT:
			cell.spawn_wood_to_the_right_chance += 10
		Types.DRUID_OVERHEAL_LVLUP:
			cell.cell_lvlup_chance += 35
		Types.DRUID_OBELISK_CHANCE:
			cell.obelisk_spawn_chance += 10
		_:
			return false
	return true


func _apply_rogue_upgrade(type: Types, cell: PlayerCell) -> bool:
	match type:
		Types.ROGUE_CRIT_WEAK:
			cell.projectile_mod_data.bonus_crit_chance_on_weakened += 30
		_:
			return false
	return true


func get_description(type: Types) -> String:
	return descriptions[type]
