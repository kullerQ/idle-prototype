extends Control
class_name PlayerCell

const MAX_ACCURACY: int = 12
var data: PlayerCellData
@onready var timer: Timer = $Timer
@onready var marker_shoot: Marker2D = $MarkerShoot
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var panel: Panel = $Panel
@onready var panel_not_active: Panel = $PanelNotActive

static var manager
static var projectile_manager: ProjectileManager

func _ready() -> void:
	set_physics_process(false)
	if !data:
		panel.hide()
		panel_not_active.show()
		progress_bar.hide()
		progress_bar.hide()
		set_process_unhandled_input(false)
	
	timer.timeout.connect(_on_timeout)
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
		if !timer.is_stopped():
			return
			
		shoot()
	
func _physics_process(delta: float) -> void:
	progress_bar.value = (data.cooldown - timer.time_left) / data.cooldown
	
func shoot() -> void:
	var bullet_pos: Vector2 = marker_shoot.global_position
	var bullet_dir = bullet_pos.direction_to(get_global_mouse_position())
	if data.accuracy < MAX_ACCURACY:
		print(bullet_dir)
		bullet_dir = bullet_dir.rotated(deg_to_rad(randf_range(-MAX_ACCURACY + data.accuracy, MAX_ACCURACY - data.accuracy)))
		print(bullet_dir)
		
	var bullet_mult = 1
	if randf_range(0, 100) <= data.crit_chance:
		bullet_mult = data.crit_mult
		
	projectile_manager.add_projectile(bullet_pos, data.projectile_type, bullet_dir, bullet_mult)
	timer.start()
	timer.wait_time = data.cooldown
	
func set_data(_data: PlayerCellData) -> void:
	data = _data
	panel.show()
	panel_not_active.hide()
	if data.type == 0:
		return
		
	timer.wait_time = data.cooldown
	progress_bar.show()
	set_process_unhandled_input(true)
	set_physics_process(true)

func _on_timeout() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		shoot()
