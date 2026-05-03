extends Control
class_name PlayerCell

var data: PlayerCellData
@onready var timer: Timer = $Timer
@onready var marker_shoot: Marker2D = $MarkerShoot
@onready var progress_bar: ProgressBar = $ProgressBar

static var manager
static var projectile_manager: ProjectileManager

func _ready() -> void:
	set_physics_process(false)
	if !data:
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
	projectile_manager.add_projectile(bullet_pos, data.projectile_type, bullet_dir)
	timer.start()
	
func set_data(_data: PlayerCellData) -> void:
	data = _data
	progress_bar.show()
	timer.wait_time = data.cooldown
	set_process_unhandled_input(true)
	set_physics_process(true)

func _on_timeout() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		shoot()
