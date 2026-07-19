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

const _SCENE_BULLET: PackedScene = preload("res://Scenes/Projectiles/Bullet/bullet.tscn")
const _SCENE_KNIFE: PackedScene = preload("res://Scenes/Projectiles/Knife/knife.tscn")
const _SCENE_MAGIC: PackedScene = preload("res://Scenes/Projectiles/Magic/magic.tscn")
const _SCENE_AXE: PackedScene = preload("res://Scenes/Projectiles/Axe/axe.tscn")
const _SCENE_DRUID_MAGIC: PackedScene = preload("res://Scenes/Projectiles/DruidMagic/druid_magic.tscn")
const _SCENE_GREATAXE: PackedScene = preload("res://Scenes/Projectiles/Greataxe/greataxe.tscn")

const _DATA_BULLET: ProjectileData = preload("res://Resources/Projectiles/projectile_data_bullet.tres")
const _DATA_KNIFE: ProjectileData = preload("res://Resources/Projectiles/projectile_data_knife.tres")
const _DATA_MAGIC: ProjectileData = preload("res://Resources/Projectiles/projectile_data_magic.tres")
const _DATA_AXE: ProjectileData = preload("res://Resources/Projectiles/projectile_data_axe.tres")
const _DATA_DRUID_MAGIC: ProjectileData = preload("res://Resources/Projectiles/projectile_data_druid_magic.tres")
const _DATA_GREATAXE: ProjectileData = preload("res://Resources/Projectiles/projectile_data_greataxe.tres")

var projectile_scenes: Dictionary = {
	Types.BULLET: _SCENE_BULLET,
	Types.KNIFE: _SCENE_KNIFE,
	Types.MAGIC: _SCENE_MAGIC,
	Types.AXE: _SCENE_AXE,
	Types.DRUID_MAGIC: _SCENE_DRUID_MAGIC,
	Types.GREATAXE: _SCENE_GREATAXE,
}

var projectile_data: Dictionary = {
	Types.BULLET: _DATA_BULLET.duplicate(),
	Types.KNIFE: _DATA_KNIFE.duplicate(),
	Types.MAGIC: _DATA_MAGIC.duplicate(),
	Types.AXE: _DATA_AXE.duplicate(),
	Types.DRUID_MAGIC: _DATA_DRUID_MAGIC.duplicate(),
	Types.GREATAXE: _DATA_GREATAXE.duplicate(),
}

var projectile_container: Node2D
var damage_manager: DamageManager
var cell_manager: CellManager


func free_all_projectiles() -> void:
	for i in projectile_container.get_children():
		i.call_deferred("queue_free")


func get_data(type: Types) -> ProjectileData:
	return projectile_data[type]


func add_spd(type: Types, amount: float) -> void:
	projectile_data[type].spd += amount


func add_max_range(type: Types, amount: float) -> void:
	projectile_data[type].max_range += amount


func add_max_piercings(type: Types, amount: int) -> void:
	projectile_data[type].max_piercings += amount


func set_bounce(type: Types, enabled: bool) -> void:
	projectile_data[type].bounce = enabled


func set_backstab(type: Types, enabled: bool) -> void:
	projectile_data[type].backstab = enabled


func add_backstab_bonus_dmg(type: Types, amount: int) -> void:
	projectile_data[type].backstab_bonus_dmg += amount


func new_projectile(pos: Vector2, type: Types, crit_chance: int, crit_mult: int, mod_data: ProjectileDataModifiers, bonus_damage: Dictionary) -> Projectile:
	var projectile: Projectile = projectile_scenes[type].instantiate()
	projectile.data = projectile_data[type]
	projectile.crit_chance = crit_chance
	projectile.crit_mult = crit_mult
	projectile.global_position = pos
	projectile.cell_manager = cell_manager
	projectile.damage_data = damage_manager.build_projectile_damage(type, bonus_damage)
	projectile.mod_data = mod_data
	# Effects roll once at spawn from ProjectileDataModifiers (single path).
	projectile.weakening = mod_data.weakening_chance > 0 and randi() % 100 < mod_data.weakening_chance
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
