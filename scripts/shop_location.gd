extends StaticBody2D

@export var location_name: String = "Tienda de regalos"

func interact() -> void:
	var shop_menu = get_tree().current_scene.get_node_or_null("ShopMenu")

	if shop_menu == null:
		push_error("No existe un nodo ShopMenu en la escena actual.")
		return

	if not shop_menu.has_method("open_menu"):
		push_error("El nodo ShopMenu existe, pero no tiene shop_menu.gd adjunto o no tiene open_menu().")
		return

	shop_menu.open_menu()
