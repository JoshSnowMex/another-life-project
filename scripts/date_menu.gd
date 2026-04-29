extends CanvasLayer

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var question_label: Label = $Panel/MarginContainer/VBoxContainer/QuestionLabel
@onready var options_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/OptionsContainer
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/CloseButton

var target_npc = null
var selected_session_id: String = ""

func _ready() -> void:
	visible = false
	close_button.pressed.connect(close_menu)

func open_menu(npc) -> void:
	target_npc = npc
	selected_session_id = ""
	visible = true
	show_available_sessions()

func close_menu() -> void:
	visible = false
	target_npc = null
	selected_session_id = ""
	DateSessionSystem.clear_session()
	clear_options()

func show_available_sessions() -> void:
	clear_options()

	if target_npc == null:
		title_label.text = "Cita"
		question_label.text = "No hay NPC seleccionado."
		return

	title_label.text = "Invitar a " + target_npc.npc_name
	var sessions: Array[Dictionary] = DateSessionSystem.get_available_sessions_for_npc(target_npc.npc_id)

	if sessions.is_empty():
		question_label.text = DateSessionSystem.get_session_lock_reason(target_npc.npc_id)
		return

	question_label.text = "Elige una cita disponible."

	for session_data in sessions:
		var session_id: String = str(session_data.get("session_id", ""))
		var label: String = DateSessionSystem.get_session_display_name(session_data)
		add_session_button(label, session_id)

func add_session_button(label: String, session_id: String) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(320, 36)
	button.pressed.connect(func(): start_selected_session(session_id))
	options_container.add_child(button)

func start_selected_session(session_id: String) -> void:
	if target_npc == null:
		return

	selected_session_id = session_id
	var start_result: Dictionary = DateSessionSystem.start_session(target_npc, session_id)

	clear_options()

	if not bool(start_result.get("success", false)):
		question_label.text = str(start_result.get("text", "No se pudo iniciar la cita."))
		return

	title_label.text = "Cita con " + target_npc.npc_name
	question_label.text = str(start_result.get("text", "La cita comienza."))
	add_continue_to_date_menu_button()

func show_date_action_menu() -> void:
	clear_options()

	if target_npc == null or not DateSessionSystem.has_active_session():
		title_label.text = "Cita"
		question_label.text = "No hay cita activa."
		add_close_result_button()
		return

	title_label.text = "Cita con " + target_npc.npc_name
	question_label.text = DateSessionSystem.get_status_text()

	add_action_menu_button("Charlar", start_talk, not DateSessionSystem.can_talk())
	add_action_menu_button("Dar regalo", show_gift_options, not DateSessionSystem.can_gift())
	add_action_menu_button("Movimiento", show_action_options, not DateSessionSystem.can_action())
	add_action_menu_button("Terminar cita", finish_date, false)

func add_action_menu_button(label: String, callback: Callable, disabled: bool = false) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(300, 36)
	button.disabled = disabled
	button.pressed.connect(callback)
	options_container.add_child(button)

func add_continue_to_date_menu_button() -> void:
	var button := Button.new()
	button.text = "Continuar"
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(show_date_action_menu)
	options_container.add_child(button)

func start_talk() -> void:
	var result: Dictionary = DateSessionSystem.perform_talk()
	clear_options()

	if bool(result.get("requires_answer", false)):
		question_label.text = str(result.get("text", ""))
		var options: Array = result.get("options", [])

		for option in options:
			add_question_option_button(str(option))

		return

	show_action_result(result)

func add_question_option_button(option_text: String) -> void:
	var button := Button.new()
	button.text = option_text
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(func(): answer_question(option_text))
	options_container.add_child(button)

func answer_question(selected_answer: String) -> void:
	var result: Dictionary = DateSessionSystem.answer_pending_question(selected_answer)
	show_action_result(result)

func show_gift_options() -> void:
	clear_options()
	title_label.text = "Dar regalo"
	question_label.text = "Elige un regalo. Regalos usados: " + str(DateSessionSystem.gifts_used) + "/" + str(int(DateSessionSystem.active_session.get("max_gifts", 2)))

	var gift_items: Dictionary = DialogueDatabase.get_gift_items()
	var has_any_gift: bool = false

	for gift_type in gift_items.keys():
		var amount: int = PlayerStats.get_item_count(gift_type)

		if amount <= 0:
			continue

		has_any_gift = true
		var display_name: String = DialogueDatabase.get_item_display_name(gift_type)
		var button := Button.new()
		button.text = display_name + " x" + str(amount)
		button.custom_minimum_size = Vector2(280, 36)
		button.pressed.connect(func(): choose_gift(str(gift_type)))
		options_container.add_child(button)

	if not has_any_gift:
		question_label.text = "No tienes regalos disponibles."

	add_action_menu_button("Volver", show_date_action_menu, false)

func choose_gift(gift_type: String) -> void:
	var result: Dictionary = DateSessionSystem.use_gift(gift_type)
	show_action_result(result)

func show_action_options() -> void:
	clear_options()
	title_label.text = "Movimiento"
	question_label.text = "Elige un movimiento. Solo puedes intentar uno por cita.\n" + DateSessionSystem.get_status_text()

	var actions: Array[Dictionary] = DateSessionSystem.get_available_actions()

	if actions.is_empty():
		question_label.text = "No hay movimientos disponibles para esta cita."
		add_action_menu_button("Volver", show_date_action_menu, false)
		return

	for action_data in actions:
		var action_id: String = str(action_data.get("action_id", ""))
		var display_name: String = str(action_data.get("display_name", action_id))
		var min_score: int = int(action_data.get("min_score", 0))

		var button := Button.new()
		button.text = display_name + " | requiere progreso " + str(min_score)
		button.custom_minimum_size = Vector2(320, 36)
		button.pressed.connect(func(): choose_action(action_id))
		options_container.add_child(button)

	add_action_menu_button("Volver", show_date_action_menu, false)

func choose_action(action_id: String) -> void:
	var result: Dictionary = DateSessionSystem.perform_action(action_id)
	show_action_result(result)

func show_action_result(result: Dictionary) -> void:
	clear_options()
	question_label.text = str(result.get("text", ""))

	if bool(result.get("finished", false)):
		add_close_result_button()
	else:
		add_continue_to_date_menu_button()

func finish_date() -> void:
	var result: Dictionary = DateSessionSystem.finish_session()
	show_action_result(result)

func add_close_result_button() -> void:
	var button := Button.new()
	button.text = "Cerrar"
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(close_menu)
	options_container.add_child(button)

func clear_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
