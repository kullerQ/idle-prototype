extends Resource
class_name ProjectileDataModifiers

var weakened_dmg_mod: float
var weakening_chance: int
var ricochet_if_weakened: bool
var reduce_cd_if_weakened: float
var bonus_bullet_spd: int 
var ricochet_after_kill: bool
var spread_damage_ratio: float
var spread_damage_to: int
var bonus_crit_chance_on_weakened: int


func _init(_weakened_dmg_mod: float = 0, 
			_weakening_chance: int = 0, 
			_ricochet_if_weakened: bool = false, 
			_reduce_cd_if_weakened: float = 0,
			_bonus_bullet_spd: int = 0,
			_ricochet_after_kill: bool = false,
			_spread_damage_ratio: float = 0,
			_spread_damage_to: int = 0,
			_bonus_crit_chance_on_weakened: int = 0,
			) -> void:

	weakened_dmg_mod = _weakened_dmg_mod
	weakening_chance = _weakening_chance
	ricochet_if_weakened = _ricochet_if_weakened
	reduce_cd_if_weakened = _reduce_cd_if_weakened
	bonus_bullet_spd = _bonus_bullet_spd
	ricochet_after_kill = _ricochet_after_kill
	spread_damage_ratio = _spread_damage_ratio
	spread_damage_to = _spread_damage_to
	bonus_crit_chance_on_weakened = _bonus_crit_chance_on_weakened
