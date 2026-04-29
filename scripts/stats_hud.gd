extends CanvasLayer

@onready var stats_label: Label = $StatsPanel/StatsLabel

func _process(_delta: float) -> void:
	stats_label.text = get_stats_text()

func get_stats_text() -> String:
	var text: String = ""

	text += "Energía: " + str(PlayerStats.current_energy) + " / " + str(PlayerStats.max_energy) + "\n"
	text += "Fuerza: " + str(PlayerStats.strength) + "\n"
	text += "Inteligencia: " + str(PlayerStats.intelligence) + "\n"
	text += "Destreza: " + str(PlayerStats.dexterity) + "\n"
	text += "Carisma: " + str(PlayerStats.charisma) + "\n"
	text += "Constitución: " + str(PlayerStats.constitution) + "\n"
	text += "Suerte: " + str(PlayerStats.luck) + "\n" +"\n"
	text += "Dinero: " + str(PlayerStats.money) + "\n"
	text += "Camino de Vida: " + PlayerStats.life_path

	return text
