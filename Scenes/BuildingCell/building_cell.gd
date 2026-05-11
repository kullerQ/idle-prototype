extends Control
class_name BuildingCell

var data: BuildingData
@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar
var graphics_cd: float
var current_charge: int = 0
var charged: bool = false
@onready var button: Button = $Button

static var economy: Economy

func _ready() -> void:
	set_physics_process(false)
	timer.timeout.connect(_on_timeout)
	button.pressed.connect(_on_pressed)
	if !data:
		return

func set_data(_data: BuildingData) -> void:
	data = _data
	$PanelNotActive.hide()
	$Panel.show()
	if !data.automated:
		G.resource_cell_hitted.connect(_on_resource_hitted)
		return
	
	automate()

func _physics_process(delta: float) -> void:
	progress_bar.value =  timer.time_left / graphics_cd #(graphics_cd - timer.time_left) / graphics_cd

func _on_resource_hitted(type: CellManager.Types, _name: CellManager.Names) -> void:
	return
#	if charged:
#		return
#
#	if type != Economy.Currencies.WOOD:
#		return
#
#	current_charge += 1
#	if current_charge >= data.charge:
#		set_charged(true)
##		current_charge -= data.charge
##		apply_effects()
	
	progress_bar.value = float(current_charge) / data.charge

func set_charged(enabled: bool) -> void:
	charged = enabled
	if charged && data.automated:
		timer.start()
		set_physics_process(true)
		
func automate() -> void:
#	G.resource_cell_hitted.disconnect(_on_resource_hitted)
	data.automated = true
	timer.wait_time = data.cooldown
	graphics_cd = timer.wait_time
	button.pressed.disconnect(_on_pressed)

func _on_timeout() -> void:
	timer.wait_time = data.cooldown
	graphics_cd = timer.wait_time
	current_charge = 0 
	set_charged(false)
	apply_effects()
	set_physics_process(false)

func apply_effects() -> void:
	for i in data.production:
		var v: int = data.production[i]
		if v != 0:
			var mult: int = 1
			if randf_range(0, 100) <= data.crit_chance:
				mult = data.crit_chance
				G.crit_label_requested.emit(progress_bar.global_position + progress_bar.size / 2)
				
			economy.add_resource(i, v * mult)
	
func _on_pressed() -> void:
	if charged:
		current_charge = max(0, current_charge - 1)
		progress_bar.value = float(current_charge) / data.charge
		if current_charge == 0:
			apply_effects()
			set_charged(false)
	
