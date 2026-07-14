extends AnimatedButton
class_name PanelButton

static var container: ButtonContainer


func _ready() -> void:
	_owner = container
	super()
