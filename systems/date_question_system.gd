extends Node

func get_available_question_for_npc(npc_id: String) -> Dictionary:
	var npc_questions: Dictionary = DialogueDatabase.get_date_questions_for_npc(npc_id)
	var available_questions: Array[Dictionary] = []

	for question_id in npc_questions.keys():
		var question_data: Dictionary = npc_questions[question_id].duplicate(true)
		question_data["question_id"] = str(question_id)

		if can_question_be_used(question_data):
			available_questions.append(question_data)

	if available_questions.is_empty():
		return {}

	return available_questions.pick_random()

func can_question_be_used(question_data: Dictionary) -> bool:
	var answered_flag: String = str(question_data.get("answered_flag", ""))

	if answered_flag != "" and EventSystem.has_flag(answered_flag):
		return false

	var npc_id: String = str(question_data.get("npc_id", ""))
	var required_fact_id: String = str(question_data.get("required_fact_id", ""))

	if required_fact_id != "":
		if npc_id == "":
			return false

		if not NpcKnowledgeSystem.is_fact_unlocked(npc_id, required_fact_id):
			return false

	return true

func can_question_be_used_for_session(question_data: Dictionary) -> bool:
	var npc_id: String = str(question_data.get("npc_id", ""))
	var required_fact_id: String = str(question_data.get("required_fact_id", ""))

	if required_fact_id != "":
		if npc_id == "":
			return false

		if not NpcKnowledgeSystem.is_fact_unlocked(npc_id, required_fact_id):
			return false

	return true
	
func answer_question(question_data: Dictionary, selected_answer: String) -> Dictionary:
	var npc_id: String = str(question_data.get("npc_id", ""))
	var correct_answer: String = str(question_data.get("correct_answer", ""))
	var is_correct: bool = selected_answer == correct_answer

	var affinity_change: int = int(question_data.get("affinity_penalty", 0))

	if is_correct:
		affinity_change = int(question_data.get("affinity_reward", 0))

	var new_affinity: int = RelationshipSystem.add_affinity(npc_id, affinity_change)

	mark_question_answered(question_data)

	var result_text: String = get_result_text(question_data, is_correct, new_affinity)

	return {
		"is_correct": is_correct,
		"npc_id": npc_id,
		"affinity_change": affinity_change,
		"new_affinity": new_affinity,
		"text": result_text
	}

func mark_question_answered(question_data: Dictionary) -> void:
	var answered_flag: String = str(question_data.get("answered_flag", ""))

	if answered_flag == "":
		return

	EventSystem.set_flag(answered_flag, true)

func get_result_text(question_data: Dictionary, is_correct: bool, new_affinity: int) -> String:
	var text_key: String = "wrong_text"

	if is_correct:
		text_key = "correct_text"

	var result_text: String = str(question_data.get(text_key, ""))

	if result_text == "":
		if is_correct:
			result_text = "Respuesta correcta. Afinidad: {affinity}."
		else:
			result_text = "Respuesta incorrecta. Afinidad: {affinity}."

	result_text = result_text.replace("{affinity}", str(new_affinity))
	return result_text

func get_question_prompt(question_data: Dictionary) -> String:
	return str(question_data.get("question", ""))

func get_question_options(question_data: Dictionary) -> Array:
	var options: Array = question_data.get("options", [])
	return options.duplicate(true)
