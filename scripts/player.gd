extends CharacterBody2D

@export var speed: float = 160.0
@export var save_id: String = "player"

@onready var interaction_area: Area2D = $Area2D

func _physics_process(_delta: float) -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")
	var gift_menu = get_tree().current_scene.get_node("GiftMenu")
	var social_notebook = get_tree().current_scene.get_node("SocialNotebook")
	var pause_menu = get_tree().current_scene.get_node("PauseMenu")
	var date_menu = get_tree().current_scene.get_node("DateMenu")
	var location_menu = get_tree().current_scene.get_node("LocationInteractionMenu")
	var npc_interaction_menu = get_tree().current_scene.get_node("NpcInteractionMenu")
	var shop_menu = get_tree().current_scene.get_node("ShopMenu")

	if Input.is_action_just_pressed("interact"):
		if dialogue_box.is_open():
			dialogue_box.advance_dialogue()
		elif gift_menu.visible:
			gift_menu.close_menu()
		elif social_notebook.visible:
			social_notebook.close_notebook()
		elif date_menu.visible:
			date_menu.close_menu()
		elif location_menu.visible:
			location_menu.close_menu()
		elif npc_interaction_menu.visible:
			npc_interaction_menu.close_menu()
		elif shop_menu.visible:
			shop_menu.close_menu()
		elif pause_menu.visible:
			pause_menu.close_menu()
		else:
			check_interaction()

	if Input.is_action_just_pressed("social_notebook"):
		if social_notebook.visible:
			social_notebook.close_notebook()
		elif not is_any_ui_visible([dialogue_box, gift_menu, pause_menu, date_menu, location_menu, npc_interaction_menu, shop_menu]):
			social_notebook.open_notebook()

	if Input.is_action_just_pressed("pause_menu"):
		if dialogue_box.is_open():
			dialogue_box.hide_dialogue()
		elif gift_menu.visible:
			gift_menu.close_menu()
		elif social_notebook.visible:
			social_notebook.close_notebook()
		elif date_menu.visible:
			date_menu.close_menu()
		elif location_menu.visible:
			location_menu.close_menu()
		elif npc_interaction_menu.visible:
			npc_interaction_menu.close_menu()
		elif shop_menu.visible:
			shop_menu.close_menu()
		else:
			pause_menu.toggle_menu()
		
	if dialogue_box.is_open() or gift_menu.visible or social_notebook.visible or pause_menu.visible or date_menu.visible or location_menu.visible or npc_interaction_menu.visible or shop_menu.visible:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("next_day"):
		TimeSystem.next_day()
		
	if Input.is_action_just_pressed("save_game"):
		if SaveSystem.save_game():
			print("Partida guardada.")

	if Input.is_action_just_pressed("load_game"):
		if SaveSystem.load_game():
			print("Partida cargada.")

	var direction: Vector2 = Vector2.ZERO

	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if direction.length() > 0:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

func check_interaction() -> void:
	var bodies = interaction_area.get_overlapping_bodies()
	var npc_interaction_menu = get_tree().current_scene.get_node("NpcInteractionMenu")

	for body in bodies:
		if body == self:
			continue

		if is_npc(body):
			npc_interaction_menu.open_menu(body)
			return

		if body.has_method("interact"):
			body.interact()
			return

func is_npc(body) -> bool:
	return "npc_id" in body and "npc_name" in body

func open_gift_menu_for_nearby_npc() -> void:
	var gift_menu = get_tree().current_scene.get_node("GiftMenu")
	var bodies = interaction_area.get_overlapping_bodies()

	for body in bodies:
		if body == self:
			continue

		if body.has_method("receive_gift"):
			gift_menu.open_menu(body)
			return

func open_date_menu_for_nearby_npc() -> void:
	var date_menu = get_tree().current_scene.get_node("DateMenu")
	var bodies = interaction_area.get_overlapping_bodies()

	for body in bodies:
		if body == self:
			continue

		if body.has_method("interact") and "npc_id" in body:
			date_menu.open_menu(body)
			return

func is_any_ui_visible(controls: Array) -> bool:
	for control in controls:
		if control == null:
			continue

		if control.has_method("is_open") and control.is_open():
			return true

		if "visible" in control and control.visible:
			return true

	return false
