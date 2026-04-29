extends CharacterBody2D

@export var npc_id: String = "lyria"

var npc_name: String = ""
var personality: String = GameConstants.PERSONALITY_AMABLE

var loved_gifts: Array[String] = []
var liked_gifts: Array[String] = []
var disliked_gifts: Array[String] = []

func _ready() -> void:
	load_profile()
	RelationshipSystem.ensure_npc_state(npc_id)
	add_to_group("npcs")
	
func load_profile() -> void:
	var profile: Dictionary = DialogueDatabase.get_npc_profile(npc_id)

	if profile.is_empty():
		npc_name = npc_id
		personality = GameConstants.PERSONALITY_AMABLE
		loved_gifts = []
		liked_gifts = []
		disliked_gifts = []
		return

	npc_name = profile.get("display_name", npc_id)
	personality = profile.get("personality", GameConstants.PERSONALITY_AMABLE)

	loved_gifts = array_to_string_array(profile.get("loved_gifts", []))
	liked_gifts = array_to_string_array(profile.get("liked_gifts", []))
	disliked_gifts = array_to_string_array(profile.get("disliked_gifts", []))
	
func array_to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []

	if typeof(value) != TYPE_ARRAY:
		return result

	for item in value:
		result.append(str(item))

	return result

func interact() -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")
	NpcKnowledgeSystem.mark_npc_met(npc_id)

	var relationship_event: Dictionary = RelationshipEventSystem.get_available_event_for_npc(npc_id)

	if not relationship_event.is_empty():
		var event_text: String = RelationshipEventSystem.get_event_text(relationship_event)
		RelationshipEventSystem.mark_event_seen(relationship_event)
		dialogue_box.show_dialogue(npc_name, event_text)
		return

	var text: String = ""
	var interaction_count: int = RelationshipSystem.increment_interaction_count(npc_id)

	if interaction_count == 1:
		update_mood_for_today()
		text = get_first_interaction_text()
	elif interaction_count == 2:
		var affinity_change: int = calculate_affinity_change()
		var new_affinity: int = RelationshipSystem.add_affinity(npc_id, affinity_change)
		update_mood_after_affinity_change(affinity_change)
		text = get_second_interaction_text(affinity_change, new_affinity)
	else:
		text = get_limit_text()
	
	dialogue_box.show_dialogue(npc_name, text)
	
func calculate_affinity_change() -> int:
	var mood_modifier: int = get_mood_modifier()
	var affinity_bias: int = get_affinity_bias()
	var personality_modifier: int = get_personality_affinity_modifier()

	var luck_roll: int = randi_range(-2, 2)

	var charisma_bonus: int = int(PlayerStats.charisma / 5)
	var luck_bonus: int = int(PlayerStats.luck / 5)

	var result: int = mood_modifier + affinity_bias + personality_modifier + luck_roll + charisma_bonus + luck_bonus

	return clamp(result, -5, 5)
	
func update_mood_for_today() -> void:
	var roll: int = randi_range(1, 100)
	var bias: int = get_affinity_bias()
	var personality_modifier: int = get_personality_mood_modifier()

	var final_roll: int = roll + (bias * 10) + personality_modifier

	if final_roll >= 75:
		RelationshipSystem.set_mood(npc_id, GameConstants.MOOD_HAPPY)
	elif final_roll <= 25:
		RelationshipSystem.set_mood(npc_id, GameConstants.MOOD_IRRITATED)
	else:
		RelationshipSystem.set_mood(npc_id, GameConstants.MOOD_NEUTRAL)
		
func get_personality_mood_modifier() -> int:
	match personality:
		GameConstants.PERSONALITY_AMABLE:
			return 10
		GameConstants.PERSONALITY_GRUNON:
			return -10
		GameConstants.PERSONALITY_IMPREDECIBLE:
			return randi_range(-20, 20)

	return 0

func update_mood_after_affinity_change(affinity_change: int) -> void:
	if affinity_change > 1:
		RelationshipSystem.set_mood(npc_id, GameConstants.MOOD_HAPPY)
	elif affinity_change < 0:
		RelationshipSystem.set_mood(npc_id, GameConstants.MOOD_IRRITATED)
		
func get_personality_dialogue(context: String) -> String:
	return DialogueDatabase.get_npc_personality_dialogue(personality, context)
	
func get_first_interaction_text() -> String:
	var mood: String = RelationshipSystem.get_mood(npc_id)

	if mood == GameConstants.MOOD_HAPPY:
		var dialogue: String = get_personality_dialogue(GameConstants.DIALOGUE_FIRST_HAPPY)
		if dialogue != "":
			return dialogue
		return "Me alegra verte por aquí."

	elif mood == GameConstants.MOOD_IRRITATED:
		var dialogue: String = get_personality_dialogue(GameConstants.DIALOGUE_FIRST_IRRITATED)
		if dialogue != "":
			return dialogue
		return "No estoy de humor ahora mismo."

	return get_affinity_text()

