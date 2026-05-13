extends Resource
class_name ProjectileDataModifiers

var weakened_dmg_mod: float
var weakening_chance: float
var ricohcet_if_weakened: bool
var reduce_cd_if_weakened: float
var add_bullet_spd: int 
var add_overwrite: Dictionary
var sub_overwrite: Dictionary

func _init(_weakened_dmg_mod: float = 0, 
			_weakening_chance: float = 0, 
			_ricohcet_if_weakened: bool = false, 
			_reduce_cd_if_weakened: float = 0,
			_add_bullet_spd: int = 0,
			_add_overwrite: Dictionary = {},
			_sub_overwrite: Dictionary = {},
			) -> void:

	weakened_dmg_mod = _weakened_dmg_mod
	weakening_chance = _weakening_chance
	ricohcet_if_weakened = _ricohcet_if_weakened
	reduce_cd_if_weakened = _reduce_cd_if_weakened
	add_bullet_spd = _add_bullet_spd
	add_overwrite = _add_overwrite
	sub_overwrite = _sub_overwrite
