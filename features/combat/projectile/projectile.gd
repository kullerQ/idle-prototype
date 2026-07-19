extends Node2D
class_name Projectile

var dir: Vector2 = Vector2.ZERO
var data: ProjectileData
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area: Area2D = $Area2D
var mod_data: ProjectileDataModifiers
var damage_data: Dictionary
var cell_manager: CellManager
var dmg: float = 0
var spd: int = 0
var crit_mult: int = 0
var init_pos: Vector2
var crit_chance: int = 1
var p_owner: PlayerCell
var pierced: int = 0
var ignore: Array = []
var weakening: bool = false
var base_mult: int = 1
var critted: bool = false
var delay: float = 0
var particle_container: Node2D

signal crit_occurred(pos: Vector2)


func _ready() -> void:
	if delay:
		set_physics_process(false)
		await get_tree().create_timer(delay).timeout
		show()
		set_physics_process(true)
		
	collision.shape.radius = data.r
	area.area_entered.connect(_on_area_entered)
	init_pos = global_position
#	dmg = data.dmg
	spd += data.spd
	base_mult = damage_data[DamageManager.DamageDataTypes.MULT]
	if p_owner:
		damage_data["owner"] = p_owner


func _physics_process(delta: float) -> void:
	move(delta)
	check_max_range()


func move(delta: float) -> void:
	if !dir:
		queue_free()
		
	global_position += dir * spd * delta


func check_max_range() -> void:
	if global_position.distance_squared_to(init_pos) >= data.max_range * data.max_range:
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, data.r + 1, Color.BLACK)
	draw_circle(Vector2.ZERO, data.r, Color.DARK_GRAY)


func before_hitted(cell: CellResource = null) -> void:
	apply_crit()


func after_hitted(cell: CellResource = null) -> void:
	particle_container.add_child(HitCircle.new(global_position))
	pierced += 1
		
	if mod_data.ricochet_after_kill:
		if cell.hp <= 0:
			ricochet(cell)
			return
		
	if pierced >= data.max_piercings + 1:
		die()


func die() -> void:
	queue_free()


func when_hitted(_area: Area2D, cell: CellResource = null) -> void:
	if p_owner:
		p_owner.add_xp()
	
	if cell.is_weakened():
		damage_data[DamageManager.DamageDataTypes.MULT] += mod_data.weakened_dmg_mod
	
	_area.hitted.emit(damage_data, get_spread_damage_data())
	apply_effects(cell)


func get_spread_damage_data() -> Dictionary:
	return {"to":  mod_data.spread_damage_to, "ratio": mod_data.spread_damage_ratio}


func apply_effects(cell: CellResource) -> void:
	if weakening:
		if cell.is_weakened():
			if mod_data.ricochet_if_weakened:
				if ricochet(cell):
					pierced -= 1
			
			return
			
		cell.set_effect(EffectManager.Effects.WEAKENED, true)
	
	if cell.is_weakened():
		if mod_data.reduce_cd_if_weakened:
			p_owner.reduce_cd_time(mod_data.reduce_cd_if_weakened)


func apply_crit(chance: int = crit_chance) -> void:
	if randi() % 100 < chance:
		critted = true
		damage_data[DamageManager.DamageDataTypes.MULT] += crit_mult
		crit_occurred.emit(global_position)


func _on_area_entered(a: Area2D) -> void:
	var cell: CellResource = a.owner
	if ignore.has(cell):
		return
		
	before_hitted(cell)
	when_hitted(a, cell)
	after_hitted(cell)


func set_disabled(_disabled: bool) -> void:
	collision.disabled = _disabled


func get_dmg() -> float:
	var total: float = 0
	for dmg_type in range(DamageManager.DamageDataTypes.size()):
		for type in damage_data[dmg_type]:
			for stat in damage_data[dmg_type][type]:
				total += damage_data[dmg_type][type][stat]
				
	return total


func add_dmg(amount: int) -> void:
	for dmg_type in range(DamageManager.DamageDataTypes.size()):
		for type in damage_data[dmg_type]:
			for stat in damage_data[dmg_type][type]:
				damage_data[dmg_type][type][stat] += amount


func div_dmg(amount: int) -> void:
	for dmg_type in range(DamageManager.DamageDataTypes.size()):
		for type in damage_data[dmg_type]:
			for stat in damage_data[dmg_type][type]:
				damage_data[dmg_type][type][stat] = floor(damage_data[dmg_type][type][stat] / amount)


func ricochet(cell: CellResource = null, _div_dmg: bool = true) -> bool:
	damage_data[DamageManager.DamageDataTypes.MULT] = base_mult
	if get_dmg() <= 0:
		die()
		return false
		
	var target_cell_pos: Vector2 = cell_manager.get_rand_occupied_cell_global_center([cell])
	if !target_cell_pos:
		return false
		
	dir = global_position.direction_to(target_cell_pos) 
	if _div_dmg:
		div_dmg(2)
	
	return true
