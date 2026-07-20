extends TestCase


func test_projectile_damage_effect_applies_flat_bonus() -> void:
	var damage_manager: DamageManager = DamageManager.new()
	damage_manager.initialize()

	var applier: UpgradeApplier = UpgradeApplier.new()
	applier.damage_manager = damage_manager

	var effect: UpgradeEffectAddProjectileDamage = UpgradeEffectAddProjectileDamage.new()
	effect.projectile_type = ProjectileManager.Types.BULLET
	effect.amount = 7.0

	var definition: UpgradeDefinition = UpgradeDefinition.new()
	definition.effects = [effect]

	applier.apply(definition, 2)

	assert_eq(damage_manager.flat_damage_bonus[ProjectileManager.Types.BULLET], 14.0)
