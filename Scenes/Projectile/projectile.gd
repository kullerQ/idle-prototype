extends Node2D
class_name Projectile

var dir: Vector2 = Vector2.ZERO
var data: ProjectileData
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area: Area2D = $Area2D
var dmg: int = 0
var init_pos: Vector2
var dmg_mult: int = 1
var p_owner: PlayerCell
var pierced: int = 0
static var particle_container: Node2D

func _ready() -> void:
	collision.shape.radius = data.r
	area.area_entered.connect(_on_area_entered)
	init_pos = global_position
	dmg = data.dmg

func _physics_process(delta: float) -> void:
	move(delta)
	check_max_range()

func move(delta: float) -> void:
	if !dir:
		queue_free()
		
	global_position += dir * data.spd * delta
	
func check_max_range() -> void:
	if global_position.distance_to(init_pos) >= data.max_range:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, data.r + 1, Color.BLACK)
	draw_circle(Vector2.ZERO, data.r, Color.DARK_GRAY)

func before_hitted(cell: CellResource = null) -> void:
	if dmg_mult > 1:
		apply_crit()
	
func after_hitted(cell: CellResource = null) -> void:
	particle_container.add_child(HitCircle.new(global_position))
	pierced += 1
	if pierced >= data.max_piercings + 1:
		die()

func die() -> void:
	p_owner.add_xp()
	queue_free()

func when_hitted(_area: Area2D) -> void:
	_area.hitted.emit(dmg)

func apply_crit() -> void:
	dmg *= dmg_mult
	G.crit_label_requested.emit(global_position)

func _on_area_entered(a: Area2D) -> void:
	var cell: CellResource = a.owner
	before_hitted(cell)
	when_hitted(a)
	after_hitted(cell)
	
