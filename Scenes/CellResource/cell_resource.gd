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
#@onready var default_color: Color = panel_style.bg_color
@onready var default_color_bg: Color = progress_bar_hp_bg.bg_color
@onready var default_color_fill: Color = progress_bar_hp_fill.bg_color
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
#static var economy: Economy

func _ready() -> void:
	timer.timeout.connect(_on_timeout)
#	panel.set("theme_override_styles/panel", panel_style)
	progress_bar_hp.set("theme_override_styles/background", progress_bar_hp_bg)
	progress_bar_hp.set("theme_override_styles/fill", progress_bar_hp_fill)
	set_physics_process(false)
	progress_bar.hide()
	cell_hitbox.hitted.connect(_on_hitted)

func _physics_process(delta) -> void:
	progress_bar.value = timer.time_left / data.life_time 

func _on_hitted(dmg: int) -> void:
	if !data:
		return
	
	audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
	audio_stream_player.playing = true
	
	manager.cell_hitted.emit(self, dmg)
#	durability -= dmg
#	G.cell_hitted.emit(data.type, data._name)
#	if durability <= 0:
#		economy.add_resource(data.currency, data.break_value)
#		manager.free_cell(self)
#		data = null
#		set_disabled(true)
#		return
#
#	economy.add_resource(data.currency, data.value * dmg)
	
func sub_hp(v: int) -> void:
	set_hp(max(0, hp - v))
	
func set_hp(new_v: int) -> void:
	hp = new_v
	progress_bar_hp.value = float(hp) / data.durability
	if hp <= 0:
		manager.cell_died.emit(self)
	
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
	
	set_hp(data.durability)
	manager.occupy_cell(self)

func set_disabled(_disabled: bool) -> void:
	collision.call_deferred("set_disabled", _disabled)
	if _disabled:
		panel_style.bg_color = default_color_bg
		progress_bar.hide()
#		progress_bar_hp_bg.bg_color = default_color
		progress_bar_hp.value = 0
		set_physics_process(false)
	else:
		progress_bar.show()
		progress_bar_hp.show()
		set_physics_process(true)

func _on_timeout() -> void:
	manager.free_cell(self)
	data = null
	set_disabled(true)
