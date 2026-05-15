extends Resource
class_name PlayerCellData

enum Types {
	NULL,
	SHOOTER,
	ROGUE,
	WIZARD,
	DRUID,
}
@export var cooldown: float
@export var projectile_type: ProjectileManager.Types
@export var accuracy: float
@export var type: Types
@export var crit_chance: int
@export var crit_mult: int = 2
@export var xp_increase: float = 1
@export var autoattack: bool = false
@export var attacks: int = 1
@export var multi_attack_delay: float = 0.5
@export var color: Color
