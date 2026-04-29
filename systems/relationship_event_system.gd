extends Node

func get_available_event_for_npc(npc_id: String) -> Dictionary:
	var npc_events: Dictionary = DialogueDatabase.get_relationship_events_for_npc(npc_id)
	var current_affinity: int = RelationshipSystem.get_affinity(npc_id)

	var best_event: Dictionary = {}
	var best_required_affinity: int = -999999

	for event_id in npc_events.keys():
		var event_data: Dictionary = npc_events[event_id]

		if not can_event_trigger(event_data, current_affinity):
			continue

		var required_affinity: int = int(event_data.get("required_affinity", 0))

		if required_affinity > best_required_affinity:
			best_required_affinity = required_affinity
			best_event = event_data.duplicate(true)
			best_event["event_id"] = event_id

	return best_event

func can_event_trigger(event_data: Dictionary, current_affinity: int) -> bool:
	var required_affinity: int = int(event_data.get("required_affinity", 0))

	if current_affinity < required_affinity:
		return false

	var flag_id: String = str(event_data.get("flag_id", ""))

	if flag_id == "":
		return false

	if EventSystem.has_flag(flag_id):
		return false

	return true

func mark_event_seen(event_data: Dictionary) -> void:
	var flag_id: String = str(event_data.get("flag_id", ""))

	if flag_id == "":
		return

	EventSystem.set_flag(flag_id, true)

func get_event_text(event_data: Dictionary) -> String:
	return str(event_data.get("text", ""))

func get_event_title(event_data: Dictionary) -> String:
	return str(event_data.get("title", "Evento"))
