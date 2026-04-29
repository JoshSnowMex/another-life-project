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

	var stat_gain: int = apply_stat_reward(activity_data)
	var money_gain: int = apply_money_reward(activity_data)

	var success_text: String = str(activity_data.get("success_text", "Actividad completada."))
	success_text = format_activity_text(success_text, stat_gain, money_gain)

	return create_result(true, speaker_name, success_text)

func apply_stat_reward(activity_data: Dictionary) -> int:
	var stat_name: String = str(activity_data.get("stat", ""))

	if stat_name == "":
		return 0

	var base_gain: int = int(activity_data.get("base_gain", 0))

	if base_gain <= 0:
		return 0

	return PlayerStats.gain_stat(stat_name, base_gain)

func apply_money_reward(activity_data: Dictionary) -> int:
	var base_money: int = int(activity_data.get("money_gain", 0))

	if base_money <= 0:
		return 0

	var money_stat: String = str(activity_data.get("money_stat", ""))

	if money_stat == "":
		PlayerStats.add_money(base_money)
		return base_money

	var final_money: int = PlayerStats.calculate_money_gain(money_stat, base_money)
	PlayerStats.add_money(final_money)
	return final_money

func format_activity_text(text: String, gained_amount: int, money_gain: int) -> String:
	var result: String = text
	result = result.replace("{gain}", str(gained_amount))
	result = result.replace("{money}", str(money_gain))
	result = result.replace("{energy}", str(PlayerStats.current_energy))
	result = result.replace("{total_money}", str(PlayerStats.money))
	return result

func create_result(success: bool, speaker_name: String, text: String) -> Dictionary:
	return {
		"success": success,
		"speaker_name": speaker_name,
		"text": text
	}
