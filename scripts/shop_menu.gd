extends CanvasLayer

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var money_label: Label = $Panel/MarginContainer/VBoxContainer/MoneyLabel
@onready var items_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ItemsContainer
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(close_menu)

func open_menu() -> void:
	visible = true
	refresh_menu()

func close_menu() -> void:
	visible = false
	clear_items()

func refresh_menu() -> void:
	title_label.text = "Tienda de regalos"
	money_label.text = "Dinero: " + str(PlayerStats.money)
	clear_items()

	var shop_items: Dictionary = ShopSystem.get_available_shop_items()

	for shop_item_id in shop_items.keys():
		add_shop_item_button(str(shop_item_id), shop_items[shop_item_id])

func clear_items() -> void:
	for child in items_container.get_children():
		child.queue_free()

func add_shop_item_button(shop_item_id: String, shop_item_data: Dictionary) -> void:
	var item_id: String = str(shop_item_data.get("item_id", shop_item_id))
	var price: int = int(shop_item_data.get("price", 0))
	var display_name: String = DialogueDatabase.get_item_display_name(item_id)
	var owned: int = PlayerStats.get_item_count(item_id)

	var button := Button.new()
	button.custom_minimum_size = Vector2(320, 36)
	button.text = display_name + " - " + str(price) + " monedas" + " | Tienes: " + str(owned)
	button.disabled = not PlayerStats.can_afford(price)
	button.pressed.connect(func(): buy_item(shop_item_id))

	items_container.add_child(button)

func buy_item(shop_item_id: String) -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")
	var result: Dictionary = ShopSystem.buy_item(shop_item_id, 1)

	var speaker_name: String = str(result.get("speaker_name", "Tienda"))
	var text: String = str(result.get("text", ""))

	close_menu()
	dialogue_box.show_dialogue(speaker_name, text)
