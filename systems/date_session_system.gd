extends Node

var active_session: Dictionary = {}
var active_npc = null
var active_questions: Array[Dictionary] = []
var current_round_index: int = 0
var current_score: int = 0

func get_available_sessions_for_npc(npc_id: String) -> Array[Dictionary]:
	var sessions: Dictionary = DialogueDatabase.get_date_sessions_for_npc(npc_id)
	var available: Array[Dictionary] = []

	for session_id in sessions.keys():
		var session_data: Dictionary = sessions[session_id].duplicate(true)
		session_data["session_id"] = str(session_id)

		if can_session_be_used(session_data):
			available.append(session_data)

	available.sort_custom(func(a, b): return int(a.get("tier", 0)) < int(b.get("tier", 0)))
	return available

func can_session_be_used(session_data: Dictionary) -> bool:
	var npc_id: String = str(session_data.get("npc_id", ""))
	var required_affinity: int = int(session_data.get("required_affinity", 0))
	var affinity: int = RelationshipSystem.get_affinity(npc_id)

	if affinity < required_affinity:
		return false

	var success_flag: String = str(session_data.get("success_flag", ""))

	if success_flag != "" and EventSystem.has_flag(success_flag):
		return false

	var required_success_flags: Array = session_data.get("required_success_flags", [])

	for flag_id in required_success_flags:
		if not EventSystem.has_flag(str(flag_id)):
			return false

	var question_ids: Array = session_data.get("questions", [])

	for question_id in question_ids:
		var question_data: Dictionary = DialogueDatabase.get_date_question_data(str(question_id))

		if question_data.is_empty():
			continue

		if DateQuestionSystem.can_question_be_used_for_session(question_data):
			return true

	return false

func start_session(npc, session_id: String) -> Dictionary:
	var session_data: Dictionary = DialogueDatabase.get_date_session_data(session_id)

	if session_data.is_empty():
		return {
			"success": false,
			"text": "No se encontró la cita seleccionada."
		}

	session_data["session_id"] = session_id

	if not can_session_be_used(session_data):
		return {
			"success": false,
			"text": "Esta cita no está disponible todavía."
		}

	active_npc = npc
	active_session = session_data
	active_questions = build_session_questions(session_data)
	current_round_index = 0
	current_score = 0

	if active_questions.is_empty():
		clear_session()
		return {
			"success": false,
			"text": "No hay preguntas disponibles para esta cita."
		}

	return {
		"success": true,
		"text": str(session_data.get("intro_text", "La cita comienza."))
	}

func build_session_questions(session_data: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var valid_questions: Array[Dictionary] = []
	var question_ids: Array = session_data.get("questions", [])
	var rounds: int = int(session_data.get("rounds", 3))

	for question_id in question_ids:
		var question_data: Dictionary = DialogueDatabase.get_date_question_data(str(question_id))

		if question_data.is_empty():
			continue

		if DateQuestionSystem.can_question_be_used_for_session(question_data):
			valid_questions.append(question_data)

	if valid_questions.is_empty():
		return result

	for index in range(rounds):
		var selected_question: Dictionary = valid_questions[index % valid_questions.size()].duplicate(true)
		result.append(selected_question)

	return result

func has_active_session() -> bool:
	return not active_session.is_empty()

func get_current_question() -> Dictionary:
	if current_round_index < 0 or current_round_index >= active_questions.size():
		return {}

	return active_questions[current_round_index]

func answer_current_question(selected_answer: String) -> Dictionary:
	var question_data: Dictionary = get_current_question()

	if question_data.is_empty():
		return {
			"finished": true,
			"text": "La cita terminó inesperadamente."
		}

	var correct_answer: String = str(question_data.get("correct_answer", ""))
	var is_correct: bool = selected_answer == correct_answer

	if is_correct:
		current_score += 1

	var result_text: String = get_round_result_text(question_data, is_correct)

	current_round_index += 1

	if current_round_index >= active_questions.size():
		var final_result: Dictionary = finish_session()
		final_result["round_text"] = result_text
		final_result["finished"] = true
		return final_result

	return {
		"finished": false,
		"is_correct": is_correct,
		"text": result_text,
		"score": current_score,
		"round": current_round_index + 1,
		"total_rounds": active_questions.size()
	}

func get_round_result_text(question_data: Dictionary, is_correct: bool) -> String:
	var result_text: String = ""

	if is_correct:
		result_text = str(question_data.get("date_correct_text", question_data.get("correct_text", "La respuesta parece alegrarle.")))
	else:
		result_text = str(question_data.get("date_wrong_text", question_data.get("wrong_text", "La respuesta no parece convencerle.")))

	result_text = result_text.replace("{affinity}", "")
	result_text = result_text.replace("Afinidad: .", "")
	result_text = result_text.strip_edges()

	return result_text

func finish_session() -> Dictionary:
	var npc_id: String = str(active_session.get("npc_id", ""))
	var success_score: int = int(active_session.get("success_score", 2))
	var was_successful: bool = current_score >= success_score
	var affinity_change: int = int(active_session.get("failure_affinity_penalty", 0))
	var final_text: String = str(active_session.get("failure_text", "La cita no salió demasiado bien."))

	if was_successful:
		affinity_change = int(active_session.get("success_affinity_reward", 0))
		final_text = str(active_session.get("success_text", "La cita fue un éxito."))

	var new_affinity: int = RelationshipSystem.add_affinity(npc_id, affinity_change)

	if was_successful:
		var success_flag: String = str(active_session.get("success_flag", ""))

		if success_flag != "":
			EventSystem.set_flag(success_flag, true)

	var result: Dictionary = {
		"session_success": was_successful,
		"score": current_score,
		"total_rounds": active_questions.size(),
		"affinity_change": affinity_change,
		"new_affinity": new_affinity,
		"text": final_text + "\nResultado: " + str(current_score) + "/" + str(active_questions.size()) + ". Afinidad: " + str(new_affinity) + "."
	}

	clear_session()
	return result

func clear_session() -> void:
	active_session = {}
	active_npc = null
	active_questions.clear()
	current_round_index = 0
	current_score = 0

func get_session_display_name(session_data: Dictionary) -> String:
	var display_name: String = str(session_data.get("display_name", "Cita"))
	var location_name: String = str(session_data.get("location_name", ""))

	if location_name == "":
		return display_name

	return display_name + " - " + location_name

func get_session_lock_reason(npc_id: String) -> String:
	var affinity: int = RelationshipSystem.get_affinity(npc_id)

	if affinity < 20:
		return "Necesitas afinidad 20 para invitar a una cita."

	return "No hay citas disponibles. Completa citas previas o descubre más información."
