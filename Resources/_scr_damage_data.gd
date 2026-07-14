extends Resource
class_name DamageData

enum Stats {
	NULL,
	HP,
	LIFE_TIME,
}

@export var base: Dictionary = {
	Stats.HP: 0.0,
	Stats.LIFE_TIME: 0.0,
}

var flat_bonus: Dictionary = {}
var mult: Dictionary = {}


func get_value(stat: Stats) -> float:
	return (base[stat] + flat_bonus.get(stat, 0)) * mult.get(stat, 1)


func add_flat_bonus(stat: Stats, amount: float) -> void:
	flat_bonus[stat] = flat_bonus.get(stat, 0) + amount


func add_mult(stat: Stats, amount: float) -> void:
	flat_bonus[stat] = mult.get(stat, 0) + amount


#enum Values {
#	NULL,
#	HP,
#	LIFE_TIME,
#}
#var dmg: Dictionary = {}
#var heal: Dictionary = {}
#var weakened_mod: float
#@export_group("damage")
#@export var HP_DMG: float = 0
#@export var LIFE_TIME_DMG: float = 0
#@export_group("heal")
#@export var HP_HEAL: float = 0
#@export var LIFE_TIME_HEAL: float = 0
#
#func _init(_dmg = {Values.HP: 1}, _weakened_mod: float = 1.4, _heal = {}) -> void:
#	dmg = _dmg
#	weakened_mod = _weakened_mod
#	heal = _heal
#
#func initialize() -> void:
#	var value_keys: Array = Values.keys()
#	for i in range(1, Values.size()):
#		dmg[i] = get("%s_DMG" %value_keys[i])
#		heal[i] = get("%s_HEAL" %value_keys[i])
#
#
#func add_dmg(type: Values, amount: int) -> void:
#	if !dmg.has(type):
#		set_dmg(type, amount)
#		return
#
#	set_dmg(type, dmg[type] + amount)
#
#func sub_dmg(type: Values, amount: int) -> void:
#	if !dmg.has(type):
#		return
#
#	set_dmg(type, dmg[type] - amount)
#
#func add_heal(type: Values, amount: int) -> void:
#	if !heal.has(type):
#		set_heal(type, amount)
#		return
#
#	set_heal(type, heal[type] + amount)
#
#func sub_heal(type: Values, amount: int) -> void:
#	if !heal.has(type):
#		return
#
#	set_heal(type, heal[type] - amount)
#
#func set_dmg(type: Values, v: int) -> void:
#	dmg[type] = v
#
#func set_heal(type: Values, v: int) -> void:
#	heal[type] = v
#
#
