extends Node

func mark_npc_met(npc_id: String) -> void:
	EventSystem.set_flag(get_met_flag_id(npc_id), true)

func has_met_npc(npc_id: String) -> bool:
	return EventSystem.has_flag(get_met_flag_id(npc_id))

func get_met_flag_id(npc_id: String) -> String:
	return "met_" + npc_id

func unlock_fact(npc_id: String, fact_id: String) -> void:
	var fact_data: Dictionary = get_fact_data(npc_id, fact_id)

	if fact_data.is_empty():
		return

	var unlock_flag: String = str(fact_data.get("unlock_flag", ""))

	if unlock_flag == "":
		return

	EventSystem.set_flag(unlock_flag, true)

func is_fact_unlocked(npc_id: String, fact_id: String) -> bool:
	var fact_data: Dictionary = get_fact_data(npc_id, fact_id)

	if fact_data.is_empty():
		return false

	var unlock_flag: String = str(fact_data.get("unlock_flag", ""))

	if unlock_flag == "":
		return false

	return EventSystem.has_flag(unlock_flag)

func get_known_npcs() -> Array[String]:
	var result: Array[String] = []
	var all_knowledge: Dictionary = DialogueDatabase.get_npc_knowledge()

	for npc_id in all_knowledge.keys():
		if has_met_npc(str(npc_id)):
			result.append(str(npc_id))

	return result

func get_profile_data(npc_id: String) -> Dictionary:
	var npc_data: Dictionary = DialogueDatabase.get_npc_knowledge_data(npc_id)

	if npc_data.is_empty():
		return {}

	return npc_data.get("profile", {})

func get_fact_data(npc_id: String, fact_id: String) -> Dictionary:
	var npc_data: Dictionary = DialogueDatabase.get_npc_knowledge_data(npc_id)

	if npc_data.is_empty():
		return {}

	var facts: Dictionary = npc_data.get("facts", {})

	if not facts.has(fact_id):
		return {}

	return facts[fact_id]

func get_known_facts(npc_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var npc_data: Dictionary = DialogueDatabase.get_npc_knowledge_data(npc_id)

	if npc_data.is_empty():
		return result

	var facts: Dictionary = npc_data.get("facts", {})

	for fact_id in facts.keys():
		if not is_fact_unlocked(npc_id, str(fact_id)):
			continue

		var fact_data: Dictionary = facts[fact_id].duplicate(true)
		fact_data["fact_id"] = str(fact_id)
		result.append(fact_data)

	return result
