extends CanvasLayer

const MAIN_MENU_SCENE_PATH: String = "res://scenes/ui/main_menu.tscn"

@onready var load_button: Button = $Panel/MarginContainer/VBoxContainer/LoadButton

func _ready() -> void:
	visible = false
	refresh_buttons()

func refresh_buttons() -> void:
	load_button.disabled = not SaveSystem.has_save_file()

func open_menu() -> void:
	refresh_buttons()
	visible = true

func close_menu() -> void:
	visible = false

func toggle_menu() -> void:
	if visible:
		close_menu()
	else:
		open_menu()

func _on_continue_button_pressed() -> void:
	close_menu()

func _on_save_button_pressed() -> void:
	if SaveSystem.save_game():
		print("Partida guardada desde menú de pausa.")
	refresh_buttons()

func _on_load_button_pressed() -> void:
	if SaveSystem.load_game():
		print("Partida cargada desde menú de pausa.")
	close_menu()

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
