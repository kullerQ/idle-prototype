extends UpgradeEffect
class_name UpgradeEffectAddBuildingChargePerHit

## BuildingManager.Buildings value (int to avoid class_name cycle).
@export var building_type: int = 0
@export var amount: int = 0
