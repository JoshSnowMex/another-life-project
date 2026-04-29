extends Node

const NPC_PERSONALITY_DIALOGUES_PATH: String = "res://data/npc_personality_dialogues.json"
const NPC_PROFILES_PATH: String = "res://data/npcs.json"
const ITEMS_PATH: String = "res://data/items.json"
const RELATIONSHIP_EVENTS_PATH: String = "res://data/relationship_events.json"

var npc_personality_dialogues: Dictionary = {}
var npc_profiles: Dictionary = {}
var items: Dictionary = {}
var relationship_events: Dictionary = {}

func _ready() -> void:
	load_all_data()

func load_all_data() -> void:
	load_npc_personality_dialogues()
	load_npc_profiles()
	load_items()
	load_relationship_events()

func load_npc_personality_dialogues() -> void:
	npc_personality_dialogues = load_json_file(NPC_PERSONALITY_DIALOGUES_PATH)

func load_npc_profiles() -> void:
	npc_profiles = load_json_file(NPC_PROFILES_PATH)

func load_items() -> void:
	items = load_json_file(ITEMS_PATH)

func load_relationship_events() -> void:
	relationship_events = load_json_file(RELATIONSHIP_EVENTS_PATH)

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
