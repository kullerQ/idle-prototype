extends VBoxContainer
class_name LevelUpgradePath

@onready var node: LevelUpgradeNode = $LevelUpgradeNode

func _ready() -> void:
	var root: Container = get_node_or_null("Root")
	if !root:
		return
		
	root.hide()
