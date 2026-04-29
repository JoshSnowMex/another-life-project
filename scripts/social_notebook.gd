extends CanvasLayer

var selected_npc_id: String = ""

@onready var npc_list_container: VBoxContainer = $Panel/MarginContainer/HBoxContainer/NpcListPanel/NpcList
@onready var detail_name_label: Label = $Panel/MarginContainer/HBoxContainer/DetailPanel/DetailMargin/DetailContent/NameLabel
@onready var detail_stage_label: Label = $Panel/MarginContainer/HBoxContainer/DetailPanel/DetailMargin/DetailContent/StageLabel
@onready var detail_affinity_label: Label = $Panel/MarginContainer/HBoxContainer/DetailPanel/DetailMargin/DetailContent/AffinityLabel
@onready var detail_description_label: Label = $Panel/MarginContainer/HBoxContainer/DetailPanel/DetailMargin/DetailContent/DescriptionLabel
@onready var known_facts_container: VBoxContainer = $Panel/MarginContainer/HBoxContainer/DetailPanel/DetailMargin/DetailContent/KnownFacts

func _ready() -> void:
	visible = false
	clear_details()

func open_notebook() -> void:
	selected_npc_id = ""
	refresh_notebook()
	visible = true

func close_notebook() -> void:
	visible = false

func toggle_notebook() -> void:
	if visible:
		close_notebook()
	else:
		open_notebook()

func refresh_notebook() -> void:
	clear_npc_list()
	clear_details()

	var known_npcs: Array[String] = NpcKnowledgeSystem.get_known_npcs()

	if known_npcs.is_empty():
		add_empty_list_label("No conoces a nadie todavía.")
		return

	for npc_id in known_npcs:
		add_npc_button(npc_id)

func clear_npc_list() -> void:
	for child in npc_list_container.get_children():
		child.queue_free()

func add_empty_list_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	npc_list_container.add_child(label)

func add_npc_button(npc_id: String) -> void:
	var profile_data: Dictionary = NpcKnowledgeSystem.get_profile_data(npc_id)
	var display_name: String = str(profile_data.get("display_name", npc_id))

	var button := Button.new()
	button.text = display_name
	button.custom_minimum_size = Vector2(220, 40)
	button.modulate = get_relationship_color(npc_id)
	button.pressed.connect(func(): show_npc_details(npc_id))

	npc_list_container.add_child(button)

func get_relationship_color(npc_id: String) -> Color:
	var affinity: int = RelationshipSystem.get_affinity(npc_id)

	if affinity < 0:
		return Color(1.0, 0.45, 0.45)
	elif affinity < 20:
		return Color(1.0, 1.0, 1.0)
	elif affinity < 40:
		return Color(1.0, 0.9, 0.45)
	elif affinity < 60:
		return Color(0.55, 1.0, 0.55)
	elif affinity < 80:
		return Color(0.45, 0.85, 1.0)
	else:
		return Color(1.0, 0.55, 0.9)

func show_npc_details(npc_id: String) -> void:
	selected_npc_id = npc_id

	var profile_data: Dictionary = NpcKnowledgeSystem.get_profile_data(npc_id)
	var display_name: String = str(profile_data.get("display_name", npc_id))
	var short_description: String = str(profile_data.get("short_description", ""))

	var affinity: int = RelationshipSystem.get_affinity(npc_id)
	var stage_data: Dictionary = RelationshipStageSystem.get_stage_for_npc(npc_id)

	detail_name_label.text = display_name
	detail_stage_label.text = "Relación: " + str(stage_data.get("display_name", "Desconocido"))
	detail_affinity_label.text = "Afinidad: " + str(affinity)
	detail_description_label.text = short_description

	refresh_known_facts(npc_id)

func refresh_known_facts(npc_id: String) -> void:
	for child in known_facts_container.get_children():
		child.queue_free()

	var known_facts: Array[Dictionary] = NpcKnowledgeSystem.get_known_facts(npc_id)

	if known_facts.is_empty():
		var label := Label.new()
		label.text = "Aún no conoces datos personales."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		known_facts_container.add_child(label)
		return

	for fact_data in known_facts:
		var label_text: String = str(fact_data.get("label", "Dato")) + ": " + str(fact_data.get("value", ""))
		var label := Label.new()
		label.text = label_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		known_facts_container.add_child(label)

func clear_details() -> void:
	detail_name_label.text = "Selecciona un NPC"
	detail_stage_label.text = "Relación: -"
	detail_affinity_label.text = "Afinidad: -"
	detail_description_label.text = ""

	for child in known_facts_container.get_children():
		child.queue_free()

	var label := Label.new()
	label.text = "Haz click en un nombre para ver la información conocida."
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	known_facts_container.add_child(label)
