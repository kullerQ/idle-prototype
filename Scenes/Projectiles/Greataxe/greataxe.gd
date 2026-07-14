extends Projectile
class_name Greataxe

var target_pos: Vector2
var cell_height: int = 0
var damage_bonus_with_backstab: Dictionary = {}
var default_damage_bonus: Dictionary = {}

func _ready() -> void:
	super()
	if !data.backstab:
		return
		
	default_damage_bonus = damage_data[DamageManager.DamageDataTypes.BONUS]
	damage_bonus_with_backstab = default_damage_bonus.duplicate(true)
	damage_bonus_with_backstab[DamageManager.Types.HIT][DamageManager.Stats.HP] += data.backstab_bonus_dmg

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