func get_second_interaction_text(affinity_change: int, current_affinity: int) -> String:
	var dialogue: String = ""

	if affinity_change > 0:
		dialogue = get_personality_dialogue(GameConstants.DIALOGUE_SECOND_POSITIVE)
		if dialogue == "":
			dialogue = "Supongo que hablar contigo no estuvo mal."

	elif affinity_change < 0:
		dialogue = get_personality_dialogue(GameConstants.DIALOGUE_SECOND_NEGATIVE)
		if dialogue == "":
			dialogue = "Te dije que no era un buen momento."

	else:
		dialogue = get_personality_dialogue(GameConstants.DIALOGUE_SECOND_NEUTRAL)
		if dialogue == "":
			dialogue = "No tengo mucho más que decir."

	return dialogue + " Afinidad: " + str(current_affinity)

func get_limit_text() -> String:
	var dialogue: String = ""
	var mood: String = RelationshipSystem.get_mood(npc_id)

	if mood == GameConstants.MOOD_IRRITATED:
		dialogue = get_personality_dialogue(GameConstants.DIALOGUE_LIMIT_IRRITATED)
		if dialogue == "":
			dialogue = "Ya basta por hoy."

	elif mood == GameConstants.MOOD_HAPPY:
		dialogue = get_personality_dialogue(GameConstants.DIALOGUE_LIMIT_HAPPY)
		if dialogue == "":
			dialogue = "Hablemos luego, ¿sí?"

	else:
		dialogue = get_personality_dialogue(GameConstants.DIALOGUE_LIMIT_NEUTRAL)
		if dialogue == "":
			dialogue = "Creo que ya hablamos suficiente por hoy."

	return dialogue
	
func get_gift_already_received_text() -> String:
	var dialogue: String = get_personality_dialogue(GameConstants.DIALOGUE_GIFT_ALREADY_RECEIVED)

	if dialogue != "":
		return dialogue

	return "Ya me diste algo hoy."
	
func get_personality_affinity_modifier() -> int:
	match personality:
		GameConstants.PERSONALITY_AMABLE:
			return 1
		GameConstants.PERSONALITY_GRUNON:
			return -1
		GameConstants.PERSONALITY_IMPREDECIBLE:
			return randi_range(-2, 2)

	return 0

func get_mood_modifier() -> int:
	var mood: String = RelationshipSystem.get_mood(npc_id)

	if mood == GameConstants.MOOD_HAPPY:
		return 2
	elif mood == GameConstants.MOOD_IRRITATED:
		return -2
	else:
		return 0

func get_affinity_bias() -> int:
	var affinity: int = RelationshipSystem.get_affinity(npc_id)

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
	var affinity: int = RelationshipSystem.get_affinity(npc_id)

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

	if RelationshipSystem.has_received_gift_today(npc_id):
		dialogue_box.show_dialogue(npc_name, get_gift_already_received_text())
		return

	RelationshipSystem.mark_gift_received_today(npc_id)

	var affinity_change: int = calculate_gift_affinity_change(gift_type)
	unlock_gift_knowledge(gift_type, affinity_change)
	var new_affinity: int = RelationshipSystem.add_affinity(npc_id, affinity_change)

	if affinity_change >= 6:
		RelationshipSystem.set_mood(npc_id, GameConstants.MOOD_HAPPY)
	elif affinity_change < 0:
		RelationshipSystem.set_mood(npc_id, GameConstants.MOOD_IRRITATED)
	else:
		RelationshipSystem.set_mood(npc_id, GameConstants.MOOD_NEUTRAL)

	dialogue_box.show_dialogue(npc_name, get_gift_response_text(affinity_change, new_affinity))

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

func get_gift_response_text(affinity_change: int, current_affinity: int) -> String:
	var dialogue_context: String = get_gift_dialogue_context(affinity_change)
	var dialogue: String = get_personality_dialogue(dialogue_context)

	if dialogue == "":
		dialogue = get_default_gift_response_text(affinity_change)

	return dialogue + " Afinidad: " + str(current_affinity)

func get_gift_dialogue_context(affinity_change: int) -> String:
	if affinity_change >= 10:
		return GameConstants.DIALOGUE_GIFT_LOVED
	elif affinity_change > 1:
		return GameConstants.DIALOGUE_GIFT_LIKED
	elif affinity_change == 1:
		return GameConstants.DIALOGUE_GIFT_NEUTRAL
	else:
		return GameConstants.DIALOGUE_GIFT_DISLIKED

func get_default_gift_response_text(affinity_change: int) -> String:
	if affinity_change >= 10:
		return "¿Esto es para mí? Me encanta."
	elif affinity_change > 1:
		return "Gracias, me gusta."
	elif affinity_change == 1:
		return "Gracias... supongo."
	else:
		return "Esto no me gusta."

func can_receive_gift() -> bool:
	return not RelationshipSystem.has_received_gift_today(npc_id)

func unlock_gift_knowledge(gift_type: String, affinity_change: int) -> void:
	if loved_gifts.has(gift_type):
		NpcKnowledgeSystem.unlock_fact(npc_id, "loved_gift_" + gift_type)
	elif liked_gifts.has(gift_type):
		NpcKnowledgeSystem.unlock_fact(npc_id, "liked_gift_" + gift_type)
	elif disliked_gifts.has(gift_type):
		NpcKnowledgeSystem.unlock_fact(npc_id, "disliked_gift_" + gift_type)
