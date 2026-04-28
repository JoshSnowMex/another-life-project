extends Node

var current_day: int = 1

func next_day() -> void:
	current_day += 1

	restore_player()
	RelationshipSystem.reset_daily_state()

func restore_player() -> void:
	PlayerStats.current_energy = PlayerStats.max_energy
