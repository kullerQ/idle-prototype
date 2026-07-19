extends UpgradeEffect
class_name UpgradeEffectAddSpecialCellSpawnTimer

## CellManager.Names value (int to avoid class_name cycle).
## Wait time is taken from that cell's life_time at apply time.
@export var cell_name: int = 0
@export var color: Color = Color("#9c0a00")
