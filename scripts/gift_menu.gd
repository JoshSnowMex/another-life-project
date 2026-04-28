extends CanvasLayer

var target_npc = null

@onready var food_button: Button = $GiftPanel/FoodButton
@onready var flower_button: Button = $GiftPanel/FlowerButton
@onready var jewel_button: Button = $GiftPanel/JewelButton
@onready var book_button: Button = $GiftPanel/BookButton
@onready var craft_button: Button = $GiftPanel/CraftButton
@onready var strange_button: Button = $GiftPanel/StrangeButton

func _ready() -> void:
	visible = false

	food_button.pressed.connect(func(): give_gift("comida"))
	flower_button.pressed.connect(func(): give_gift("flor"))
	jewel_button.pressed.connect(func(): give_gift("joya"))
	book_button.pressed.connect(func(): give_gift("libro"))
	craft_button.pressed.connect(func(): give_gift("artesania"))
	strange_button.pressed.connect(func(): give_gift("extrano"))

func open_menu(npc) -> void:
	target_npc = npc
	update_buttons()
	visible = true

func close_menu() -> void:
	visible = false
	target_npc = null

func update_buttons() -> void:
	food_button.text = "Comida x" + str(PlayerStats.get_item_count("comida"))
	flower_button.text = "Flor x" + str(PlayerStats.get_item_count("flor"))
	jewel_button.text = "Joya x" + str(PlayerStats.get_item_count("joya"))
	book_button.text = "Libro x" + str(PlayerStats.get_item_count("libro"))
	craft_button.text = "Artesanía x" + str(PlayerStats.get_item_count("artesania"))
	strange_button.text = "Extraño x" + str(PlayerStats.get_item_count("extrano"))

	food_button.disabled = not PlayerStats.has_item("comida")
	flower_button.disabled = not PlayerStats.has_item("flor")
	jewel_button.disabled = not PlayerStats.has_item("joya")
	book_button.disabled = not PlayerStats.has_item("libro")
	craft_button.disabled = not PlayerStats.has_item("artesania")
	strange_button.disabled = not PlayerStats.has_item("extrano")

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
