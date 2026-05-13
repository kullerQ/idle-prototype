class_name DamageManager

enum Stats {
	HP,
	LIFE_TIME
}

enum Types {
	HEAL,
	HIT,
}

enum DamageDataTypes {
	BASE,
	BONUS
}

enum TowerPresets {
	DRUID_DURAB,
	DRUID_LIFE_TIME,
}

var projectile_damage_data: Dictionary = {
	ProjectileManager.Types.BULLET: {
		DamageDataTypes.BASE: {
			Types.HEAL: {},
			Types.HIT: {},
		},
		DamageDataTypes.BONUS: {
			Types.HEAL: {},
			Types.HIT: {},
		},
	},
}

var tower_bonus_damage_presets: Dictionary = {}

var flat_damage_bonus: Dictionary = {}

static func new_data(hp: float = 0, life_time: float = 0) -> Dictionary:
	var data: Dictionary = {}
	data[Stats.HP] = hp
	data[Stats.LIFE_TIME] = life_time
	return data

static func new_damage_data(heal_data: Dictionary, hit_data: Dictionary) -> Dictionary:
	var damage_data: Dictionary = {}
	damage_data[Types.HEAL] = heal_data
	damage_data[Types.HIT] = hit_data
	return damage_data

static func add_hit_hp(data: Dictionary, amount: float) -> void:
	data[Types.HIT][Stats.HP] += amount

func initialize() -> void:
	for i in range(1, ProjectileManager.Types.size()):
		flat_damage_bonus[i] = 0
		
	for projcetilein in range(1, ProjectileManager.Types.size()):
		projectile_damage_data[projcetilein] = {}
		for damage_data_type in DamageDataTypes:
			projectile_damage_data[projcetilein][damage_data_type] = {}
			for type in Types:
				projectile_damage_data[projcetilein][damage_data_type][type] = {}
		
	new_base_bullet_data()
	new_base_druid_magic_data()
	new_tower_preset(TowerPresets.DRUID_LIFE_TIME, new_damage_data(new_data(0, 10), new_data()))
	new_tower_preset(TowerPresets.DRUID_DURAB, new_damage_data(new_data(10, 0), new_data(0, 1)))

func new_tower_preset(tower_preset: TowerPresets, damage_data: Dictionary) -> void:
	tower_bonus_damage_presets[tower_preset] =  damage_data

func new_projectile_damage_data(data_type: DamageDataTypes, projectile_type: ProjectileManager.Types, damage_data: Dictionary) -> void:
	projectile_damage_data[projectile_type][data_type] = damage_data

func new_base_bullet_data() -> void:
	var base_heal_data: Dictionary = new_data()
	var base_hit_data: Dictionary = new_data(1)
	var bonus_heal_data: Dictionary = new_data()
	var bonus_hit_data: Dictionary = new_data()
	new_projectile_damage_data(DamageDataTypes.BASE, ProjectileManager.Types.BULLET, new_damage_data(base_heal_data, base_hit_data))
	new_projectile_damage_data(DamageDataTypes.BONUS, ProjectileManager.Types.BULLET, new_damage_data(bonus_heal_data, bonus_hit_data))

func new_base_druid_magic_data() -> void:
	var base_heal_data: Dictionary = new_data()
	var base_hit_data: Dictionary = new_data()
	var bonus_heal_data: Dictionary = new_data()
	var bonus_hit_data: Dictionary = new_data()
	new_projectile_damage_data(DamageDataTypes.BASE, ProjectileManager.Types.DRUID_MAGIC, new_damage_data(base_heal_data, base_hit_data))
	new_projectile_damage_data(DamageDataTypes.BONUS, ProjectileManager.Types.DRUID_MAGIC, new_damage_data(bonus_heal_data, bonus_hit_data))

func get_damage_data(projectile_type: ProjectileManager.Types) -> Dictionary:
	return projectile_damage_data[projectile_type]

func get_bonus_data(projectile_type: ProjectileManager.Types) -> Dictionary:
	return projectile_damage_data[projectile_type][DamageDataTypes.BONUS]

func add_hit_bonus(projectile_type: ProjectileManager.Types, stat: Stats, amount: float) -> void:
	get_bonus_data(projectile_type)[Types.HIT][stat] += amount
	
func get_damage(projectile_type: ProjectileManager.Types, type: Types, stat: Stats) -> float:
	var data: Dictionary = projectile_damage_data[projectile_type]
	return data[DamageDataTypes.BASE][type][stat] + data[DamageDataTypes.BONUS][type][stat]
	
func add_flat_damage_bonus(projectile_type: ProjectileManager.Types, amount: float) -> void:
	flat_damage_bonus[projectile_type] += amount
