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
func before_hitted(cell: CellResource = null) -> void:
	if cell.is_weakened():
		apply_crit(crit_chance + mod_data.bonus_crit_chance_on_weakened)
		return
		
	apply_crit()

func _draw() -> void:
	draw_circle(Vector2.ZERO, data.r + 1, Color.BLACK)
	draw_circle(Vector2.ZERO, data.r, Color.SADDLE_BROWN)

func after_hitted(cell: CellResource = null) -> void:
	super()
	if !critted || p_owner.data.type != PlayerCellData.Types.ROGUE:
		return
	
	ricochet(cell)
