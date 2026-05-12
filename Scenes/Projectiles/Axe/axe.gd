extends Projectile
class_name Axe

var target_pos: Vector2
var dmg_percent: float = 0
static var bounce: bool = false

func _ready() -> void:
	super()
	set_disabled(true)
	
func move(delta: float) -> void:
	global_position += global_position.direction_to(target_pos) * spd * delta
	if spd == 0:
		set_physics_process(false)
		if area.has_overlapping_areas():
			return
		
		if bounce:
			target_pos = G.cell_manager.get_rand_occupied_cell_global_center(null, CellManager.Types.WOOD)
			if target_pos:
				spd = data.spd
				set_physics_process(true)
				set_disabled(true)
				return
			
		die()
		return
		
	if global_position.distance_to(target_pos) <= 3:
		spd = 0
		set_disabled(false)

func before_hitted(cell: CellResource = null) -> void:
	dmg = (cell.data.durability * dmg_percent)
	super()
