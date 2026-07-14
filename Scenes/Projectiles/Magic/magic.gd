extends Projectile
class_name Magic

var target_pos: Vector2 
var mage_spd: Vector2

func _ready() -> void:
	super()
	mage_spd = Vector2(data.spd, 700)

func _physics_process(delta: float) -> void:
	global_position += global_position.direction_to(target_pos) * mage_spd * delta
	if global_position.distance_squared_to(target_pos) <= 25:
		queue_free()

func die() -> void:
	pass
