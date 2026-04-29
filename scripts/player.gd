extends CharacterBody2D

@export var speed: float = 160.0
@export var save_id: String = "player"

@onready var interaction_area: Area2D = $Area2D

func _physics_process(_delta: float) -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")
	var gift_menu = get_tree().current_scene.get_node("GiftMenu")
	var social_notebook = get_tree().current_scene.get_node("SocialNotebook")
	var pause_menu = get_tree().current_scene.get_node("PauseMenu")

	if Input.is_action_just_pressed("interact"):
		if dialogue_box.is_open():
			dialogue_box.advance_dialogue()
		else:
			check_interaction()

	if Input.is_action_just_pressed("gift_menu"):
		if not gift_menu.visible:
			open_gift_menu_for_nearby_npc()
		else:
			gift_menu.close_menu()

	if Input.is_action_just_pressed("social_notebook"):
		social_notebook.toggle_notebook()
	
	if Input.is_action_just_pressed("pause_menu"):
		if dialogue_box.is_open():
			dialogue_box.hide_dialogue()
		elif gift_menu.visible:
			gift_menu.close_menu()
		elif social_notebook.visible:
			social_notebook.close_notebook()
		else:
			pause_menu.toggle_menu()
		
	if dialogue_box.is_open() or gift_menu.visible or social_notebook.visible or pause_menu.visible:
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

	for body in bodies:
		if body == self:
			continue

		if body.has_method("interact"):
			body.interact()
			return

func open_gift_menu_for_nearby_npc() -> void:
	var gift_menu = get_tree().current_scene.get_node("GiftMenu")
	var bodies = interaction_area.get_overlapping_bodies()

	for body in bodies:
		if body == self:
			continue

		if body.has_method("receive_gift"):
			gift_menu.open_menu(body)
			return
