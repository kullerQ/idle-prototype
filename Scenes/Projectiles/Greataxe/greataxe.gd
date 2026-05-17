extends Projectile
class_name Greataxe

var target_pos: Vector2
var cell_height: int = 0
var axe_spd: float = 0
var t: float = 0
var vel: Vector2 = Vector2(20, 1)
var damage_bonus_with_backstab: Dictionary = {}
var default_damage_bonus: Dictionary = {}

func _ready() -> void:
	super()
	if !data.backstab:
		return
		
	default_damage_bonus = damage_data[DamageManager.DamageDataTypes.BONUS]
	damage_bonus_with_backstab = default_damage_bonus.duplicate(true)
	damage_bonus_with_backstab[DamageManager.Types.HIT][DamageManager.Stats.HP] += data.backstab_bonus_dmg

#	t = init_pos.y

func _physics_process(delta: float) -> void:
	global_position.x += spd * delta
	if abs(global_position.x -  target_pos.x) < 5 && global_position.y != target_pos.y:
		spd = -spd
		global_position.y = target_pos.y
		if data.backstab:
			damage_data[DamageManager.DamageDataTypes.BONUS] = damage_bonus_with_backstab
	
	if global_position.y == target_pos.y && abs(init_pos.x - global_position.x) < 5:
		queue_free()

func after_hitted(cell: CellResource = null) -> void:
	particle_container.add_child(HitCircle.new(global_position))
	if spd < 0 && data.backstab:
		return
		
	pierced += 1
	if pierced >= data.max_piercings + 1:
		die()

	
#	t += speed * delta
#	global_position.y = init_pos.y - abs(t) 
#	global_position.x = init_pos.x + t**2 #sin(t)*10#(t*t)# - 5 * t
	
#	global_position.x = init_pos.y - (global_position.y**2 - 5 * global_position.y) / 10
#	global_position.y -= 50 * delta

##	global_position += global_position.direction_to(target_pos) * axe_spd * delta
#	if global_position.distance_to(target_pos) <= 5:
#		axe_spd = 0
#		set_physics_process(false)
