extends Projectile
class_name Bullet


func _draw() -> void:
	draw_circle(Vector2.ZERO, data.r + 1, Color.BLACK)
	draw_circle(Vector2.ZERO, data.r, Color.GOLDENROD)


#func when_hitted(_area: Area2D, cell: CellResource = null) -> void:
#	_area.hitted.emit(DamageData.new({DamageData.Values.LIFE_TIME: dmg, DamageData.Values.HP: dmg * 2}, mod_data.weakened_dmg_mod))
#	apply_effects(cell)
