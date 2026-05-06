class_name ProjectileManager

enum Types {
	NULL,
	BULLET
}
var projectile_scenes: Dictionary = {
	Types.BULLET: load("uid://bpt60efhydw6q")
}

var projectile_data: Dictionary = {
		Types.BULLET: load("uid://c2v6gmbo5oumv").duplicate()
	}

var projectile_container: Node2D

func get_data(type: Types) -> ProjectileData:
	return projectile_data[type]

func add_projectile(pos: Vector2, type: Types, _dir: Vector2, mult: int) -> void:
	var projectile = projectile_scenes[type].instantiate()
	projectile.data = projectile_data[type]
	projectile.dmg_mult = mult
	projectile.global_position = pos
	projectile.dir = _dir
	projectile_container.add_child(projectile)
	
