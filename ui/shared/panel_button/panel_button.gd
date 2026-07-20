extends AnimatedButton
class_name PanelButton

var container: ButtonContainer


func setup(p_container: ButtonContainer) -> void:
	container = p_container
	_owner = p_container
	setup_label_factory(container.create_floating_label)


func _ready() -> void:
	if container:
		_owner = container
	super()
