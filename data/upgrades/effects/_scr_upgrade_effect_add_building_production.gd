extends UpgradeEffect
class_name UpgradeEffectAddBuildingProduction

## BuildingManager.Buildings / Economy.Currencies values (ints to avoid class_name cycles).
@export var building_type: int = 0
@export var currency: int = 0
@export var value: int = 0
