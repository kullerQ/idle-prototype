extends Projectile
class_name DruidMagic

func when_hitted(_area: Area2D, cell: CellResource = null) -> void:
	_area.hitted.emit(DamageData.new(dmg, mod_data.weakened_dmg_mod, DamageData.Types.HEAL_LIFETIME))
	apply_effects(cell)
