extends Control
class_name CellResource

var data: CellResourceData
var durability: int = 1
@onready var cell_hitbox = $CellHitbox
@onready var collision: CollisionShape2D = $CellHitbox/CollisionShape2D
@onready var timer: Timer = $Timer
@onready var manager: CellManager = get_parent()
@onready var panel: Panel = $Panel
@onready var panel_style: StyleBoxFlat = panel.get("theme_override_styles/panel").duplicate()
@onready var default_color: Color = panel_style.bg_color
@onready var progress_bar = $ProgressBar
static var economy: Economy

func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	panel.set("theme_override_styles/panel", panel_style)
	set_physics_process(false)
	cell_hitbox.hitted.connect(_on_hitted)

func _on_hitted(dmg: int) -> void:
	durability -= dmg
	if durability <= 0:
		economy.add_resource(data.type, data.break_value)
		return
		
	economy.add_resource(data.type, data.value)
	
func set_data(_data: CellResourceData) -> void:
	if data == _data:
		return
	
	data = _data
	panel_style.bg_color = Color(data.color, default_color.a)
	timer.wait_time = data.life_time
	progress_bar.value = 1
	timer.start()
	durability = data.durability
	set_disabled(false)
	manager.occupy_cell(self)

func _physics_process(delta) -> void:
	progress_bar.value = timer.time_left / data.life_time 

func set_disabled(_disabled: bool) -> void:
	collision.call_deferred("set_disabled", _disabled)
	if _disabled:
		panel_style.bg_color = default_color
		set_physics_process(false)
	else:
		set_physics_process(true)

func _on_timeout() -> void:
	manager.free_cell(self)
	data = null
	set_disabled(true)
