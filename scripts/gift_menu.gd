extends CanvasLayer

var target_npc = null
var gift_buttons: Dictionary = {}

@onready var gift_button_container: VBoxContainer = $GiftPanel/GiftButtonContainer

func _ready() -> void:
	visible = false
	build_gift_buttons()

func build_gift_buttons() -> void:
	clear_gift_buttons()

	var gift_items: Dictionary = DialogueDatabase.get_gift_items()

	for gift_type in gift_items.keys():
		var button := Button.new()
		button.custom_minimum_size = Vector2(260, 35)
		button.pressed.connect(func(): give_gift(gift_type))

		gift_button_container.add_child(button)
		gift_buttons[gift_type] = button

	update_buttons()

func clear_gift_buttons() -> void:
	for child in gift_button_container.get_children():
		child.queue_free()

	gift_buttons.clear()

func open_menu(npc) -> void:
	target_npc = npc
	update_buttons()
	visible = true

func close_menu() -> void:
	visible = false
	target_npc = null

func update_buttons() -> void:
	for gift_type in gift_buttons.keys():
		var button: Button = gift_buttons[gift_type]
		var display_name: String = DialogueDatabase.get_item_display_name(gift_type)
		var amount: int = PlayerStats.get_item_count(gift_type)

		button.text = display_name + " x" + str(amount)
		button.disabled = amount <= 0

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
