extends Resource
class_name UpgradeDefinition
## Data-driven meta (or level) upgrade. Menus may still key off `id` during migration.

## UpgradeManager.Types value (int to avoid class_name cycle with UpgradeManager).
@export var id: int = 0
@export var description: String = ""
## Array of UpgradeEffect Resources (untyped to avoid class_name registration order issues).
@export var effects: Array = []
