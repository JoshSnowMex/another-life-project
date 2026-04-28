extends StaticBody2D

func interact() -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")

	if not PlayerStats.spend_energy(8):
		dialogue_box.show_dialogue("Biblioteca", "Estás demasiado cansado para estudiar.")
		return

	var intelligence_gain: int = PlayerStats.gain_stat("intelligence", 3)
	var luck_gain: int = PlayerStats.gain_stat("luck", 1)

	var text: String = "Estudiaste antiguos textos de Lyndrall.\n"
	text += "Inteligencia +" + str(intelligence_gain) + "\n"
	text += "Suerte +" + str(luck_gain)

	dialogue_box.show_dialogue("Biblioteca", text)
