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

func show_current_step() -> void:
	clear_options()

	var step: Dictionary = DateSessionSystem.get_current_step()

	if step.is_empty():
		question_label.text = "No hay más pasos."
		add_close_result_button()
		return

	var step_number: int = DateSessionSystem.get_current_step_number()
	var total_steps: int = DateSessionSystem.get_total_steps()
	var step_type: String = str(step.get("type", ""))

	title_label.text = "Cita con " + target_npc.npc_name + " | Paso " + str(step_number) + "/" + str(total_steps)

	match step_type:
		"dialogue":
			show_dialogue_step(step)
		"question":
			show_question_step(step)
		"gift":
			show_gift_step(step)
		"action":
			show_action_step(step)
		_:
			question_label.text = "Paso desconocido."
			add_continue_button()

func show_dialogue_step(step: Dictionary) -> void:
	question_label.text = str(step.get("text", ""))
	add_step_continue_button()

func show_question_step(step: Dictionary) -> void:
	var question_id: String = str(step.get("question_id", ""))
	var question_data: Dictionary = DialogueDatabase.get_date_question_data(question_id)

	if question_data.is_empty():
		question_label.text = "Esta pregunta no está disponible."
		add_step_continue_button()
		return

	question_label.text = DateQuestionSystem.get_question_prompt(question_data)

	var options: Array = DateQuestionSystem.get_question_options(question_data)

	for option in options:
		add_option_button(str(option))

func show_gift_step(step: Dictionary) -> void:
	question_label.text = str(step.get("prompt", "¿Quieres dar un regalo?"))
	add_gift_buttons()
	add_skip_gift_button()

func show_action_step(step: Dictionary) -> void:
	var action_id: String = str(step.get("action_id", ""))
	var action_data: Dictionary = DialogueDatabase.get_date_action_data(action_id)

	if action_data.is_empty():
		question_label.text = "Esta acción no está disponible."
		add_step_continue_button()
		return

	var display_name: String = str(action_data.get("display_name", action_id))
	var min_score: int = int(action_data.get("min_score", 0))

	question_label.text = display_name + "\nRequiere ambiente de cita: " + str(min_score) + "\nAmbiente actual: " + str(DateSessionSystem.current_score)
	add_action_button(display_name)

func add_continue_button() -> void:
	var button := Button.new()
	button.text = "Continuar"
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(show_current_step)
	options_container.add_child(button)

func add_step_continue_button() -> void:
	var button := Button.new()
	button.text = "Continuar"
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(resolve_dialogue_step)
	options_container.add_child(button)

func resolve_dialogue_step() -> void:
	var result: Dictionary = DateSessionSystem.advance_dialogue_step()
	show_step_result(result)

func add_option_button(option_text: String) -> void:
	var button := Button.new()
	button.text = option_text
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(func(): choose_answer(option_text))
	options_container.add_child(button)

func choose_answer(selected_answer: String) -> void:
	var result: Dictionary = DateSessionSystem.answer_question_step(selected_answer)
	show_step_result(result)

func add_gift_buttons() -> void:
	var gift_items: Dictionary = DialogueDatabase.get_gift_items()

	for gift_type in gift_items.keys():
		var amount: int = PlayerStats.get_item_count(gift_type)

		if amount <= 0:
			continue

		var display_name: String = DialogueDatabase.get_item_display_name(gift_type)
		var button := Button.new()
		button.text = display_name + " x" + str(amount)
		button.custom_minimum_size = Vector2(260, 36)
		button.pressed.connect(func(): choose_gift(str(gift_type)))
		options_container.add_child(button)

func add_skip_gift_button() -> void:
	var button := Button.new()
	button.text = "No dar regalo"
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(skip_gift)
	options_container.add_child(button)

func choose_gift(gift_type: String) -> void:
	var result: Dictionary = DateSessionSystem.use_gift_step(gift_type)
	show_step_result(result)

func skip_gift() -> void:
	var result: Dictionary = DateSessionSystem.skip_gift_step()
	show_step_result(result)

func add_action_button(label: String) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(resolve_action_step)
	options_container.add_child(button)

func resolve_action_step() -> void:
	var result: Dictionary = DateSessionSystem.perform_action_step()
	show_step_result(result)

func show_step_result(result: Dictionary) -> void:
	clear_options()
	question_label.text = str(result.get("text", ""))

	if bool(result.get("finished", false)):
		add_close_result_button()
	else:
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
