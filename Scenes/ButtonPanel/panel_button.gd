extends AnimatedButton
class_name PanelButton

var container: ButtonContainer


func setup(p_container: ButtonContainer) -> void:
	container = p_container
	_owner = p_container


func _ready() -> void:
	if container:
		_owner = container
	super()
