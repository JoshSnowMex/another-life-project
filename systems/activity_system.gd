extends Node

func perform_activity(activity_id: String) -> Dictionary:
	var activity_data: Dictionary = DialogueDatabase.get_activity_data(activity_id)

	if activity_data.is_empty():
		return create_result(false, "Sistema", "Actividad no encontrada.")

	var energy_cost: int = int(activity_data.get("energy_cost", 0))
	var speaker_name: String = str(activity_data.get("speaker_name", activity_data.get("display_name", "Actividad")))

	if not PlayerStats.spend_energy(energy_cost):
		var not_enough_energy_text: String = str(activity_data.get("not_enough_energy_text", "No tienes suficiente energía."))
		return create_result(false, speaker_name, not_enough_energy_text)

	var stat_name: String = str(activity_data.get("stat", ""))
	var base_gain: int = int(activity_data.get("base_gain", 1))
	var gained_amount: int = PlayerStats.gain_stat(stat_name, base_gain)

	var success_text: String = str(activity_data.get("success_text", "Actividad completada."))
	success_text = format_activity_text(success_text, gained_amount)

	return create_result(true, speaker_name, success_text)

func format_activity_text(text: String, gained_amount: int) -> String:
	var result: String = text
	result = result.replace("{gain}", str(gained_amount))
	result = result.replace("{energy}", str(PlayerStats.current_energy))
	return result

func create_result(success: bool, speaker_name: String, text: String) -> Dictionary:
	return {
		"success": success,
		"speaker_name": speaker_name,
		"text": text
	}
