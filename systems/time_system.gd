extends Node

var current_day: int = 1

func next_day() -> void:
	current_day += 1

	restore_player()
	reset_npcs()

func restore_player() -> void:
	PlayerStats.current_energy = PlayerStats.max_energy

func reset_npcs() -> void:
	var npcs = get_tree().get_nodes_in_group("npcs")

	for npc in npcs:
		if npc.has_method("reset_daily_interactions"):
			npc.reset_daily_interactions()
