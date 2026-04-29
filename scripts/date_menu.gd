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
	add_continue_button()

func add_continue_button() -> void:
	var button := Button.new()
	button.text = "Continuar"
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(show_current_question)
	options_container.add_child(button)

func show_current_question() -> void:
	clear_options()

	var question_data: Dictionary = DateSessionSystem.get_current_question()

	if question_data.is_empty():
		question_label.text = "No hay más preguntas."
		add_close_result_button()
		return

	var round_number: int = DateSessionSystem.current_round_index + 1
	var total_rounds: int = DateSessionSystem.active_questions.size()

	question_label.text = "Ronda " + str(round_number) + "/" + str(total_rounds) + "\n" + DateQuestionSystem.get_question_prompt(question_data)

	var options: Array = DateQuestionSystem.get_question_options(question_data)

	for option in options:
		add_option_button(str(option))

func add_option_button(option_text: String) -> void:
	var button := Button.new()
	button.text = option_text
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(func(): choose_answer(option_text))
	options_container.add_child(button)

func choose_answer(selected_answer: String) -> void:
	var result: Dictionary = DateSessionSystem.answer_current_question(selected_answer)
	clear_options()

	var text: String = str(result.get("text", ""))

	if bool(result.get("finished", false)):
		var round_text: String = str(result.get("round_text", ""))

		if round_text != "":
			question_label.text = round_text + "\n\n" + text
		else:
			question_label.text = text

		add_close_result_button()
		return

	question_label.text = text
	add_continue_button()

func add_close_result_button() -> void:
	var button := Button.new()
	button.text = "Cerrar"
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(close_menu)
	options_container.add_child(button)

func clear_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
