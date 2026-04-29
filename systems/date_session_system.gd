extends Node

var active_session: Dictionary = {}
var active_npc = null

var current_score: int = 0
var talks_used: int = 0
var gifts_used: int = 0
var actions_used: int = 0

var pending_question: Dictionary = {}
var waiting_for_question_answer: bool = false

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

	return true

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
	current_score = 0
	talks_used = 0
	gifts_used = 0
	actions_used = 0
	pending_question = {}
	waiting_for_question_answer = false

	return {
		"success": true,
		"text": str(session_data.get("intro_text", "La cita comienza."))
	}

func has_active_session() -> bool:
	return not active_session.is_empty()

func get_status_text() -> String:
	if active_session.is_empty():
		return ""

	var max_score: int = int(active_session.get("max_score", 10))
	var success_score: int = int(active_session.get("success_score", 8))
	var max_talks: int = int(active_session.get("max_talks", 5))
	var max_gifts: int = int(active_session.get("max_gifts", 2))
	var max_actions: int = int(active_session.get("max_actions", 1))

	var progress_percent: int = int(round((float(current_score) / float(max_score)) * 100.0))
	var success_percent: int = int(round((float(success_score) / float(max_score)) * 100.0))

	return "Calidad de la cita: " + str(progress_percent) + "% | Éxito: " + str(success_percent) + "%\nCharlar: " + str(talks_used) + "/" + str(max_talks) + " | Regalos: " + str(gifts_used) + "/" + str(max_gifts) + " | Movimiento: " + str(actions_used) + "/" + str(max_actions)

func can_talk() -> bool:
	if active_session.is_empty():
		return false

	return talks_used < int(active_session.get("max_talks", 5))

func can_gift() -> bool:
	if active_session.is_empty():
		return false

	return gifts_used < int(active_session.get("max_gifts", 2))

func can_action() -> bool:
	if active_session.is_empty():
		return false

	return actions_used < int(active_session.get("max_actions", 1))

func perform_talk() -> Dictionary:
	if not can_talk():
		return create_action_result("Ya no hay mucho más que conversar en esta cita.")

	talks_used += 1

	if should_trigger_question():
		var question_data: Dictionary = get_available_question_for_session()

		if not question_data.is_empty():
			pending_question = question_data
			waiting_for_question_answer = true

			return {
				"requires_answer": true,
				"text": DateQuestionSystem.get_question_prompt(question_data),
				"options": DateQuestionSystem.get_question_options(question_data)
			}

	var talk_data: Dictionary = get_random_talk()
	var score_gain: int = int(talk_data.get("score", 1))
	current_score = clamp(current_score + score_gain, -99, int(active_session.get("max_score", 10)))

	var text: String = str(talk_data.get("text", "La conversación fluye de forma tranquila."))
	text += "\nProgreso +" + str(score_gain) + "."

	return create_action_result(text)

func should_trigger_question() -> bool:
	var chance: int = int(active_session.get("question_chance", 40))
	var question_data: Dictionary = get_available_question_for_session()

	if question_data.is_empty():
		return false

	return randi_range(1, 100) <= chance

func get_available_question_for_session() -> Dictionary:
	var question_pool: Array = active_session.get("question_pool", [])
	var available: Array[Dictionary] = []

	for question_id in question_pool:
		var question_data: Dictionary = DialogueDatabase.get_date_question_data(str(question_id))

		if question_data.is_empty():
			continue

		if DateQuestionSystem.can_question_be_used_for_session(question_data):
			available.append(question_data)

	if available.is_empty():
		return {}

	return available.pick_random()

func answer_pending_question(selected_answer: String) -> Dictionary:
	if not waiting_for_question_answer or pending_question.is_empty():
		return create_action_result("No hay pregunta pendiente.")

	var correct_answer: String = str(pending_question.get("correct_answer", ""))
	var is_correct: bool = selected_answer == correct_answer

	var score_change: int = -1

	if is_correct:
		score_change = 2

	current_score = clamp(current_score + score_change, -99, int(active_session.get("max_score", 10)))

	var text: String = DateQuestionSystem.get_result_text_for_session(pending_question, is_correct)

	if is_correct:
		text += "\nProgreso +2."
	else:
		text += "\nProgreso -1."

	pending_question = {}
	waiting_for_question_answer = false

	return create_action_result(text)

func get_random_talk() -> Dictionary:
	var talk_pool: Array = active_session.get("talk_pool", [])
	var valid_talks: Array[Dictionary] = []

	for talk_id in talk_pool:
		var talk_data: Dictionary = DialogueDatabase.get_date_talk_data(str(talk_id))

		if talk_data.is_empty():
			continue

		valid_talks.append(talk_data)

	if valid_talks.is_empty():
		return {
			"text": "La conversación fluye de forma tranquila.",
			"score": 1
		}

	return valid_talks.pick_random()

