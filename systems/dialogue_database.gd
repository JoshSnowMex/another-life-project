extends Node

const NPC_PERSONALITY_DIALOGUES_PATH: String = "res://data/npc_personality_dialogues.json"
const NPC_PROFILES_PATH: String = "res://data/npcs.json"
const ITEMS_PATH: String = "res://data/items.json"
const RELATIONSHIP_EVENTS_PATH: String = "res://data/relationship_events.json"
const RELATIONSHIP_STAGES_PATH: String = "res://data/relationship_stages.json"
const NPC_KNOWLEDGE_PATH: String = "res://data/npc_knowledge.json"
const ACTIVITIES_PATH: String = "res://data/activities.json"
const DATE_QUESTIONS_PATH: String = "res://data/date_questions.json"
const SHOP_ITEMS_PATH: String = "res://data/shop_items.json"
const DATE_SESSIONS_PATH: String = "res://data/date_sessions.json"
const DATE_ACTIONS_PATH: String = "res://data/date_actions.json"
const DATE_TALKS_PATH: String = "res://data/date_talks.json"

var npc_personality_dialogues: Dictionary = {}
var npc_profiles: Dictionary = {}
var items: Dictionary = {}
var relationship_events: Dictionary = {}
var relationship_stages: Dictionary = {}
var npc_knowledge: Dictionary = {}
var activities: Dictionary = {}
var date_questions: Dictionary = {}
var shop_items: Dictionary = {}
var date_sessions: Dictionary = {}
var date_actions: Dictionary = {}
var date_talks: Dictionary = {}

func _ready() -> void:
	load_all_data()

func load_all_data() -> void:
	load_npc_personality_dialogues()
	load_npc_profiles()
	load_items()
	load_relationship_events()
	load_relationship_stages()
	load_npc_knowledge()
	load_activities()
	load_date_questions()
	load_shop_items()
	load_date_sessions()
	load_date_actions()
	load_date_talks()

func load_npc_personality_dialogues() -> void:
	npc_personality_dialogues = load_json_file(NPC_PERSONALITY_DIALOGUES_PATH)

func load_npc_profiles() -> void:
	npc_profiles = load_json_file(NPC_PROFILES_PATH)

func load_items() -> void:
	items = load_json_file(ITEMS_PATH)

func load_relationship_events() -> void:
	relationship_events = load_json_file(RELATIONSHIP_EVENTS_PATH)
	
func load_relationship_stages() -> void:
	relationship_stages = load_json_file(RELATIONSHIP_STAGES_PATH)

func load_npc_knowledge() -> void:
	npc_knowledge = load_json_file(NPC_KNOWLEDGE_PATH)

func load_activities() -> void:
	activities = load_json_file(ACTIVITIES_PATH)
	
func load_date_questions() -> void:
	date_questions = load_json_file(DATE_QUESTIONS_PATH)

func load_shop_items() -> void:
	shop_items = load_json_file(SHOP_ITEMS_PATH)
	
func load_date_sessions() -> void:
	date_sessions = load_json_file(DATE_SESSIONS_PATH)
	
func load_date_actions() -> void:
	date_actions = load_json_file(DATE_ACTIONS_PATH)

func load_date_talks() -> void:
	date_talks = load_json_file(DATE_TALKS_PATH)

