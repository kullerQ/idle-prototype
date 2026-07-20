extends Control

const MAIN_SCENE: String = "res://scenes/main/main.tscn"

@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var new_game_button: Button = $VBoxContainer/NewGameButton


func _ready() -> void:
	continue_button.disabled = !SaveService.has_save()
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)


func _on_new_game_pressed() -> void:
	SaveService.delete_save()
	RunState.clear_pending()
	get_tree().change_scene_to_file(MAIN_SCENE)


func _on_continue_pressed() -> void:
	var loaded: Dictionary = SaveService.load_from_file()
	if loaded.is_empty():
		continue_button.disabled = true
		return
	RunState.set_pending(RunState.from_dict(loaded))
	get_tree().change_scene_to_file(MAIN_SCENE)
