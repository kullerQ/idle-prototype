extends Projectile
class_name DruidMagic

#func when_hitted(_area: Area2D, cell: CellResource = null) -> void:
#	var dmg_data: DamageData = DamageData.new( {}, mod_data.weakened_dmg_mod, {DamageData.Values.LIFE_TIME: dmg})
#
##	if !mod_data.add_values.is_empty():
##		dmg_data.add = mod_data.add_values
##
##	if !mod_data.sub_values.is_empty():
##		dmg_data.sub = mod_data.sub_values
#
#	_area.hitted.emit(dmg_data)
#	apply_effects(cell)
