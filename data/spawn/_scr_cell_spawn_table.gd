extends Resource
class_name CellSpawnTable

## CellManager.Types value (int to avoid class_name cycle with CellManager).
@export var type: int = 1
@export var entries: Array[CellSpawnWeight] = []
