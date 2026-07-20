extends Control
class_name PlayerCell

const MAX_ACCURACY: int = 12
var data: PlayerCellData

# --- Per-tower combat modifiers (set by level-up / upgrades; not a Modifiers Resource yet) ---
# Shared
var cooldown_reduction: float = 0
var bonus_crit_chance: int = 0
var auto_aim: bool = false
var bonus_attacks: int = 0
var attack_effects: Array = []
var bonus_damage: Dictionary = {}
# Shooter
var weakened_dmg_mod: float = 0.4
var auto_weakening_chance: int = 0
var special_attack_count: int = 0 # runtime counter for auto-weaken burst
# Druid
var spawn_tree_on_overheal_chance: int = 0
var spawn_wood_to_the_right_chance: int = 0
var cell_lvlup_chance: int = 0
var reduce_cd_if_heal: float = 0
var weakening_chance: int = 0 # chance spawned-on-overheal wood starts weakened
var max_obelisks: int = 1
var obelisk_spawn_chance: int = 0
var obelisks: Array = []

var projectile_mod_data: ProjectileDataModifiers
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
var upgrade_path: Array = []
var applied_level_upgrades: Array = []
var attack_count: int = 0
var type_name: String
var xp: float = 0
var lvl: int = 0
var lvl_tokens: int = 0
var disabled: bool = false
@onready var upgrade_arrow: Polygon2D = $UpgradeArrow

var manager: PlayerCellManager
var projectile_manager: ProjectileManager


func _ready() -> void:
	set_physics_process(false)
	projectile_mod_data = ProjectileDataModifiers.new(weakened_dmg_mod)
		
	if !data:
		panel.hide()
		panel_not_active.show()
		progress_bar.hide()
		progress_bar.set("theme_override_styles/fill", pb_style)
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
		
	manager.tower_pressed.emit(self)


func add_xp() -> void:
	manager.xp_added.emit(self)


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
	if disabled:
		return
		
	call(type_name + "_attack")
	manager.cell_attacked.emit(self, attack_effects)
	if auto_weakening_chance > 0:
		if special_attack_count < 1:
			special_attack_count += 1
			if randi() % 100 < auto_weakening_chance:
				start_multi_attack_timer()
				return

		special_attack_count = 0

	attack_count += 1
	if attack_count < data.attacks + bonus_attacks:
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
	timer_multi_attack.wait_time = data.multi_attack_delay
	if data.autoattack:
		attack()

	progress_bar.show()
	set_process_unhandled_input(true)
	set_physics_process(true)


func reset_level_modifiers() -> void:
	cooldown_reduction = 0
	bonus_crit_chance = 0
	auto_aim = false
	bonus_attacks = 0
	attack_effects = []
	weakened_dmg_mod = 0.4
	auto_weakening_chance = 0
	special_attack_count = 0
	spawn_tree_on_overheal_chance = 0
	spawn_wood_to_the_right_chance = 0
	cell_lvlup_chance = 0
	reduce_cd_if_heal = 0
	weakening_chance = 0
	max_obelisks = 1
	obelisk_spawn_chance = 0
	obelisks = []
	upgrade_path = []
	applied_level_upgrades = []
	projectile_mod_data = ProjectileDataModifiers.new(weakened_dmg_mod)
	bonus_damage = DamageManager.new_damage_data(
		DamageManager.new_data(0, 0),
		DamageManager.new_data(0, 0)
	)


func _on_timeout() -> void:
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !data.autoattack:
		return
	
	attack()


func _on_multi_attack_timeout() -> void:
	attack()


func get_bullet_crit_chance() -> float:
	return data.crit_chance + bonus_crit_chance


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
	if auto_aim || data.autoattack:
		return get_dir_to_rand_cell()
	
	return get_attack_dir_to_mouse()


func get_dir_to_rand_cell() -> Vector2:
	return get_bullet_pos().direction_to(manager.cell_manager.get_rand_occupied_cell_global_center())


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
	function.call(get_bullet_pos(), get_bullet_crit_chance(), data.crit_mult, get_dir(get_bullet_pos()), projectile_mod_data, bonus_damage,self)


func shooter_attack() -> void:
	if special_attack_count == 1:
		var init_chance: int = projectile_mod_data.weakening_chance
		projectile_mod_data.weakening_chance = 100
		projectile_manager.add_bullet(get_bullet_pos(), get_bullet_crit_chance(), data.crit_mult, get_dir_to_rand_cell(), projectile_mod_data, bonus_damage, self)
		projectile_mod_data.weakening_chance = init_chance
		return
		
	add_dir_projectile(projectile_manager.add_bullet)


func rogue_attack() -> void:
	add_dir_projectile(projectile_manager.add_knife)


func wizard_attack() -> void:
	# Wizard / Magic projectile not implemented — data stub only; no production UI.
	if OS.is_debug_build():
		push_warning("WIP: wizard_attack stub (Magic projectile removed from registries)")


func druid_attack() -> void:
	add_dir_projectile(projectile_manager.add_druid_magic)


func executioner_attack() -> void:
	projectile_manager.add_greataxe(get_bullet_crit_chance(), data.crit_mult, projectile_mod_data, bonus_damage, self)
