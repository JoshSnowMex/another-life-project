extends CanvasLayer

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var options_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/OptionsContainer
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/CloseButton

var current_location = null

func _ready() -> void:
	visible = false
	close_button.pressed.connect(close_menu)

func open_menu(location) -> void:
	current_location = location
	visible = true
	title_label.text = location.location_name

	refresh_options()

func close_menu() -> void:
	visible = false
	current_location = null
	clear_options()

func refresh_options() -> void:
	clear_options()

	if current_location == null:
		return

	var activities: Array[Dictionary] = current_location.get_available_activities()

	if activities.is_empty():
		add_disabled_label("No hay acciones disponibles.")
		return

	for activity_entry in activities:
		var label: String = str(activity_entry.get("label", "Actividad"))
		var activity_id: String = str(activity_entry.get("activity_id", ""))

		if activity_id == "":
			continue

		add_activity_button(label, activity_id)

func clear_options() -> void:
	for child in options_container.get_children():
		child.queue_free()

func add_activity_button(label: String, activity_id: String) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(func(): perform_activity(activity_id))
	options_container.add_child(button)

func add_disabled_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	options_container.add_child(label)

func perform_activity(activity_id: String) -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")
	var result: Dictionary = ActivitySystem.perform_activity(activity_id)

	var speaker_name: String = str(result.get("speaker_name", "Actividad"))
	var text: String = str(result.get("text", ""))

	close_menu()
	dialogue_box.show_dialogue(speaker_name, text)


func _on_close_button_pressed() -> void:
	pass # Replace with function body.
