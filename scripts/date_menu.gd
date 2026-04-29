extends CanvasLayer

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var question_label: Label = $Panel/MarginContainer/VBoxContainer/QuestionLabel
@onready var options_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/OptionsContainer
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/CloseButton

var target_npc = null
var current_question: Dictionary = {}

func _ready() -> void:
	visible = false
	close_button.pressed.connect(close_menu)

func open_menu(npc) -> void:
	target_npc = npc
	current_question = DateQuestionSystem.get_available_question_for_npc(npc.npc_id)

	clear_options()

	if current_question.is_empty():
		title_label.text = npc.npc_name
		question_label.text = "No hay preguntas disponibles por ahora. Conoce mejor a este personaje o descubre más datos."
		close_button.visible = true
		visible = true
		return

	title_label.text = "Cita con " + npc.npc_name
	question_label.text = DateQuestionSystem.get_question_prompt(current_question)
	close_button.visible = true

	var options: Array = DateQuestionSystem.get_question_options(current_question)

	for option in options:
		add_option_button(str(option))

	visible = true

func close_menu() -> void:
	visible = false
	target_npc = null
	current_question = {}
	clear_options()

func clear_options() -> void:
	for child in options_container.get_children():
		child.queue_free()

func add_option_button(option_text: String) -> void:
	var button := Button.new()
	button.text = option_text
	button.custom_minimum_size = Vector2(260, 36)
	button.pressed.connect(func(): choose_answer(option_text))
	options_container.add_child(button)

func choose_answer(selected_answer: String) -> void:
	if current_question.is_empty():
		return

	var result: Dictionary = DateQuestionSystem.answer_question(current_question, selected_answer)
	clear_options()

	var result_text: String = str(result.get("text", ""))
	question_label.text = result_text
	current_question = {}
