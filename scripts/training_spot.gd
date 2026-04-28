extends StaticBody2D

func interact() -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")

	if not PlayerStats.spend_energy(10):
		dialogue_box.show_dialogue("Sistema", "Estás demasiado cansado.")
		return

	var strength_gain: int = PlayerStats.gain_stat("strength", 3)
	var constitution_gain: int = PlayerStats.gain_stat("constitution", 2)

	var text: String = "Entrenaste duro.\n"
	text += "Fuerza +" + str(strength_gain) + "\n"
	text += "Constitución +" + str(constitution_gain)

	dialogue_box.show_dialogue("Entrenamiento", text)
