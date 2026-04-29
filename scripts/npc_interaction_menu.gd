extends CanvasLayer

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var options_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/OptionsContainer
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/CloseButton

var current_npc = null

func _ready() -> void:
	visible = false
	close_button.pressed.connect(close_menu)

func open_menu(npc) -> void:
	current_npc = npc
	visible = true
	title_label.text = npc.npc_name
	refresh_options()

func close_menu() -> void:
	visible = false
	current_npc = null
	clear_options()

func refresh_options() -> void:
	clear_options()

	if current_npc == null:
		add_disabled_label("No hay personaje seleccionado.")
		return

	add_action_button("Hablar", func(): talk_to_npc())
	add_action_button("Regalar", func(): open_gift_menu())
	add_action_button(get_date_button_text(), func(): open_date_menu(), not can_open_date_menu())

func clear_options() -> void:
	for child in options_container.get_children():
		child.queue_free()

func add_action_button(label: String, callback: Callable, disabled: bool = false) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(260, 36)
	button.disabled = disabled
	button.pressed.connect(callback)
	options_container.add_child(button)

func add_disabled_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	options_container.add_child(label)

func talk_to_npc() -> void:
	if current_npc == null:
		return

	var npc = current_npc
	close_menu()
	npc.interact()

func open_gift_menu() -> void:
	if current_npc == null:
		return

	var npc = current_npc
	var gift_menu = get_tree().current_scene.get_node("GiftMenu")

	close_menu()
	gift_menu.open_menu(npc)

func open_date_menu() -> void:
	if current_npc == null:
		return

	var npc = current_npc
	var date_menu = get_tree().current_scene.get_node("DateMenu")

	close_menu()
	date_menu.open_menu(npc)

func can_open_date_menu() -> bool:
	if current_npc == null:
		return false

	var npc_id: String = str(current_npc.npc_id)
	var sessions: Array[Dictionary] = DateSessionSystem.get_available_sessions_for_npc(npc_id)

	return not sessions.is_empty()

func get_date_button_text() -> String:
	if current_npc == null:
		return "Cita"

	var npc_id: String = str(current_npc.npc_id)
	var affinity: int = RelationshipSystem.get_affinity(npc_id)

	if affinity < 20:
		return "Cita - requiere afinidad 20"

	var sessions: Array[Dictionary] = DateSessionSystem.get_available_sessions_for_npc(npc_id)

	if sessions.is_empty():
		return "Cita - sin citas disponibles"

	return "Cita"


func _on_close_button_pressed() -> void:
	pass # Replace with function body.
