extends CharacterBody2D

@export var npc_name: String = "Lyria"
@export var loved_gifts: Array[String] = ["joya"]
@export var liked_gifts: Array[String] = ["flor", "libro"]
@export var disliked_gifts: Array[String] = ["extrano"]

var affinity: int = 0
var mood: String = "neutral"
var interaction_count: int = 0
var has_received_gift_today: bool = false

func _ready() -> void:
	add_to_group("npcs")

func interact() -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")
	var text: String = ""

	interaction_count += 1

	if interaction_count == 1:
		update_mood_for_today()
		text = get_first_interaction_text()
	elif interaction_count == 2:
		var affinity_change: int = calculate_affinity_change()
		affinity += affinity_change
		affinity = clamp(affinity, -100, 100)
		update_mood_after_affinity_change(affinity_change)
		text = get_second_interaction_text(affinity_change)
	else:
		text = get_limit_text()
	
	print("Fuerza actual: ", PlayerStats.strength)
	dialogue_box.show_dialogue(npc_name, text)

func update_mood_for_today() -> void:
	var roll: int = randi_range(1, 100)
	var bias: int = get_affinity_bias()

	if roll + (bias * 10) >= 75:
		mood = "happy"
	elif roll + (bias * 10) <= 25:
		mood = "irritated"
	else:
		mood = "neutral"

func update_mood_after_affinity_change(affinity_change: int) -> void:
	if affinity_change > 1:
		mood = "happy"
	elif affinity_change < 0:
		mood = "irritated"

func get_first_interaction_text() -> String:
	if mood == "happy":
		return "Me alegra verte por aquí."
	elif mood == "irritated":
		return "No estoy de humor ahora mismo."
	else:
		return get_affinity_text()

func get_second_interaction_text(affinity_change: int) -> String:
	if affinity_change > 0:
		return "Supongo que hablar contigo no estuvo mal. Afinidad: " + str(affinity)
	elif affinity_change < 0:
		return "Te dije que no era un buen momento. Afinidad: " + str(affinity)
	else:
		return "No tengo mucho más que decir. Afinidad: " + str(affinity)

func get_limit_text() -> String:
	if mood == "irritated":
		return "Ya basta por hoy."
	elif mood == "happy":
		return "Hablemos luego, ¿sí?"
	else:
		return "Creo que ya hablamos suficiente por hoy."

func calculate_affinity_change() -> int:
	var mood_modifier: int = get_mood_modifier()
	var affinity_bias: int = get_affinity_bias()

	var luck_roll: int = randi_range(-2, 2)

	# NUEVO: influencia de stats del jugador
	var charisma_bonus: int = int(PlayerStats.charisma / 5)
	var luck_bonus: int = int(PlayerStats.luck / 5)

	var result: int = mood_modifier + affinity_bias + luck_roll + charisma_bonus + luck_bonus

	return clamp(result, -4, 4)

func get_mood_modifier() -> int:
	if mood == "happy":
		return 2
	elif mood == "irritated":
		return -2
	else:
		return 0

func get_affinity_bias() -> int:
	if affinity < -80:
		return -3
	elif affinity < -50:
		return -2
	elif affinity < -20:
		return -1
	elif affinity < 20:
		return 0
	elif affinity < 50:
		return 1
	elif affinity < 80:
		return 2
	else:
		return 3

func get_affinity_text() -> String:
	if affinity < -80:
		return "Te odio."
	elif affinity < -50:
		return "No te soporto."
	elif affinity < -20:
		return "No quiero hablar contigo."
	elif affinity < 0:
		return "¿Qué quieres ahora?"
	elif affinity < 20:
		return "No te conozco..."
	elif affinity < 50:
		return "Oh, eres tú otra vez."
	elif affinity < 80:
		return "Me agrada hablar contigo."
	else:
		return "Confío en ti."

func receive_gift(gift_type: String) -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")

	if has_received_gift_today:
		dialogue_box.show_dialogue(npc_name, "Ya me diste algo hoy.")
		return

	has_received_gift_today = true

	var affinity_change: int = calculate_gift_affinity_change(gift_type)
	affinity += affinity_change
	affinity = clamp(affinity, -100, 100)

	if affinity_change >= 6:
		mood = "happy"
	elif affinity_change < 0:
		mood = "irritated"
	else:
		mood = "neutral"

	dialogue_box.show_dialogue(npc_name, get_gift_response_text(gift_type, affinity_change))

func calculate_gift_affinity_change(gift_type: String) -> int:
	var base_change: int = 1

	if loved_gifts.has(gift_type):
		base_change = 12
	elif liked_gifts.has(gift_type):
		base_change = 6
	elif disliked_gifts.has(gift_type):
		base_change = -8

	var luck_modifier: int = int(PlayerStats.luck / 5)
	var result: int = base_change + luck_modifier

	return clamp(result, -12, 15)

func get_gift_response_text(gift_type: String, affinity_change: int) -> String:
	if affinity_change >= 10:
		return "¿Esto es para mí? Me encanta. Afinidad: " + str(affinity)
	elif affinity_change > 1:
		return "Gracias, me gusta. Afinidad: " + str(affinity)
	elif affinity_change == 1:
		return "Gracias... supongo. Afinidad: " + str(affinity)
	else:
		return "Esto no me gusta. Afinidad: " + str(affinity)

func reset_daily_interactions() -> void:
	interaction_count = 0
	has_received_gift_today = false
	
func can_receive_gift() -> bool:
	return not has_received_gift_today
