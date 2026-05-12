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
# todo refactor effects
func new_projectile(pos: Vector2, type: Types, mult: int, _mod_data: ProjectileDataModifiers) -> Projectile:
	var projectile: Projectile = projectile_scenes[type].instantiate()
	projectile.data = projectile_data[type]
	projectile.dmg_mult = mult
	projectile.global_position = pos
	var roll: float = randf_range(0, 1)
	if _mod_data.weakening_chance > 0:
		projectile.weakening = true if randf_range(0, 1) < _mod_data.weakening_chance else false
	
	projectile.mod_data = _mod_data
	
	return projectile
	
func new_resource_projectule(pos: Vector2, type: Types, mult: int, mod_data: ProjectileDataModifiers, _ignore: Array) -> Projectile:
	var projectile: Projectile = new_projectile(pos, type, mult, mod_data)
	projectile.ignore = _ignore
	return projectile

func new_player_projectle(pos: Vector2, type: Types, mult: int, mod_data: ProjectileDataModifiers, _owner: PlayerCell) -> Projectile:
	var projectile: Projectile = new_projectile(pos, type, mult, mod_data)
	projectile.p_owner = _owner
	return projectile

func add_projectile(projectile: Projectile) -> void:
	projectile_container.call_deferred("add_child", projectile)

func add_bullet(pos: Vector2, mult: int, _dir: Vector2, mod_data: ProjectileDataModifiers, _owner: PlayerCell) -> void:
	var bullet: Bullet = new_player_projectle(pos, Types.BULLET, mult, mod_data, _owner)
	bullet.spd = mod_data.add_bullet_spd
	bullet.dir = _dir
	add_projectile(bullet)

func add_knife(pos: Vector2, mult: int, _dir: Vector2, mod_data: ProjectileDataModifiers, _owner: PlayerCell) -> void:
	var knife: Knife = new_player_projectle(pos, Types.KNIFE, mult, mod_data, _owner)
	knife.dir = _dir
	add_projectile(knife)

func add_magic(pos: Vector2, mult: int, _target_pos: Vector2, mod_data: ProjectileDataModifiers, _owner: PlayerCell) -> void:
	var magic: Magic = new_player_projectle(pos, Types.MAGIC, mult, mod_data, _owner)
	magic.target_pos = _target_pos
	add_projectile(magic)
	
func add_resource_axe(pos: Vector2, mult: int, _dmg_percent: float, _target_pos: Vector2, mod_data: ProjectileDataModifiers, _ignore: Array) -> void:
	var axe: Axe = new_resource_projectule(pos, Types.AXE, mult, mod_data, _ignore)
	axe.target_pos = _target_pos
	axe.dmg_percent = _dmg_percent
	add_projectile(axe)
	

	
