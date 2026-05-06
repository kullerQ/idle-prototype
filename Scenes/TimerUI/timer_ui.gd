extends Control
class_name TimerUI

var timer_pb_scene: PackedScene = load("uid://c27fham6w4psy")

func setup_timers(timer_dict: Dictionary) -> void:
	for i in timer_dict.values():
		var tpb: TimerProgressBar = timer_pb_scene.instantiate()
		tpb.timer = i
		add_child(tpb)
