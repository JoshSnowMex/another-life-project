extends CanvasLayer

var target_npc = null

@onready var food_button: Button = $GiftPanel/FoodButton
@onready var flower_button: Button = $GiftPanel/FlowerButton
@onready var jewel_button: Button = $GiftPanel/JewelButton
@onready var book_button: Button = $GiftPanel/BookButton
@onready var craft_button: Button = $GiftPanel/CraftButton
@onready var strange_button: Button = $GiftPanel/StrangeButton

var gift_buttons: Dictionary = {}

func _ready() -> void:
	visible = false

	gift_buttons = {
		GameConstants.GIFT_COMIDA: {
			"button": food_button,
			"display_name": "Comida"
		},
		GameConstants.GIFT_FLOR: {
			"button": flower_button,
			"display_name": "Flor"
		},
		GameConstants.GIFT_JOYA: {
			"button": jewel_button,
			"display_name": "Joya"
		},
		GameConstants.GIFT_LIBRO: {
			"button": book_button,
			"display_name": "Libro"
		},
		GameConstants.GIFT_ARTESANIA: {
			"button": craft_button,
			"display_name": "Artesanía"
		},
		GameConstants.GIFT_EXTRANO: {
			"button": strange_button,
			"display_name": "Extraño"
		}
	}

	for gift_type in gift_buttons.keys():
		var data: Dictionary = gift_buttons[gift_type]
		var button: Button = data["button"]
		button.pressed.connect(func(): give_gift(gift_type))

func open_menu(npc) -> void:
	target_npc = npc
	update_buttons()
	visible = true

func close_menu() -> void:
	visible = false
	target_npc = null

func update_buttons() -> void:
	for gift_type in gift_buttons.keys():
		var data: Dictionary = gift_buttons[gift_type]
		var button: Button = data["button"]
		var display_name: String = data["display_name"]

		button.text = display_name + " x" + str(PlayerStats.get_item_count(gift_type))
		button.disabled = not PlayerStats.has_item(gift_type)

func give_gift(gift_type: String) -> void:
	if target_npc == null:
		close_menu()
		return

	if target_npc.has_method("can_receive_gift"):
		if not target_npc.can_receive_gift():
			target_npc.receive_gift(gift_type)
			close_menu()
			return

	if not PlayerStats.remove_item(gift_type):
		update_buttons()
		return

	if target_npc.has_method("receive_gift"):
		target_npc.receive_gift(gift_type)

	close_menu()
