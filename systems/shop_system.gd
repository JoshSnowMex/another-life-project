extends Node

func get_available_shop_items() -> Dictionary:
	return DialogueDatabase.get_shop_items()

func buy_item(shop_item_id: String, amount: int = 1) -> Dictionary:
	var shop_item_data: Dictionary = DialogueDatabase.get_shop_item_data(shop_item_id)

	if shop_item_data.is_empty():
		return create_result(false, "Tienda", "Ese objeto no existe en la tienda.")

	var item_id: String = str(shop_item_data.get("item_id", shop_item_id))
	var price: int = int(shop_item_data.get("price", 0))
	var total_price: int = price * max(amount, 1)

	if total_price <= 0:
		return create_result(false, "Tienda", "Ese objeto no tiene precio válido.")

	if not PlayerStats.can_afford(total_price):
		return create_result(false, "Tienda", "No tienes suficiente dinero. Necesitas " + str(total_price) + " monedas.")

	if not PlayerStats.spend_money(total_price):
		return create_result(false, "Tienda", "No se pudo completar la compra.")

	PlayerStats.add_item(item_id, amount)

	var display_name: String = DialogueDatabase.get_item_display_name(item_id)
	var text: String = "Compraste " + display_name + " x" + str(amount) + ". Dinero restante: " + str(PlayerStats.money) + "."

	return create_result(true, "Tienda", text)

func create_result(success: bool, speaker_name: String, text: String) -> Dictionary:
	return {
		"success": success,
		"speaker_name": speaker_name,
		"text": text
	}
