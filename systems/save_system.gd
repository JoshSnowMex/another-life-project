extends Node

const SAVE_FILE_PATH: String = "user://save_game.json"
const SAVE_VERSION: int = 2
const POSITION_SAVE_GROUP: String = "save_position"

func save_game() -> bool:
	var save_data: Dictionary = create_save_data()
	var json_text: String = JSON.stringify(save_data, "\t")

	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("No se pudo crear el archivo de guardado: " + SAVE_FILE_PATH)
		return false

	file.store_string(json_text)
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		push_warning("No existe archivo de guardado todavía: " + SAVE_FILE_PATH)
		return false

	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)

	if file == null:
		push_error("No se pudo abrir el archivo de guardado: " + SAVE_FILE_PATH)
		return false

	var json_text: String = file.get_as_text()
	var parsed = JSON.parse_string(json_text)

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("El archivo de guardado no tiene formato válido.")
		return false

	apply_save_data(parsed)
	return true

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save_file() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return true

	var error: Error = DirAccess.remove_absolute(SAVE_FILE_PATH)

	if error != OK:
		push_error("No se pudo eliminar el archivo de guardado.")
		return false

	return true

func create_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"current_day": TimeSystem.current_day,
		"player": create_player_save_data(),
		"relationships": RelationshipSystem.relationships.duplicate(true),
		"event_flags": EventSystem.get_all_flags(),
		"positions": create_positions_save_data()
	}

func create_player_save_data() -> Dictionary:
	return {
		"strength": PlayerStats.strength,
		"intelligence": PlayerStats.intelligence,
		"dexterity": PlayerStats.dexterity,
		"charisma": PlayerStats.charisma,
		"constitution": PlayerStats.constitution,
		"luck": PlayerStats.luck,
		"max_energy": PlayerStats.max_energy,
		"current_energy": PlayerStats.current_energy,
		"life_path": PlayerStats.life_path,
		"inventory": PlayerStats.inventory.duplicate(true)
	}

func create_positions_save_data() -> Dictionary:
	var result: Dictionary = {}
	var nodes: Array[Node] = get_tree().get_nodes_in_group(POSITION_SAVE_GROUP)

	for node in nodes:
		if not node is Node2D:
			continue

		if not "save_id" in node:
			continue

		var save_id: String = str(node.save_id)

		if save_id == "":
			continue

		var node_2d := node as Node2D

		result[save_id] = {
			"x": node_2d.global_position.x,
			"y": node_2d.global_position.y
		}

	return result

func apply_save_data(save_data: Dictionary) -> void:
	TimeSystem.current_day = int(save_data.get("current_day", 1))

	var player_data: Dictionary = save_data.get("player", {})
	apply_player_save_data(player_data)

	var relationships_data: Dictionary = save_data.get("relationships", {})
	RelationshipSystem.relationships = relationships_data.duplicate(true)

	var event_flags_data: Dictionary = save_data.get("event_flags", {})
	EventSystem.load_flags(event_flags_data)

	var positions_data: Dictionary = save_data.get("positions", {})
	apply_positions_save_data(positions_data)

func apply_player_save_data(player_data: Dictionary) -> void:
	PlayerStats.strength = int(player_data.get("strength", 1))
	PlayerStats.intelligence = int(player_data.get("intelligence", 1))
	PlayerStats.dexterity = int(player_data.get("dexterity", 1))
	PlayerStats.charisma = int(player_data.get("charisma", 1))
	PlayerStats.constitution = int(player_data.get("constitution", 1))
	PlayerStats.luck = int(player_data.get("luck", 1))

	PlayerStats.life_path = str(player_data.get("life_path", "balanced"))

	var inventory_data: Dictionary = player_data.get("inventory", {})
	PlayerStats.inventory = inventory_data.duplicate(true)

	PlayerStats.update_max_energy()

	var saved_max_energy: int = int(player_data.get("max_energy", PlayerStats.max_energy))
	PlayerStats.max_energy = saved_max_energy
	PlayerStats.current_energy = int(player_data.get("current_energy", PlayerStats.max_energy))
	PlayerStats.current_energy = clamp(PlayerStats.current_energy, 0, PlayerStats.max_energy)

func apply_positions_save_data(positions_data: Dictionary) -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(POSITION_SAVE_GROUP)

	for node in nodes:
		if not node is Node2D:
			continue

		if not "save_id" in node:
			continue

		var save_id: String = str(node.save_id)

		if save_id == "":
			continue

		if not positions_data.has(save_id):
			continue

		var position_data: Dictionary = positions_data[save_id]
		var x: float = float(position_data.get("x", 0.0))
		var y: float = float(position_data.get("y", 0.0))

		var node_2d := node as Node2D
		node_2d.global_position = Vector2(x, y)
