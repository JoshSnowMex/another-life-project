extends CanvasLayer

@onready var load_button: Button = $Panel/MarginContainer/VBoxContainer/LoadGameButton

func _ready() -> void:
	load_button.disabled = not SaveSystem.has_save_file()

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/life_path_selection.tscn")

func _on_load_game_button_pressed() -> void:
	if not SaveSystem.load_game_and_enter_world():
		load_button.disabled = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()