func use_gift(gift_type: String) -> Dictionary:
	if not can_gift():
		return create_action_result("Ya diste todos los regalos posibles durante esta cita.")

	if active_npc == null:
		return create_action_result("No hay NPC para recibir el regalo.")

	if not PlayerStats.remove_item(gift_type):
		return create_action_result("No tienes ese regalo.")

	gifts_used += 1

	var score_change: int = calculate_date_gift_score(gift_type)
	current_score = clamp(current_score + score_change, -99, int(active_session.get("max_score", 10)))

	if active_npc.has_method("unlock_gift_knowledge"):
		active_npc.unlock_gift_knowledge(gift_type, score_change)

	var display_name: String = DialogueDatabase.get_item_display_name(gift_type)
	var text: String = "Diste: " + display_name + ".\n" + get_gift_result_text(score_change)

	if score_change > 0:
		text += "\nProgreso +" + str(score_change) + "."
	elif score_change < 0:
		text += "\nProgreso " + str(score_change) + "."
	else:
		text += "\nProgreso sin cambios."

	return create_action_result(text)

func calculate_date_gift_score(gift_type: String) -> int:
	if active_npc == null:
		return 0

	if not active_npc.has_method("get_gift_preference_level"):
		return 0

	var preference_level: String = active_npc.get_gift_preference_level(gift_type)

	match preference_level:
		"loved":
			return 3
		"liked":
			return 2
		"neutral":
			return 0
		"disliked":
			return -3

	return 0

func get_gift_result_text(score_change: int) -> String:
	if score_change >= 3:
		return "El regalo fue excelente. El ambiente mejora mucho."

	if score_change > 0:
		return "El regalo fue bien recibido."

	if score_change < 0:
		return "El regalo no fue bien recibido."

	return "El regalo fue aceptado, aunque no cambió demasiado el ambiente."

func get_available_actions() -> Array[Dictionary]:
	var action_pool: Array = active_session.get("action_pool", [])
	var result: Array[Dictionary] = []
	var tier: int = int(active_session.get("tier", 20))
	var npc_id: String = str(active_session.get("npc_id", ""))
	var affinity: int = RelationshipSystem.get_affinity(npc_id)

	for action_id in action_pool:
		var action_data: Dictionary = DialogueDatabase.get_date_action_data(str(action_id))

		if action_data.is_empty():
			continue

		var min_tier: int = int(action_data.get("min_tier", 20))
		var min_affinity: int = int(action_data.get("min_affinity", 0))

		if tier < min_tier:
			continue

		if affinity < min_affinity:
			continue

		result.append(action_data)

	return result

func perform_action(action_id: String) -> Dictionary:
	if not can_action():
		return create_action_result("Ya intentaste un movimiento durante esta cita.")

	var action_data: Dictionary = DialogueDatabase.get_date_action_data(action_id)

	if action_data.is_empty():
		return create_action_result("Esa acción no está disponible.")

	actions_used += 1

	var min_score: int = int(action_data.get("min_score", 0))
	var score_change: int = 0
	var text: String = ""

	if current_score >= min_score:
		score_change = int(action_data.get("success_score", 1))
		text = str(action_data.get("success_text", "La acción salió bien."))
	else:
		score_change = int(action_data.get("failure_score", -1))
		text = str(action_data.get("failure_text", "La acción no salió bien."))

	current_score = clamp(current_score + score_change, -99, int(active_session.get("max_score", 10)))

	if score_change > 0:
		text += "\nProgreso +" + str(score_change) + "."
	elif score_change < 0:
		text += "\nProgreso " + str(score_change) + "."
	else:
		text += "\nProgreso sin cambios."

	return create_action_result(text)

func finish_session() -> Dictionary:
	if active_session.is_empty():
		return {
			"text": "No hay cita activa.",
			"finished": true
		}

	var npc_id: String = str(active_session.get("npc_id", ""))
	var success_score: int = int(active_session.get("success_score", 8))
	var was_successful: bool = current_score >= success_score

	var affinity_change: int = int(active_session.get("failure_affinity_penalty", -3))
	var final_text: String = str(active_session.get("failure_text", "La cita no salió demasiado bien."))

	if was_successful:
		affinity_change = int(active_session.get("success_affinity_reward", 8))
		final_text = str(active_session.get("success_text", "La cita fue un éxito."))

	var new_affinity: int = RelationshipSystem.add_affinity(npc_id, affinity_change)

	if was_successful:
		var success_flag: String = str(active_session.get("success_flag", ""))

		if success_flag != "":
			EventSystem.set_flag(success_flag, true)

	var max_score: int = int(active_session.get("max_score", 10))
	var progress_percent: int = int(round((float(current_score) / float(max_score)) * 100.0))
	var success_percent: int = int(round((float(success_score) / float(max_score)) * 100.0))

	var result_text: String = final_text + "\nCalidad final: " + str(progress_percent) + "% / Éxito requerido: " + str(success_percent) + "%. Afinidad: " + str(new_affinity) + "."

	clear_session()

	return {
		"text": result_text,
		"finished": true,
		"session_success": was_successful
	}

func create_action_result(text: String) -> Dictionary:
	return {
		"text": text,
		"finished": false
	}

func clear_session() -> void:
	active_session = {}
	active_npc = null
	current_score = 0
	talks_used = 0
	gifts_used = 0
	actions_used = 0
	pending_question = {}
	waiting_for_question_answer = false

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
