class_name ProjectileManager

enum Types {
	NULL,
	BULLET,
	KNIFE,
	MAGIC,
	AXE
	
}
var projectile_scenes: Dictionary = {
	Types.BULLET: load("uid://cqfvg24btpsd"),
	Types.KNIFE: load("uid://btawcaget3dop"),
	Types.MAGIC: load("uid://dbvm0xe75co22"),
	Types.AXE: load("uid://fayy1y7iri3x"),
}

var projectile_data: Dictionary = {
	Types.BULLET: load("uid://c2v6gmbo5oumv").duplicate(),
	Types.KNIFE: load("uid://d2gth6s63tah6").duplicate(),
	Types.MAGIC: load("uid://cqm1gvin210dd").duplicate(),
	Types.AXE: load("uid://cwix8ktqxey3o").duplicate(),
	}

var projectile_container: Node2D

func get_data(type: Types) -> ProjectileData:
	return projectile_data[type]

func new_projectile(pos: Vector2, type: Types, mult: int) -> Projectile:
	var projectile: Projectile = projectile_scenes[type].instantiate()
	projectile.data = projectile_data[type]
	projectile.dmg_mult = mult
	projectile.global_position = pos
	return projectile
	
func new_player_projectle(pos: Vector2, type: Types, mult: int, _owner: PlayerCell) -> Projectile:
	var projectile: Projectile = new_projectile(pos, type, mult)
	projectile.p_owner = _owner
	return projectile

func add_projectile(projectile: Projectile) -> void:
	projectile_container.call_deferred("add_child", projectile)
#	var projectile: Projectile = new_player_projectle(pos, type, mult, _owner)
#	projectile.dir = _dir

func add_bullet(pos: Vector2, mult: int, _dir: Vector2, _owner: PlayerCell) -> void:
	var bullet: Bullet = new_player_projectle(pos, Types.BULLET, mult, _owner)
	bullet.dir = _dir
	add_projectile(bullet)

func add_knife(pos: Vector2, mult: int, _dir: Vector2, _owner: PlayerCell) -> void:
	var knife: Knife = new_player_projectle(pos, Types.KNIFE, mult, _owner)
	knife.dir = _dir
	add_projectile(knife)

func add_magic(pos: Vector2, mult: int, _target_pos: Vector2, _owner: PlayerCell) -> void:
	var magic: Magic = new_player_projectle(pos, Types.MAGIC, mult, _owner)
	magic.target_pos = _target_pos
	add_projectile(magic)
	
func new_resource_projectule(pos: Vector2, type: Types, mult: int, _ignore: Array) -> Projectile:
	var projectile: Projectile = new_projectile(pos, type, mult)
	projectile.ignore = _ignore
	return projectile

func add_resource_axe(pos: Vector2, mult: int, _dmg_percent: float, _target_pos: Vector2, _ignore: Array) -> void:
	var axe: Axe = new_resource_projectule(pos, Types.AXE, mult, _ignore)
	axe.target_pos = _target_pos
	axe.dmg_percent = _dmg_percent
	add_projectile(axe)

#func add_resource_projectile(pos: Vector2, mult: int, type: Types, _dir: Vector2, _ignore: Array) -> void:
#	var projectile: Projectile = new_resource_projectule(pos, mult, type, _ignore)
#	projectile.dir = _dir
#	projectile_container.call_deferred("add_child", projectile)
	

	
