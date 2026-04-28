extends Node

var strength: int = 1
var intelligence: int = 1
var dexterity: int = 1
var charisma: int = 1
var constitution: int = 1
var luck: int = 1

var inventory: Dictionary = {
	"comida": 2,
	"flor": 1,
	"joya": 1,
	"libro": 1,
	"artesania": 1,
	"extrano": 1
}

var max_energy: int = 100
var current_energy: int = 100

var life_path: String = "balanced"

func _ready() -> void:
	update_max_energy()

func update_max_energy() -> void:
	max_energy = 100 + (constitution * 2)
	current_energy = clamp(current_energy, 0, max_energy)

func gain_stat(stat_name: String, base_amount: int) -> int:
	var final_amount: int = calculate_gain(stat_name, base_amount)

	match stat_name:
		"strength":
			strength += final_amount
		"intelligence":
			intelligence += final_amount
		"dexterity":
			dexterity += final_amount
		"charisma":
			charisma += final_amount
		"constitution":
			constitution += final_amount
			update_max_energy()
		"luck":
			luck += final_amount

	return final_amount

func calculate_gain(stat_name: String, base_amount: int) -> int:
	var modifier: float = get_life_path_modifier(stat_name)
	var result: int = roundi(base_amount * modifier)
	return max(result, 1)

func get_life_path_modifier(stat_name: String) -> float:
	match life_path:
		"adventurer":
			if stat_name == "strength" or stat_name == "constitution":
				return 1.3
			if stat_name == "intelligence" or stat_name == "charisma":
				return 0.8

		"scholar":
			if stat_name == "intelligence" or stat_name == "luck":
				return 1.3
			if stat_name == "strength" or stat_name == "constitution":
				return 0.8

		"artisan":
			if stat_name == "dexterity" or stat_name == "constitution":
				return 1.3
			if stat_name == "charisma" or stat_name == "luck":
				return 0.8

		"charmer":
			if stat_name == "charisma" or stat_name == "luck":
				return 1.3
			if stat_name == "strength" or stat_name == "dexterity":
				return 0.8

		"rogue":
			if stat_name == "dexterity" or stat_name == "luck":
				return 1.3
			if stat_name == "intelligence" or stat_name == "constitution":
				return 0.8

	return 1.0

func spend_energy(amount: int) -> bool:
	if current_energy < amount:
		return false

	current_energy -= amount
	return true

func restore_energy(amount: int) -> void:
	current_energy += amount
	current_energy = clamp(current_energy, 0, max_energy)

func get_stat_value(stat_name: String) -> int:
	match stat_name:
		"strength":
			return strength
		"intelligence":
			return intelligence
		"dexterity":
			return dexterity
		"charisma":
			return charisma
		"constitution":
			return constitution
		"luck":
			return luck

	return 0

func has_item(item_name: String) -> bool:
	return inventory.has(item_name) and inventory[item_name] > 0

func remove_item(item_name: String, amount: int = 1) -> bool:
	if not has_item(item_name):
		return false

	inventory[item_name] -= amount
	return true

func get_item_count(item_name: String) -> int:
	if not inventory.has(item_name):
		return 0

	return inventory[item_name]
