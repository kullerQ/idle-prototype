extends Projectile
class_name Axe

var target_pos: Vector2
@onready var spd: float = data.spd
var dmg_percent: float = 0

func _ready() -> void:
	super()
	set_disabled(true)
	
func move(delta: float) -> void:
	global_position += global_position.direction_to(target_pos) * spd * delta
	if spd == 0:
		set_physics_process(false)
		if area.has_overlapping_areas():
			return
		
		die()
		return
		
	if global_position.distance_to(target_pos) <= 3:
		spd = 0
		set_disabled(false)

func before_hitted(cell: CellResource = null) -> void:
	dmg = (cell.data.durability * dmg_percent)
	super()
