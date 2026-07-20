extends HBoxContainer
class_name TimerProgressBar

var timer: Timer
@onready var progress_bar: ProgressBar = $ProgressBar
var wt: float = 0
@onready var panel = $Icon/Panel
var tw: Tween


func _ready() -> void:
	wt = timer.wait_time
	timer.timeout.connect(_on_timeout)
	var fill_style = progress_bar.get("theme_override_styles/fill").duplicate()
	fill_style.set("bg_color", timer.color)
	progress_bar.set("theme_override_styles/fill", fill_style)


func _physics_process(delta: float) -> void:
	if !is_instance_valid(timer):
		set_physics_process(false)
		return
	progress_bar.value = (wt - timer.time_left) / wt


func _on_timeout() -> void:
	if !is_instance_valid(timer):
		return
	wt = timer.wait_time
	if tw:
		tw.kill()
		
	tw = create_tween()
	panel.position.y = -2
	tw.tween_property(panel, "position:y", 0, 0.2)
