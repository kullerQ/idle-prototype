extends Node2D
class_name Bullet

var dir: Vector2 = Vector2.ZERO
var data: ProjectileData
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area: Area2D = $Area2D
var init_pos: Vector2

func _ready() -> void:
	collision.shape.radius = data.r
	area.area_entered.connect(_on_area_entered)
	init_pos = global_position
	print("dmg: %d\nspd: %d\nmax_range: %d\n" %[data.dmg, data.spd, data.max_range])
	
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
	a.hitted.emit(data.dmg)
	queue_free()
	
