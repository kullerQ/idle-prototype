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
	BONUS,
	MULT,
}

enum TowerPresets {
	DRUID_DURAB,
	DRUID_LIFE_TIME,
}

var projectile_damage_data: Dictionary = {
	ProjectileManager.Types.BULLET: {
#		DamageDataTypes.BASE: {
#			Types.HEAL: {},
#			Types.HIT: {},
#		},
#		DamageDataTypes.BONUS: {
#			Types.HEAL: {},
#			Types.HIT: {},
#		},
#		DamageDataTypes.MULT: 1
	}
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

static func print_data(data: Dictionary) -> void:
	var dtk: Array = DamageDataTypes.keys()
	var tk: Array = Types.keys()
	var sk: Array = Stats.keys()
	print("###")
	for damage_type in data:
		if damage_type == DamageDataTypes.MULT:
			return
			
		print("\nx Damage type: %s" %dtk[damage_type])
		for type in data[damage_type]:
			print("= type: %s" %tk[type])
			for stat in data[damage_type][type]:
				print("# stat: %s value: %d" %[sk[stat], data[damage_type][type][stat]])

func add_mult(projectile_type: ProjectileManager.Types, amount: int) -> void:
	projectile_damage_data[projectile_type][DamageDataTypes.MULT] += amount

func set_mult(projectile_type: ProjectileManager.Types, mult: int = 1) -> void:
	projectile_damage_data[projectile_type][DamageDataTypes.MULT] = mult

func initialize() -> void:
	for i in range(1, ProjectileManager.Types.size()):
		flat_damage_bonus[i] = 0
		
	for projcetile in range(1, ProjectileManager.Types.size()):
		projectile_damage_data[projcetile] = {}
		for damage_data_type in DamageDataTypes.size():
			projectile_damage_data[projcetile][damage_data_type] = {}
			for type in Types.size():
				projectile_damage_data[projcetile][damage_data_type][type] = {}
		
	new_base_data(ProjectileManager.Types.BULLET, new_data(), new_data(1))
	new_base_data(ProjectileManager.Types.DRUID_MAGIC, new_data(0, 1))
	new_base_data(ProjectileManager.Types.AXE)

func new_tower_preset(tower_preset: TowerPresets, damage_data: Dictionary) -> void:
	tower_bonus_damage_presets[tower_preset] =  damage_data

func new_projectile_damage_data(data_type: DamageDataTypes, projectile_type: ProjectileManager.Types, damage_data: Dictionary) -> void:
	projectile_damage_data[projectile_type][data_type] = damage_data

func new_base_data(type: ProjectileManager.Types, base_heal_data: Dictionary = new_data(), base_hit_data: Dictionary = new_data(), bonus_heal_data: Dictionary = new_data(), bonus_hit_data: Dictionary = new_data()) -> void:
	new_projectile_damage_data(DamageDataTypes.BASE, type, new_damage_data(base_heal_data, base_hit_data))
	new_projectile_damage_data(DamageDataTypes.BONUS, type, new_damage_data(bonus_heal_data, bonus_hit_data))
	set_mult(type)

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
