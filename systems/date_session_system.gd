extends Node

var active_session: Dictionary = {}
var active_npc = null
var active_steps: Array[Dictionary] = []
var current_step_index: int = 0
var current_score: int = 0
var gift_used: bool = false

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

	var steps: Array = session_data.get("steps", [])

	if steps.is_empty():
		return false

	return has_at_least_one_usable_step(steps)

func has_at_least_one_usable_step(steps: Array) -> bool:
	for raw_step in steps:
		var step: Dictionary = raw_step

		if can_step_be_used(step):
			return true

	return false

func can_step_be_used(step: Dictionary) -> bool:
	var step_type: String = str(step.get("type", ""))

	match step_type:
		"dialogue":
			return true
		"gift":
			return true
		"action":
			var action_id: String = str(step.get("action_id", ""))
			return not DialogueDatabase.get_date_action_data(action_id).is_empty()
		"question":
			var question_id: String = str(step.get("question_id", ""))
			var question_data: Dictionary = DialogueDatabase.get_date_question_data(question_id)

			if question_data.is_empty():
				return false

			return DateQuestionSystem.can_question_be_used_for_session(question_data)

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
	active_steps = build_session_steps(session_data)
	current_step_index = 0
	current_score = 0
	gift_used = false

	if active_steps.is_empty():
		clear_session()
		return {
			"success": false,
			"text": "No hay pasos disponibles para esta cita."
		}

	return {
		"success": true,
		"text": str(session_data.get("intro_text", "La cita comienza."))
	}

func build_session_steps(session_data: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var steps: Array = session_data.get("steps", [])

	for raw_step in steps:
		var step: Dictionary = raw_step.duplicate(true)

		if not can_step_be_used(step):
			continue

		result.append(step)

	return result

func has_active_session() -> bool:
	return not active_session.is_empty()

func get_current_step() -> Dictionary:
	if current_step_index < 0 or current_step_index >= active_steps.size():
		return {}

	return active_steps[current_step_index]

func get_current_step_number() -> int:
	return current_step_index + 1

func get_total_steps() -> int:
	return active_steps.size()

func advance_dialogue_step() -> Dictionary:
	var step: Dictionary = get_current_step()

	if step.is_empty():
		return finish_session_with_wrapper("")

	current_step_index += 1

	if current_step_index >= active_steps.size():
		return finish_session_with_wrapper(str(step.get("text", "")))

	return {
		"finished": false,
		"text": str(step.get("text", "")),
		"continue_to_next": true
	}

func answer_question_step(selected_answer: String) -> Dictionary:
	var step: Dictionary = get_current_step()
	var question_id: String = str(step.get("question_id", ""))
	var question_data: Dictionary = DialogueDatabase.get_date_question_data(question_id)

	if question_data.is_empty():
		current_step_index += 1
		return {
			"finished": false,
			"text": "La pregunta no está disponible."
		}

	var correct_answer: String = str(question_data.get("correct_answer", ""))
	var is_correct: bool = selected_answer == correct_answer

	if is_correct:
		current_score += int(step.get("success_score", 1))
	else:
		current_score += int(step.get("failure_score", 0))

	var result_text: String = DateQuestionSystem.get_result_text_for_session(question_data, is_correct)

	current_step_index += 1

	if current_step_index >= active_steps.size():
		return finish_session_with_wrapper(result_text)

	return {
		"finished": false,
		"text": result_text,
		"score": current_score
	}

func use_gift_step(gift_type: String) -> Dictionary:
	var step: Dictionary = get_current_step()

	if gift_used:
		return {
			"finished": false,
			"text": "Ya diste un regalo durante esta cita."
		}

	if active_npc == null:
		return {
			"finished": false,
			"text": "No hay NPC para recibir el regalo."
		}

	if not PlayerStats.remove_item(gift_type):
		return {
			"finished": false,
			"text": "No tienes ese regalo."
		}

	gift_used = true

	var score_change: int = calculate_gift_score(step, gift_type)
	current_score += score_change

	var gift_display_name: String = DialogueDatabase.get_item_display_name(gift_type)
	var result_text: String = get_gift_result_text(gift_type, score_change)
	result_text = "Diste: " + gift_display_name + ".\n" + result_text

	if active_npc.has_method("unlock_gift_knowledge"):
		active_npc.unlock_gift_knowledge(gift_type, score_change)

	current_step_index += 1

	if current_step_index >= active_steps.size():
		return finish_session_with_wrapper(result_text)

	return {
		"finished": false,
		"text": result_text,
		"score": current_score
	}

func skip_gift_step() -> Dictionary:
	var result_text: String = "Decidiste no dar ningún regalo en este momento."

	current_step_index += 1

	if current_step_index >= active_steps.size():
		return finish_session_with_wrapper(result_text)

	return {
		"finished": false,
		"text": result_text,
		"score": current_score
	}

func calculate_gift_score(step: Dictionary, gift_type: String) -> int:
	if active_npc == null:
		return int(step.get("neutral_score", 0))

	if not "gift_preferences" in active_npc:
		return int(step.get("neutral_score", 0))

	var preferences: Dictionary = active_npc.gift_preferences

	if preferences.has("loved") and gift_type in preferences["loved"]:
		return int(step.get("success_score", 2))

	if preferences.has("liked") and gift_type in preferences["liked"]:
		return int(step.get("success_score", 2))

	if preferences.has("disliked") and gift_type in preferences["disliked"]:
		return int(step.get("failure_score", -1))

	return int(step.get("neutral_score", 0))

func get_gift_result_text(gift_type: String, score_change: int) -> String:
	if score_change > 0:
		return "El regalo parece mejorar el ambiente de la cita."

	if score_change < 0:
		return "El regalo no fue bien recibido."

	return "El regalo fue aceptado, aunque no cambió demasiado el ambiente."

func perform_action_step() -> Dictionary:
	var step: Dictionary = get_current_step()
	var action_id: String = str(step.get("action_id", ""))
	var action_data: Dictionary = DialogueDatabase.get_date_action_data(action_id)

	if action_data.is_empty():
		current_step_index += 1
		return {
			"finished": false,
			"text": "La acción no está disponible."
		}

	var min_score: int = int(action_data.get("min_score", 0))
	var result_text: String = ""
	var score_change: int = 0

	if current_score >= min_score:
		score_change = int(action_data.get("success_score", 1))
		result_text = str(action_data.get("success_text", "La acción salió bien."))
	else:
		score_change = int(action_data.get("failure_score", -1))
		result_text = str(action_data.get("failure_text", "La acción no salió bien."))

	current_score += score_change
	current_step_index += 1

	if current_step_index >= active_steps.size():
		return finish_session_with_wrapper(result_text)

	return {
		"finished": false,
		"text": result_text,
		"score": current_score
	}

func finish_session_with_wrapper(previous_text: String) -> Dictionary:
	var final_result: Dictionary = finish_session()

	if previous_text != "":
		final_result["text"] = previous_text + "\n\n" + str(final_result.get("text", ""))

	final_result["finished"] = true
	return final_result

func finish_session() -> Dictionary:
	var npc_id: String = str(active_session.get("npc_id", ""))
	var success_score: int = int(active_session.get("success_score", 4))
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
		"success_score": success_score,
		"affinity_change": affinity_change,
		"new_affinity": new_affinity,
		"text": final_text + "\nResultado: " + str(current_score) + "/" + str(success_score) + ". Afinidad: " + str(new_affinity) + "."
	}

	clear_session()
	return result

func clear_session() -> void:
	active_session = {}
	active_npc = null
	active_steps.clear()
	current_step_index = 0
	current_score = 0
	gift_used = false

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
