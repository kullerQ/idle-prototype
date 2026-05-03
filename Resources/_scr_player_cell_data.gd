extends Resource
class_name PlayerCellData

enum Types {
	SHOOTER,
}
@export var cooldown: float
@export var projectile_type: ProjectileManager.Types
