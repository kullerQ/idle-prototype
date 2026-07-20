class_name RunState

var data: Dictionary = {}


func to_dict() -> Dictionary:
	return data.duplicate()


static func from_dict(d: Dictionary) -> RunState:
	var state: RunState = RunState.new()
	state.data = d.duplicate()
	return state
