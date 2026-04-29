extends Node

func get_stage_for_affinity(affinity: int) -> Dictionary:
	var stages: Dictionary = DialogueDatabase.get_relationship_stages()
	var best_stage_id: String = ""
	var best_stage_data: Dictionary = {}
	var best_min_affinity: int = -999999

	for stage_id in stages.keys():
		var stage_data: Dictionary = stages[stage_id]
		var min_affinity: int = int(stage_data.get("min_affinity", 0))

		if affinity >= min_affinity and min_affinity > best_min_affinity:
			best_stage_id = stage_id
			best_stage_data = stage_data.duplicate(true)
			best_min_affinity = min_affinity

	if best_stage_data.is_empty():
		return {
			"stage_id": "unknown",
			"display_name": "Desconocido",
			"min_affinity": 0,
			"description": "No hay información de relación."
		}

	best_stage_data["stage_id"] = best_stage_id
	return best_stage_data

func get_stage_for_npc(npc_id: String) -> Dictionary:
	var affinity: int = RelationshipSystem.get_affinity(npc_id)
	return get_stage_for_affinity(affinity)

func get_stage_display_name_for_npc(npc_id: String) -> String:
	var stage_data: Dictionary = get_stage_for_npc(npc_id)
	return str(stage_data.get("display_name", "Desconocido"))

func get_stage_description_for_npc(npc_id: String) -> String:
	var stage_data: Dictionary = get_stage_for_npc(npc_id)
	return str(stage_data.get("description", ""))
