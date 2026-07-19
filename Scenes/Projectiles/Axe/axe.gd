extends Projectile
class_name Axe

var target_pos: Vector2
var dmg_ratio: float = 0


func _ready() -> void:
	super()
	set_disabled(true)


func move(delta: float) -> void:
	global_position += global_position.direction_to(target_pos) * spd * delta
	if spd == 0:
		set_physics_process(false)
		if area.has_overlapping_areas():
			return
		
		if data.bounce:
			target_pos = cell_manager.get_rand_occupied_cell_global_center([], CellManager.Types.WOOD)
			if target_pos:
				spd = data.spd
				set_physics_process(true)
				set_disabled(true)
				return
			
		die()
		return
		
	if global_position.distance_squared_to(target_pos) <= 9:
		spd = 0
		set_disabled(false)


#func before_hitted(cell: CellResource = null) -> void:
#	dmg = (cell.data.durability * dmg_ratio)
#	super()


func when_hitted(_area: Area2D, cell: CellResource = null) -> void:
	damage_data[DamageManager.DamageDataTypes.BASE][DamageManager.Types.HIT][DamageManager.Stats.HP] = round(float(cell.data.durability) * dmg_ratio)
	_area.hitted.emit(damage_data, get_spread_damage_data())
