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
var effects: Array = []
@onready var effect_graphics: Dictionary = {
	EffectManager.Effects.WEAKENED: [$PanelWeaken],
	EffectManager.Effects.BUFFED: [$BuffedGraphics],
}

@onready var effect_progress_bars: Dictionary = {
	EffectManager.Effects.WEAKENED: $PanelWeaken
}

@onready var effect_timers: Dictionary = {
	EffectManager.Effects.WEAKENED: $TimerWeaken,
#	EffectManager.Effects.BUFFED: null,
}

signal effect_timeout(effect: EffectManager.Effects)


func _ready() -> void:
	timer.timeout.connect(_on_timeout)


#	panel.set("theme_override_styles/panel", panel_style)
	progress_bar_hp.set("theme_override_styles/background", progress_bar_hp_bg)
	progress_bar_hp.set("theme_override_styles/fill", progress_bar_hp_fill)
	set_physics_process(false)
	progress_bar.hide()
	progress_bar_hp.hide()
#	panel_weaken.hide()
	cell_hitbox.hitted.connect(_on_hitted)
	# todo change to effect_timers dic 
	
	for arr in effect_graphics.values():
		for node in arr:
			node.hide()
			
	for e in effect_timers.keys():
		if !effect_timers[e]:
			continue
			
		effect_timers[e].timeout.connect(func() -> void: _on_effect_timeout(e))
	
#	timer_weaken.timeout.connect(_on_weaken_timeout)


func _physics_process(delta) -> void:
	progress_bar.value = timer.time_left / data.life_time 
	for i in effects:
		if !effect_progress_bars.has(i):
			continue
			
		var pb: ProgressBar = effect_progress_bars[i]
		var timer: Timer = effect_timers[i]
		pb.value = timer.time_left / timer.wait_time

#	panel_weaken.value = timer_weaken


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


func set_data(_data: CellResourceData, args: Dictionary) -> void:
	if data == _data:
		return
	
	data = _data

#	panel_style.bg_color = Color(data.color, default_color.a)
	progress_bar_hp_bg.bg_color = Color(data.color, default_color_bg.a)
	progress_bar_hp_fill.bg_color = Color(data.color, default_color_fill.a)
	if data.life_time > 0:
		timer.wait_time = data.life_time - args.sub_life_time
		timer.start()
		progress_bar.value = timer.time_left / data.life_time
		
	if args.effects.is_empty():
		clear_effects()
	else:
		for e in args.effects:
			set_effect(e, true)
		
	set_hp(data.durability - args.sub_hp)
	manager.occupy_cell(self)


func set_disabled(_disabled: bool) -> void:
	collision.call_deferred("set_disabled", _disabled)
	if _disabled:
		panel_style.bg_color = default_color_bg
		progress_bar.hide()
		progress_bar_hp.hide()
		clear_effects()
#		progress_bar_hp_bg.bg_color = default_color
#		progress_bar_hp.value = 0
	else:
		progress_bar.show()
		progress_bar_hp.show()
		
	set_physics_process(!_disabled)


func _on_timeout() -> void:
	manager.free_cell(self)
	data = null
	set_disabled(true)


func clear_effects() -> void:
	for e in range(1, EffectManager.Effects.size()):
		set_effect(e, false)
	
	for timer in effect_timers.values():
		if !timer:
			continue
			
		timer.stop()


func set_effect(effect: EffectManager.Effects, enabled: bool) -> void:
	var timer: Timer
	if effect_timers.has(effect):
		timer = effect_timers[effect]
		
	if !enabled:
		if !effects.has(effect):
			return
		
		effects.erase(effect)
		if timer:
			timer.stop()
	else:
		if effects.has(effect):
			return
			
		effects.append(effect)
		if timer:
			timer.start()
	
	for i in effect_graphics[effect]:
		i.visible = enabled
		if i is ProgressBar:
			i.value = 0 if !enabled else 1


func _on_effect_timeout(effect: EffectManager.Effects) -> void:
	set_effect(effect, false)


# returns overheal
func add_life_time(amount: float) -> float:
	if !data.life_time:
		return 0
		
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


func is_weakened() -> bool:
	return effects.has(EffectManager.Effects.WEAKENED)


func is_buffed() -> bool:
	return effects.has(EffectManager.Effects.BUFFED)
