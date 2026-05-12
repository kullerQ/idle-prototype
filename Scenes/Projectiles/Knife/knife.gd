extends Projectile
class_name Knife

#var pirced: int = 0
#
#func after_hitted(_area: Area2D = null) -> void:
#	particle_container.add_child(HitCircle.new(global_position))
#	pirced += 1
#	if pirced >= data.max_pircings + 1:
#		die()
#
func _draw() -> void:
	draw_circle(Vector2.ZERO, data.r + 1, Color.BLACK)
	draw_circle(Vector2.ZERO, data.r, Color.SADDLE_BROWN)

func after_hitted(cell: CellResource = null) -> void:
	super()
	if dmg_mult == 1 || p_owner.data.type != PlayerCellData.Types.ROGUE:
		return
	
	ricochet(cell)
