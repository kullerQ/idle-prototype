extends Control
class_name TimerUI

var timer_pb_scene: PackedScene = preload("res://features/timers/timer_progress_bar/timer_progress_bar.tscn")


func initialize(manager: TimerManager) -> void:
	manager.timer_added.connect(_on_timer_added)


func _on_timer_added(timer: Timer) -> void:
	var tpb: TimerProgressBar = timer_pb_scene.instantiate()
	tpb.timer = timer
	add_child(tpb)


#func setup_timers(timer_dict: Dictionary) -> void:
#	for tt in timer_dict.values():
#		for i in tt.values():
#			var tpb: TimerProgressBar = timer_pb_scene.instantiate()
#			tpb.timer = i
#			add_child(tpb)
#