func load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("No existe el archivo JSON: " + path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("No se pudo abrir el archivo JSON: " + path)
		return {}

	var text: String = file.get_as_text()
	var parsed = JSON.parse_string(text)

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("El JSON no tiene formato de Dictionary: " + path)
		return {}

	return parsed

func get_npc_profile(npc_id: String) -> Dictionary:
	if not npc_profiles.has(npc_id):
		push_error("No existe perfil para npc_id: " + npc_id)
		return {}

	return npc_profiles[npc_id]

func get_npc_personality_dialogue(personality: String, context: String) -> String:
	if not npc_personality_dialogues.has(personality):
		return ""

	var personality_dialogues: Dictionary = npc_personality_dialogues[personality]

	if not personality_dialogues.has(context):
		return ""

	var options: Array = personality_dialogues[context]

	if options.is_empty():
		return ""

	return options.pick_random()

func get_item_data(item_id: String) -> Dictionary:
	if not items.has(item_id):
		return {}

	return items[item_id]

func get_item_display_name(item_id: String) -> String:
	var item_data: Dictionary = get_item_data(item_id)

	if item_data.is_empty():
		return item_id

	return item_data.get("display_name", item_id)

func get_items_by_type(item_type: String) -> Dictionary:
	var result: Dictionary = {}

	for item_id in items.keys():
		var item_data: Dictionary = items[item_id]

		if item_data.get("type", "") == item_type:
			result[item_id] = item_data

	return result

func get_gift_items() -> Dictionary:
	return get_items_by_type("gift")

func get_starting_inventory() -> Dictionary:
	var result: Dictionary = {}

	for item_id in items.keys():
		var item_data: Dictionary = items[item_id]
		var starting_amount: int = int(item_data.get("starting_amount", 0))

		if starting_amount > 0:
			result[item_id] = starting_amount

	return result

func get_relationship_events() -> Dictionary:
	return relationship_events.duplicate(true)

func get_relationship_events_for_npc(npc_id: String) -> Dictionary:
	var result: Dictionary = {}

	for event_id in relationship_events.keys():
		var event_data: Dictionary = relationship_events[event_id]

		if str(event_data.get("npc_id", "")) == npc_id:
			result[event_id] = event_data

	return result

func get_relationship_stages() -> Dictionary:
	return relationship_stages.duplicate(true)

func get_npc_knowledge() -> Dictionary:
	return npc_knowledge.duplicate(true)

func get_npc_knowledge_data(npc_id: String) -> Dictionary:
	if not npc_knowledge.has(npc_id):
		return {}

	return npc_knowledge[npc_id].duplicate(true)

func get_activity_data(activity_id: String) -> Dictionary:
	if not activities.has(activity_id):
		push_error("No existe actividad con id: " + activity_id)
		return {}

	return activities[activity_id].duplicate(true)

func get_activities() -> Dictionary:
	return activities.duplicate(true)

func get_date_questions() -> Dictionary:
	return date_questions.duplicate(true)

func get_date_questions_for_npc(npc_id: String) -> Dictionary:
	var result: Dictionary = {}

	for question_id in date_questions.keys():
		var question_data: Dictionary = date_questions[question_id]

		if str(question_data.get("npc_id", "")) == npc_id:
			result[question_id] = question_data

	return result

func get_shop_items() -> Dictionary:
	return shop_items.duplicate(true)

func get_shop_item_data(shop_item_id: String) -> Dictionary:
	if not shop_items.has(shop_item_id):
		return {}

	return shop_items[shop_item_id].duplicate(true)

func get_date_sessions() -> Dictionary:
	return date_sessions.duplicate(true)

func get_date_sessions_for_npc(npc_id: String) -> Dictionary:
	var result: Dictionary = {}

	for session_id in date_sessions.keys():
		var session_data: Dictionary = date_sessions[session_id]

		if str(session_data.get("npc_id", "")) == npc_id:
			result[session_id] = session_data

	return result

func get_date_session_data(session_id: String) -> Dictionary:
	if not date_sessions.has(session_id):
		return {}

	return date_sessions[session_id].duplicate(true)

func get_date_question_data(question_id: String) -> Dictionary:
	var questions: Dictionary = get_date_questions()

	if not questions.has(question_id):
		return {}

	var question_data: Dictionary = questions[question_id].duplicate(true)
	question_data["question_id"] = question_id
	return question_data

func get_date_actions() -> Dictionary:
	return date_actions.duplicate(true)

func get_date_action_data(action_id: String) -> Dictionary:
	if not date_actions.has(action_id):
		return {}

	var action_data: Dictionary = date_actions[action_id].duplicate(true)
	action_data["action_id"] = action_id
	return action_data

func get_date_talk_data(talk_id: String) -> Dictionary:
	if not date_talks.has(talk_id):
		return {}

	var talk_data: Dictionary = date_talks[talk_id].duplicate(true)
	talk_data["talk_id"] = talk_id
	return talk_data
