extends Control
class_name PlayerCell

const MAX_ACCURACY: int = 12
var data: PlayerCellData
@onready var bullet_pos_marker: Marker2D = $MarkerShoot 
@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var panel: Panel = $Panel
@onready var panel_not_active: Panel = $PanelNotActive
@onready var pb_style: StyleBoxFlat = progress_bar.get("theme_override_styles/fill").duplicate()
@onready var timer_multi_attack: Timer = $TimerMultiAttack
var attack_count: int = 0
var type_name: String
var xp: float = 0
var lvl: int = 0

static var manager
static var projectile_manager: ProjectileManager

func _ready() -> void:
	set_physics_process(false)
	if !data:
		panel.hide()
		panel_not_active.show()
		progress_bar.hide()
		progress_bar.set("theme_override_styles/fill", pb_style)
		progress_bar.hide()
		set_process_unhandled_input(false)
	
	timer.timeout.connect(_on_timeout)
	timer_multi_attack.timeout.connect(_on_multi_attack_timeout)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
		if !timer.is_stopped():
			return
			
		attack()
	
func _physics_process(delta: float) -> void:
	progress_bar.value = (data.cooldown - timer.time_left) / data.cooldown
	
func add_xp() -> void:
	xp += data.xp_increase - float(lvl) / 10
	if xp >= 100:
		xp = xp - 100
		add_lvl()
		
func add_lvl() -> void:
	lvl += 1
	
func start_cd_timer() -> void:
	timer.wait_time = data.cooldown
	timer.start()

func start_multi_attack_timer() -> void:
	timer_multi_attack.wait_time = data.multi_attack_delay
	timer_multi_attack.start()

func attack() -> void:
	call(type_name + "_attack")
	attack_count += 1
	if attack_count < data.attacks:
		start_multi_attack_timer()
		return
		
	attack_count = 0
	start_cd_timer()
	
func set_data(_data: PlayerCellData) -> void:
	data = _data
	panel.show()
	panel_not_active.hide()
	if data.type == 0:
		return
		
	pb_style.set("bg_color", data.color)
	type_name = PlayerCellData.Types.keys()[data.type].to_lower()
	timer.wait_time = data.cooldown
	timer_multi_attack.wait_time = data.multi_attack_delay
#	if data.autoattack:
#		attack()
		
	progress_bar.show()
	set_process_unhandled_input(true)
	set_physics_process(true)

func _on_timeout() -> void:
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !data.autoattack:
		return
	
	attack()

func _on_multi_attack_timeout() -> void:
	attack()

func get_bullet_mult() -> int:
	if randf_range(0, 100) <= data.crit_chance:
		return data.crit_mult
	
	return 1

func get_bullet_pos() -> Vector2:
	return bullet_pos_marker.global_position

func accuracy_rotated_dir(dir: Vector2) -> Vector2:
	return dir.rotated(deg_to_rad(randf_range(-MAX_ACCURACY + data.accuracy, MAX_ACCURACY - data.accuracy)))

func get_attack_dir_to_mouse() -> Vector2:
	var bullet_dir = get_bullet_pos().direction_to(get_global_mouse_position())
	if data.accuracy < MAX_ACCURACY:
		bullet_dir = accuracy_rotated_dir(bullet_dir)
	
	return bullet_dir
	
func get_dir(pos: Vector2) -> Vector2:
	return get_attack_dir_to_mouse() if !data.autoattack else pos.direction_to(G.cell_manager.get_rand_occupied_cell_global_center())
	
# shooter
##################################
func shooter_attack() -> void:
	projectile_manager.add_bullet(self, get_bullet_pos(), get_bullet_mult(), get_dir(get_bullet_pos()))

# rogue
func rogue_attack() -> void:
	projectile_manager.add_knife(self, get_bullet_pos(), get_bullet_mult(), get_dir(get_bullet_pos()))

# wizard
##################################
func wizard_attack() -> void:
	projectile_manager.add_magic(self, get_bullet_pos(), get_bullet_mult(), G.cell_manager.get_cell_global_center(Vector2(10, randi_range(0, 7))))

