class_name ProjectileManager

enum Types {
	NULL,
	BULLET,
	KNIFE,
	MAGIC,
	AXE,
	DRUID_MAGIC,
	GREATAXE,
	
}
var projectile_scenes: Dictionary = {
	Types.BULLET: load("uid://cqfvg24btpsd"),
	Types.KNIFE: load("uid://btawcaget3dop"),
	Types.MAGIC: load("uid://dbvm0xe75co22"),
	Types.AXE: load("uid://fayy1y7iri3x"),
	Types.DRUID_MAGIC: load("uid://dw7hqy0bhgwaw"),
	Types.GREATAXE: load("uid://b7cw5v3hfnc34"),
}

var projectile_data: Dictionary = {
	Types.BULLET: load("uid://c2v6gmbo5oumv").duplicate(),
	Types.KNIFE: load("uid://d2gth6s63tah6").duplicate(),
	Types.MAGIC: load("uid://cqm1gvin210dd").duplicate(),
	Types.AXE: load("uid://cwix8ktqxey3o").duplicate(),
	Types.DRUID_MAGIC: load("uid://ckqurogg2vv7y").duplicate(),
	Types.GREATAXE: load("uid://cvmku6kcw7ksr").duplicate(),
	}

var projectile_container: Node2D
var damage_manager: DamageManager
var cell_manager: CellManager

func free_all_projectiles() -> void:
	for i in projectile_container.get_children():
		i.call_deferred("queue_free")

func get_data(type: Types) -> ProjectileData:
	return projectile_data[type]
	
# TODO: refactor effects
func new_projectile(pos: Vector2, type: Types, crit_chance: int, crit_mult: int, _mod_data: ProjectileDataModifiers, bonus_damage: Dictionary) -> Projectile:
	var projectile: Projectile = projectile_scenes[type].instantiate()
	projectile.data = projectile_data[type]
	projectile.crit_chance = crit_chance
	projectile.crit_mult = crit_mult
	projectile.global_position = pos
	var damage_data: Dictionary = damage_manager.get_damage_data(type).duplicate(true)
	var base_damage_bonus: Dictionary = damage_data[DamageManager.DamageDataTypes.BONUS]
	for damage_type in bonus_damage:
		for stat in bonus_damage[damage_type]:
			var value: float = bonus_damage[damage_type][stat]
			base_damage_bonus[damage_type][stat] += value
			if damage_data[DamageManager.DamageDataTypes.BASE][damage_type][stat] > 0:
				base_damage_bonus[damage_type][stat] += damage_manager.flat_damage_bonus[type]
		
	projectile.damage_data = damage_data
	if _mod_data.weakening_chance > 0:
		projectile.weakening = true if randi() % 100 < _mod_data.weakening_chance else false

	projectile.mod_data = _mod_data
	return projectile
	
func new_resource_projectile(pos: Vector2, type: Types, crit_chance: int, crit_mult: int, mod_data: ProjectileDataModifiers, bonus_damage: Dictionary, _ignore: Array, _delay: float = 0) -> Projectile:
	var projectile: Projectile = new_projectile(pos, type, crit_chance, crit_mult, mod_data, bonus_damage)
	projectile.ignore = _ignore
	if _delay:
		projectile.hide()
		projectile.delay = _delay
		
	return projectile

func new_player_projectile(pos: Vector2, type: Types, crit_chance: int, crit_mult: int, mod_data: ProjectileDataModifiers, bonus_damage: Dictionary, _owner: PlayerCell) -> Projectile:
	var projectile: Projectile = new_projectile(pos, type, crit_chance, crit_mult, mod_data, bonus_damage)
	projectile.p_owner = _owner
	return projectile

func add_projectile(projectile: Projectile) -> void:
	projectile_container.call_deferred("add_child", projectile)

func add_bullet(pos: Vector2, crit_chance: int, crit_mult: int, _dir: Vector2, mod_data: ProjectileDataModifiers, bonus_damage: Dictionary,  _owner: PlayerCell) -> void:
	var bullet: Bullet = new_player_projectile(pos, Types.BULLET, crit_chance, crit_mult, mod_data, bonus_damage, _owner)
	bullet.spd = mod_data.bonus_bullet_spd
	bullet.dir = _dir
	add_projectile(bullet)

func add_knife(pos: Vector2, crit_chance: int, crit_mult: int, _dir: Vector2, mod_data: ProjectileDataModifiers, bonus_damage: Dictionary, _owner: PlayerCell) -> void:
	var knife: Knife = new_player_projectile(pos, Types.KNIFE, crit_chance, crit_mult, mod_data, bonus_damage, _owner)
	knife.dir = _dir
	add_projectile(knife)

func add_druid_magic(pos: Vector2, crit_chance: int, crit_mult: int, _dir: Vector2, mod_data: ProjectileDataModifiers, bonus_damage: Dictionary, _owner: PlayerCell) -> void:
	var druid_magic: DruidMagic = new_player_projectile(pos, Types.DRUID_MAGIC, crit_chance, crit_mult, mod_data, bonus_damage, _owner)
	druid_magic.dir = _dir
	add_projectile(druid_magic)

func add_greataxe(crit_chance: int, crit_mult: int, mod_data: ProjectileDataModifiers, bonus_damage: Dictionary, _owner: PlayerCell) -> void:
	var row_count: int = cell_manager.row_count
	var start_coords: Vector2i = Vector2i(0, randi_range(0, row_count))
#	start_coords = Vector2i.ZERO
	var pos: Vector2 = cell_manager.get_cell_global_center(start_coords)
	var greataxe: Greataxe = new_player_projectile(pos, Types.GREATAXE, crit_chance, crit_mult, mod_data, bonus_damage, _owner)
	var target_y: int = start_coords.y + 1 if start_coords.y < row_count else start_coords.y - 1
	greataxe.target_pos =  cell_manager.get_cell_global_center(Vector2i(greataxe.data.max_range, target_y))
	greataxe.cell_height =  cell_manager.CELL_SIZE.y
	add_projectile(greataxe)

func add_resource_axe(pos: Vector2, crit_chance: int, crit_mult: int, _dmg_ratio: float, _target_pos: Vector2, mod_data: ProjectileDataModifiers, _ignore: Array) -> void:
	var axe: Axe = new_resource_projectile(pos, Types.AXE, crit_chance, crit_mult, mod_data, {}, _ignore)
	axe.target_pos = _target_pos
	axe.dmg_ratio = _dmg_ratio
	add_projectile(axe)
	
func add_resource_bullet(pos: Vector2, crit_chance: int, crit_mult: int, _dir: Vector2, mod_data: ProjectileDataModifiers, _ignore: Array, _delay: float = 0) -> void:
	var bullet: Bullet = new_resource_projectile(pos, Types.BULLET, crit_chance, crit_mult, mod_data, {}, _ignore, _delay)
	bullet.dir = _dir
	add_projectile(bullet)
	

	
