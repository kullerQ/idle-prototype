extends Resource
class_name BuildingData

@export var cooldown: float
@export var production: Dictionary = {Economy.Currencies.WOOD: 0}
@export var crit_chance: float = 0
@export var crit_mult: int = 0
@export var automated: bool = false
@export var charge_per_hit: int = 1
@export var charge: int = 1
