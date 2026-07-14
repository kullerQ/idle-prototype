extends Control
class_name ExpeditionUI

@onready var progress_bar_hp: ProgressBar = $VBoxContainer/ProgressBarHP
@onready var progress_bar_time_left: ProgressBar = $VBoxContainer/ProgressBarTimeLeft
var manager: ExpeditionManager


func _ready() -> void:
	manager.hp_changed.connect(_on_hp_changed)
	manager.expedition_started.connect(_on_expedition_started)


func _on_expedition_started() -> void:
	WipStub.wip("expedition_started")
#	progress_bar_hp.


func _on_hp_changed(new_hp: float, max_hp: float) -> void:
	progress_bar_hp.value = new_hp / max_hp 
