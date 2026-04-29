extends StaticBody2D

@export var activity_id: String = "train_strength"

func interact() -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")
	var result: Dictionary = ActivitySystem.perform_activity(activity_id)

	var speaker_name: String = str(result.get("speaker_name", "Actividad"))
	var text: String = str(result.get("text", ""))

	dialogue_box.show_dialogue(speaker_name, text)
