extends Node

const NPC_PERSONALITY_DIALOGUES_PATH: String = "res://data/npc_personality_dialogues.json"
const NPC_PROFILES_PATH: String = "res://data/npcs.json"

var npc_personality_dialogues: Dictionary = {}
var npc_profiles: Dictionary = {}

func _ready() -> void:
	load_all_data()

func load_all_data() -> void:
	load_npc_personality_dialogues()
	load_npc_profiles()

func load_npc_personality_dialogues() -> void:
	npc_personality_dialogues = load_json_file(NPC_PERSONALITY_DIALOGUES_PATH)

func load_npc_profiles() -> void:
	npc_profiles = load_json_file(NPC_PROFILES_PATH)

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
