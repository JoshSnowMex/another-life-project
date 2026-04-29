extends Node

var event_flags: Dictionary = {}

func has_flag(flag_id: String) -> bool:
	return bool(event_flags.get(flag_id, false))

func set_flag(flag_id: String, value: bool = true) -> void:
	event_flags[flag_id] = value

func clear_flag(flag_id: String) -> void:
	event_flags.erase(flag_id)

func reset_flags() -> void:
	event_flags.clear()

func get_all_flags() -> Dictionary:
	return event_flags.duplicate(true)

func load_flags(flags_data: Dictionary) -> void:
	event_flags = flags_data.duplicate(true)
