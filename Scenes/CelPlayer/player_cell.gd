extends Control
class_name PlayerCell

const MAX_ACCURACY: int = 12
var data: PlayerCellData
# individual data
var cooldown_reduction: float = 0
var weakening_chance: float = 0
var weakened_dmg_mod: float = 1.4
var ricohcet_if_weakened: bool = false
var reduce_cd_if_weakened: float = 0
var auto_weakening_chance: float = 0
var special_attack_count: int = 0
var add_bullet_spd: int = 0
var projectile_add_overwrite: Dictionary = {} # {DamageData.Values.value: v} -> projectile_dmg * v
var projectile_sub_overwrite: Dictionary = {}
#################
var bonus_damage: Dictionary = {}
##############
var projectile_mod_data: ProjectileDataModifiers
var damage_data: DamageData
@onready var bullet_pos_marker: Marker2D = $MarkerShoot 
@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var panel: Panel = $Panel
@onready var panel_not_active: Panel = $PanelNotActive
@onready var pb_style: StyleBoxFlat = progress_bar.get("theme_override_styles/fill").duplicate()
@onready var timer_multi_attack: Timer = $TimerMultiAttack
@onready var button: Button = $Button
@onready var panel_highlight: Panel = $PanelHighlight

var cooldown: float = 1
var upgrade_path: int = 0
var attack_count: int = 0
var type_name: String
var xp: float = 0
var lvl: int = 0
var lvl_tokens: int = 0
@onready var upgrade_arrow: Polygon2D = $UpgradeArrow

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
	button.pressed.connect(_on_pressed)

	bonus_damage = DamageManager.new_damage_data(
		DamageManager.new_data(0, 0), # cell's bonus heal data 
		DamageManager.new_data(0, 0)  # cell's bonus hit data
		)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
		if !timer.is_stopped():
			return
			
		attack()
	
func _physics_process(delta: float) -> void:
	progress_bar.value = (cooldown - timer.time_left) / cooldown

func set_highlight(enabled: bool) -> void:
	if enabled:
		panel_highlight.show()
		return
	
	panel_highlight.hide()
	
func _on_pressed() -> void:
	if !data:
		return
		
	G.player_cell_pressed.emit(self)
	
	
func add_xp() -> void:
	xp += data.xp_increase - float(lvl) / 10
	if xp >= 100:
		xp = xp - 100
		add_lvl()
		
func add_lvl() -> void:
	lvl += 1
	lvl_tokens += 1
	upgrade_arrow.show()
	manager.cell_lvled_up.emit(self, lvl)
	
func sub_tokens() -> void:
	lvl_tokens -= 1
	if lvl_tokens == 0:
		upgrade_arrow.hide()
	
func start_cd_timer() -> void:
	cooldown = max(0.1, data.cooldown - cooldown_reduction)
	timer.wait_time = cooldown
	timer.start()

func start_multi_attack_timer() -> void:
	timer_multi_attack.wait_time = data.multi_attack_delay
	timer_multi_attack.start()

func attack() -> void:
	call(type_name + "_attack")
#	if auto_weakening_chance > 0:
#		if special_attack_count < 1:
#			special_attack_count += 1
#			if randf_range(0, 1) < auto_weakening_chance:
#				start_multi_attack_timer()
#				return
#
#		special_attack_count = 0
#
	attack_count += 1
	if attack_count < data.attacks:
		start_multi_attack_timer()
		return

	attack_count = 0
	start_cd_timer()
	
func set_damage_data(_data: DamageData) -> void:
	damage_data = _data
	
func set_data(_data: PlayerCellData) -> void:
	data = _data
#	match data.type:
#		PlayerCellData.Types.DRUID:
#			projectile_add_overwrite = {DamageData.Values.LIFE_TIME: 3}
#			projectile_sub_overwrite = {DamageData.Values.HP: 0}
			
	projectile_mod_data = ProjectileDataModifiers.new(
		weakened_dmg_mod, 
		weakening_chance, 
		ricohcet_if_weakened,
		reduce_cd_if_weakened,
		add_bullet_spd,
		projectile_add_overwrite,
		projectile_sub_overwrite,
		)
		
	panel.show()
	panel_not_active.hide()
	if data.type == 0:
		return
		
	pb_style.set("bg_color", data.color)
	type_name = PlayerCellData.Types.keys()[data.type].to_lower()
	timer_multi_attack.wait_time = data.multi_attack_delay
	if data.autoattack:
		attack()

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
	
func get_dir_to_rand_cell(pos: Vector2) -> Vector2:
	return pos.direction_to(G.cell_manager.get_rand_occupied_cell_global_center())

func reduce_cd_time(amount: float) -> void:
	var time_left: float = timer.time_left
	var new_time: float = time_left - amount
	if new_time <= 0.01:
		timer.stop()
		timer.timeout.emit()
		return
	
	timer.wait_time = new_time
	timer.start()
	
func add_dir_projectile(function: Callable) -> void:
	function.call(get_bullet_pos(), get_bullet_mult(), get_dir(get_bullet_pos()), projectile_mod_data, bonus_damage,self)
	
# shooter
##################################
func shooter_attack() -> void:
#	if special_attack_count == 1:
#		var init_chance: float = projectile_mod_data.weakening_chance
#		projectile_mod_data.weakening_chance = 1
#		projectile_manager.add_bullet(get_bullet_pos(), get_bullet_mult(), get_dir_to_rand_cell(get_bullet_pos()), projectile_mod_data, self)
#		projectile_mod_data.weakening_chance = init_chance
#		return
		
	add_dir_projectile(projectile_manager.add_bullet)
		
# rogue
##################################
func rogue_attack() -> void:
	add_dir_projectile(projectile_manager.add_knife)

# wizard
##################################
func wizard_attack() -> void:
	projectile_manager.add_magic(get_bullet_pos(), get_bullet_mult(), 
	G.cell_manager.get_cell_global_center(Vector2(10, randi_range(0, 7))), projectile_mod_data, self )

# druid
##################################
func druid_attack() -> void:
	add_dir_projectile(projectile_manager.add_druid_magic)
