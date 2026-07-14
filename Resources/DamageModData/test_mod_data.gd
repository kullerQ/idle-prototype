extends DamageModData
class_name TestModData


func apply(data: DamageData) -> Dictionary:
	var damage: Dictionary = data.base.duplicate()
	damage[DamageData.Stats.HP] = data.get_value(DamageData.Stats.HP) * 2
	return damage
