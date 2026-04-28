extends Node

var relationships: Dictionary = {}

func ensure_npc_state(npc_id: String) -> void:
	if relationships.has(npc_id):
		return

	relationships[npc_id] = {
		"affinity": 0,
		"mood": GameConstants.MOOD_NEUTRAL,
		"interaction_count": 0,
		"has_received_gift_today": false
	}

func get_npc_state(npc_id: String) -> Dictionary:
	ensure_npc_state(npc_id)
	return relationships[npc_id]

func get_affinity(npc_id: String) -> int:
	var state: Dictionary = get_npc_state(npc_id)
	return int(state.get("affinity", 0))

func set_affinity(npc_id: String, value: int) -> void:
	var state: Dictionary = get_npc_state(npc_id)
	state["affinity"] = clamp(value, -100, 100)

func add_affinity(npc_id: String, amount: int) -> int:
	var new_value: int = get_affinity(npc_id) + amount
	set_affinity(npc_id, new_value)
	return get_affinity(npc_id)

func get_mood(npc_id: String) -> String:
	var state: Dictionary = get_npc_state(npc_id)
	return str(state.get("mood", GameConstants.MOOD_NEUTRAL))

func set_mood(npc_id: String, value: String) -> void:
	var state: Dictionary = get_npc_state(npc_id)
	state["mood"] = value

func get_interaction_count(npc_id: String) -> int:
	var state: Dictionary = get_npc_state(npc_id)
	return int(state.get("interaction_count", 0))

func increment_interaction_count(npc_id: String) -> int:
	var state: Dictionary = get_npc_state(npc_id)
	var new_count: int = int(state.get("interaction_count", 0)) + 1
	state["interaction_count"] = new_count
	return new_count

func has_received_gift_today(npc_id: String) -> bool:
	var state: Dictionary = get_npc_state(npc_id)
	return bool(state.get("has_received_gift_today", false))

func mark_gift_received_today(npc_id: String) -> void:
	var state: Dictionary = get_npc_state(npc_id)
	state["has_received_gift_today"] = true

func reset_daily_state() -> void:
	for npc_id in relationships.keys():
		var state: Dictionary = relationships[npc_id]
		state["interaction_count"] = 0
		state["has_received_gift_today"] = false
