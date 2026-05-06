extends Node2D
class_name Bullet

var dir: Vector2 = Vector2.ZERO
var data: ProjectileData
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area: Area2D = $Area2D
var init_pos: Vector2
var dmg_mult: int = 1
static var particle_container: Node2D

func _ready() -> void:
	collision.shape.radius = data.r
	area.area_entered.connect(_on_area_entered)
	init_pos = global_position
	
func _physics_process(delta: float) -> void:
	if !dir:
		queue_free()
		
	global_position += dir * data.spd * delta
	if global_position.distance_to(init_pos) >= data.max_range:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, data.r + 1, Color.BLACK)
	draw_circle(Vector2.ZERO, data.r, Color.GOLDENROD)

func _on_area_entered(a: Area2D) -> void:
	a.hitted.emit(data.dmg * dmg_mult)
	particle_container.add_child(HitCircle.new(global_position))
	if dmg_mult > 1:
		G.crit_label_requested.emit(global_position)
		
	queue_free()
	
