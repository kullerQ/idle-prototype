extends Resource
class_name DamageData

enum Types {
	NULL,
	HIT,
	HEAL_LIFETIME,
	HEAL_DURABILITY,
}

var type: Types
var dmg: float
var weakened_mod: float

func _init(_dmg: float, _weakened_mod: float, _type: Types = Types.HIT) -> void:
	dmg = _dmg
	weakened_mod = _weakened_mod
	type = _type
