extends CanvasLayer

@onready var title_label: Label = $Panel/MarginContainer/HBoxContainer/DetailsPanel/DetailsContent/TitleLabel
@onready var description_label: Label = $Panel/MarginContainer/HBoxContainer/DetailsPanel/DetailsContent/DescriptionLabel
@onready var bonus_label: Label = $Panel/MarginContainer/HBoxContainer/DetailsPanel/DetailsContent/BonusLabel
@onready var penalty_label: Label = $Panel/MarginContainer/HBoxContainer/DetailsPanel/DetailsContent/PenaltyLabel
@onready var neutral_label: Label = $Panel/MarginContainer/HBoxContainer/DetailsPanel/DetailsContent/NeutralLabel
@onready var confirm_button: Button = $Panel/MarginContainer/HBoxContainer/DetailsPanel/DetailsContent/ConfirmButton

var selected_life_path: String = ""

var life_paths: Dictionary = {
	"adventurer": {
		"display_name": "Aventurero",
		"description": "Fuerte en combate y resistencia.",
		"bonus": "Fuerza, Constitución",
		"penalty": "Inteligencia, Carisma",
		"neutral": "Destreza, Suerte"
	},
	"scholar": {
		"display_name": "Estudioso",
		"description": "Enfocado en conocimiento y azar.",
		"bonus": "Inteligencia, Suerte",
		"penalty": "Fuerza, Constitución",
		"neutral": "Destreza, Carisma"
	},
	"artisan": {
		"display_name": "Artesano",
		"description": "Habilidad manual y resistencia.",
		"bonus": "Destreza, Constitución",
		"penalty": "Carisma, Suerte",
		"neutral": "Fuerza, Inteligencia"
	},
	"charmer": {
		"display_name": "Encantador",
		"description": "Social y con buena suerte.",
		"bonus": "Carisma, Suerte",
		"penalty": "Fuerza, Destreza",
		"neutral": "Inteligencia, Constitución"
	},
	"rogue": {
		"display_name": "Bribón",
		"description": "Ágil, oportunista y arriesgado.",
		"bonus": "Destreza, Suerte",
		"penalty": "Inteligencia, Constitución",
		"neutral": "Fuerza, Carisma"
	},
	"balanced": {
		"display_name": "Equilibrado",
		"description": "Sin ventajas ni desventajas.",
		"bonus": "Ninguno",
		"penalty": "Ninguna",
		"neutral": "Todos"
	}
}

func _ready() -> void:
	confirm_button.disabled = true
	clear_details()

func select_life_path(life_path_id: String) -> void:
	selected_life_path = life_path_id

	var data: Dictionary = life_paths.get(life_path_id, {})

	title_label.text = str(data.get("display_name", life_path_id))
	description_label.text = str(data.get("description", ""))
	bonus_label.text = "Bonus x1.3: " + str(data.get("bonus", ""))
	penalty_label.text = "Penalización x0.8: " + str(data.get("penalty", ""))
	neutral_label.text = "Neutral x1.0: " + str(data.get("neutral", ""))

	confirm_button.disabled = false

func clear_details() -> void:
	title_label.text = "Elige un camino de vida"
	description_label.text = "Tu camino no bloquea contenido. Solo cambia la velocidad con la que subes ciertas estadísticas."
	bonus_label.text = "Bonus x1.3: -"
	penalty_label.text = "Penalización x0.8: -"
	neutral_label.text = "Neutral x1.0: -"

func _on_adventurer_button_pressed() -> void:
	select_life_path("adventurer")

func _on_scholar_button_pressed() -> void:
	select_life_path("scholar")

func _on_artisan_button_pressed() -> void:
	select_life_path("artisan")

func _on_charmer_button_pressed() -> void:
	select_life_path("charmer")

func _on_rogue_button_pressed() -> void:
	select_life_path("rogue")

func _on_balanced_button_pressed() -> void:
	select_life_path("balanced")

func _on_confirm_button_pressed() -> void:
	if selected_life_path == "":
		return

	SaveSystem.start_new_game(selected_life_path)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
