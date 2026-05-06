extends Resource
class_name PlayerCellData

enum Types {
	NULL,
	SHOOTER,
}
@export var cooldown: float
@export var projectile_type: ProjectileManager.Types
@export var accuracy: float
@export var type: Types
@export var crit_chance: float
@export var crit_mult: int = 2
