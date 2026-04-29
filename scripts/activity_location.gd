extends StaticBody2D

@export var location_name: String = "Ubicación"
@export var primary_activity_id: String = ""
@export var work_activity_id: String = ""
@export var hybrid_activity_id: String = ""

func interact() -> void:
	var location_menu = get_tree().current_scene.get_node("LocationInteractionMenu")
	location_menu.open_menu(self)

func get_available_activities() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	if primary_activity_id != "":
		result.append({
			"label": get_activity_display_name(primary_activity_id),
			"activity_id": primary_activity_id
		})

	if work_activity_id != "":
		result.append({
			"label": get_activity_display_name(work_activity_id),
			"activity_id": work_activity_id
		})

	if hybrid_activity_id != "":
		result.append({
			"label": get_activity_display_name(hybrid_activity_id),
			"activity_id": hybrid_activity_id
		})

	return result

func get_activity_display_name(activity_id: String) -> String:
	var activity_data: Dictionary = DialogueDatabase.get_activity_data(activity_id)

	if activity_data.is_empty():
		return activity_id

	return str(activity_data.get("display_name", activity_id))
