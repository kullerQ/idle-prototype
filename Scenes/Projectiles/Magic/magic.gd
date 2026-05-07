extends Projectile
class_name Magic

var target_pos: Vector2 
var spd: Vector2

func _ready() -> void:
	super()
	spd = Vector2(data.spd, 700)

func _physics_process(delta: float) -> void:
	global_position += global_position.direction_to(target_pos) * spd * delta
	if global_position.distance_to(target_pos) <= 5:
		queue_free()

func die() -> void:
	pass
