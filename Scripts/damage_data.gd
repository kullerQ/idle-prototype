extends Resource
class_name DamageData

enum Values {
	NULL,
	HP,
	LIFE_TIME,
}
var add: Dictionary = {}
var sub: Dictionary = {}
var dmg: float
var weakened_mod: float

func _init(_sub = {Values.HP: 1}, _weakened_mod: float = 1.4, _add = {}) -> void:
	sub = _sub
	weakened_mod = _weakened_mod
	add = _add
