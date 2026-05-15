extends Control
class_name CellResource

var data: CellResourceData
var hp: int = 1
@onready var cell_hitbox = $CellHitbox
@onready var collision: CollisionShape2D = $CellHitbox/CollisionShape2D
@onready var timer: Timer = $Timer
@onready var manager: CellManager = get_parent()
@onready var panel: Panel = $Panel
@onready var panel_style: StyleBoxFlat = panel.get("theme_override_styles/panel").duplicate()
@onready var progress_bar = $ProgressBar
@onready var progress_bar_hp = $ProgressBar2
@onready var progress_bar_hp_bg: StyleBoxFlat = progress_bar_hp.get("theme_override_styles/background").duplicate()
@onready var progress_bar_hp_fill: StyleBoxFlat = progress_bar_hp.get("theme_override_styles/fill").duplicate()
@onready var default_color_bg: Color = progress_bar_hp_bg.bg_color
@onready var default_color_fill: Color = progress_bar_hp_fill.bg_color
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var panel_weaken: ProgressBar = $PanelWeaken
var weakened: bool = false
@onready var timer_weaken: Timer = $TimerWeaken

func _ready() -> void:
	timer.timeout.connect(_on_timeout)
#	panel.set("theme_override_styles/panel", panel_style)
	progress_bar_hp.set("theme_override_styles/background", progress_bar_hp_bg)
	progress_bar_hp.set("theme_override_styles/fill", progress_bar_hp_fill)
	set_physics_process(false)
	progress_bar.hide()
	progress_bar_hp.hide()
	panel_weaken.hide()
	cell_hitbox.hitted.connect(_on_hitted)
	# todo change to effect_timers dic 
	timer_weaken.timeout.connect(_on_weaken_timeout)

func _physics_process(delta) -> void:
	progress_bar.value = timer.time_left / data.life_time 
	panel_weaken.value = timer_weaken.time_left / timer_weaken.wait_time

func _on_hitted(damage_data: Dictionary, spread_damage_data: Dictionary) -> void:
	if !data:
		return
	
	audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
	audio_stream_player.playing = true	
	manager.cell_hitted.emit(self, damage_data, spread_damage_data)
	
func sub_hp(v: int) -> void:
	if !data:
		return
	set_hp(hp - v)
	
func add_hp(v: int) -> void:
	if !data:
		return
		
	set_hp(min(data.durability, hp + v))
	
func set_hp(new_v: int) -> void:
	hp = new_v
	progress_bar_hp.value = float(hp) / data.durability
#	if hp <= 0:
#		manager.cell_died.emit(self)
	
func set_data(_data: CellResourceData) -> void:
	if data == _data:
		return
	
	data = _data
#	panel_style.bg_color = Color(data.color, default_color.a)
	progress_bar_hp_bg.bg_color = Color(data.color, default_color_bg.a)
	progress_bar_hp_fill.bg_color = Color(data.color, default_color_fill.a)
	if data.life_time > 0:
		timer.wait_time = data.life_time
		timer.start()
		progress_bar.value = data.life_time
	
	clear_effects()
	set_hp(data.durability)
	manager.occupy_cell(self)

func set_disabled(_disabled: bool) -> void:
	collision.call_deferred("set_disabled", _disabled)
	if _disabled:
		panel_style.bg_color = default_color_bg
		progress_bar.hide()
		progress_bar_hp.hide()
		panel_weaken.hide()
#		progress_bar_hp_bg.bg_color = default_color
#		progress_bar_hp.value = 0
		set_physics_process(false)
	else:
		progress_bar.show()
		panel_weaken.show()
		progress_bar_hp.show()
		set_physics_process(true)

func _on_timeout() -> void:
	manager.free_cell(self)
	data = null
	set_disabled(true)

func clear_effects() -> void:
	set_weakened(false)

func set_weakened(enabled: bool) -> void:
	if weakened == enabled:
		return
		
	weakened = enabled
	if weakened:
		panel_weaken.show()
		panel_weaken.value = 1
		timer_weaken.start()
	else:
		panel_weaken.hide()
		panel_weaken.value = 0
		timer_weaken.stop()
	
func _on_weaken_timeout() -> void:
	set_weakened(false)

# retunrs overheal
func add_life_time(amount: float) -> float:
	var time_left: float = timer.time_left
	var new_time_left: float = time_left + amount
	var overheal: float = 0
	timer.stop()
	if new_time_left > data.life_time:
		overheal = new_time_left - data.life_time
		new_time_left = data.life_time
	
	timer.wait_time = new_time_left
	timer.start()
	return overheal

# returns overkill
func sub_life_time(amount: float) -> float:
	var time_left: float = timer.time_left
	var new_time_left: float = time_left - amount
	timer.stop()
	if new_time_left <= 0.01:
		timer.timeout.emit()
		return new_time_left
	
	timer.wait_time = new_time_left
	timer.start()
	return 0
