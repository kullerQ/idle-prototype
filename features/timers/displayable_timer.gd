extends Timer
class_name DisplayableTimer

var color: Color

signal mytimeout(timer: DisplayableTimer)


func _init(wait_t: float, _color: Color) -> void:
	wait_time = wait_t
	color = _color
	timeout.connect(func() -> void: mytimeout.emit(self))
