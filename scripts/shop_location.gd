extends StaticBody2D

@export var location_name: String = "Tienda de regalos"

func interact() -> void:
	var shop_menu = get_tree().current_scene.get_node("ShopMenu")
	shop_menu.open_menu()
