class_name ProjectileManager

enum Types {
	NULL,
	BULLET,
	KNIFE,
	MAGIC
}
var projectile_scenes: Dictionary = {
	Types.BULLET: load("uid://cqfvg24btpsd"),
	Types.KNIFE: load("uid://btawcaget3dop"),
	Types.MAGIC: load("uid://dbvm0xe75co22"),
}

var projectile_data: Dictionary = {
	Types.BULLET: load("uid://c2v6gmbo5oumv").duplicate(),
	Types.KNIFE: load("uid://d2gth6s63tah6").duplicate(),
	Types.MAGIC: load("uid://cqm1gvin210dd").duplicate(),
	}

var projectile_container: Node2D

func get_data(type: Types) -> ProjectileData:
	return projectile_data[type]

func new_projectile(_owner: PlayerCell, pos: Vector2, type: Types, mult: int) -> Projectile:
	var projectile: Projectile = projectile_scenes[type].instantiate()
	projectile.data = projectile_data[type]
	projectile.dmg_mult = mult
	projectile.global_position = pos
	projectile.p_owner = _owner
	return projectile

func add_projectule(_owner: PlayerCell, pos: Vector2, type: Types, mult: int, _dir: Vector2) -> void:
	var projectile: Projectile = new_projectile(_owner, pos, type, mult)
	projectile.dir = _dir
	projectile_container.add_child(projectile)

func add_bullet(_owner: PlayerCell, pos: Vector2, mult: int, _dir: Vector2) -> void:
	add_projectule(_owner, pos, Types.BULLET, mult, _dir)

func add_knife(_owner: PlayerCell, pos: Vector2, mult: int, _dir: Vector2) -> void:
	add_projectule(_owner, pos, Types.KNIFE, mult, _dir)

func add_magic(_owner: PlayerCell, pos: Vector2, mult: int, target_pos: Vector2) -> void:
	var projectile: Magic = new_projectile(_owner, pos, Types.MAGIC, mult)
	projectile.target_pos = target_pos
	projectile_container.add_child(projectile)
	
	
