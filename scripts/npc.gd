extends CharacterBody2D


const PERSONALITY_AMABLE: String = "amable"
const PERSONALITY_GRUNON: String = "grunon"
const PERSONALITY_IMPREDECIBLE: String = "impredecible"

@export var npc_name: String = "Lyria"
@export var personality: String = "amable"

@export var loved_gifts: Array[String] = ["joya"]
@export var liked_gifts: Array[String] = ["flor", "libro"]
@export var disliked_gifts: Array[String] = ["extrano"]

var affinity: int = 0
var mood: String = "neutral"
var interaction_count: int = 0
var has_received_gift_today: bool = false

func _ready() -> void:
	add_to_group("npcs")

func interact() -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")
	var text: String = ""

	interaction_count += 1

	if interaction_count == 1:
		update_mood_for_today()
		text = get_first_interaction_text()
	elif interaction_count == 2:
		var affinity_change: int = calculate_affinity_change()
		affinity += affinity_change
		affinity = clamp(affinity, -100, 100)
		update_mood_after_affinity_change(affinity_change)
		text = get_second_interaction_text(affinity_change)
	else:
		text = get_limit_text()
	
	dialogue_box.show_dialogue(npc_name, text)

func update_mood_for_today() -> void:
	var roll: int = randi_range(1, 100)
	var bias: int = get_affinity_bias()
	var personality_modifier: int = get_personality_mood_modifier()

	var final_roll: int = roll + (bias * 10) + personality_modifier

	if final_roll >= 75:
		mood = "happy"
	elif final_roll <= 25:
		mood = "irritated"
	else:
		mood = "neutral"
		
func get_personality_mood_modifier() -> int:
	match personality:
		PERSONALITY_AMABLE:
			return 10
		PERSONALITY_GRUNON:
			return -10
		PERSONALITY_IMPREDECIBLE:
			return randi_range(-20, 20)

	return 0

func update_mood_after_affinity_change(affinity_change: int) -> void:
	if affinity_change > 1:
		mood = "happy"
	elif affinity_change < 0:
		mood = "irritated"
		
func get_personality_dialogue(context: String) -> String:
	var dialogues: Dictionary = {
		PERSONALITY_AMABLE: {
			"first_happy": [
				"¡Qué alegría verte! Me alegra que hayas venido.",
				"Justo estaba esperando encontrarme con alguien amable.",
				"Tu presencia hace que este día se sienta un poco más ligero."
			],
			"first_irritated": [
				"Perdón... hoy no me siento del todo bien.",
				"No es tu culpa, solo tengo un día complicado.",
				"Intentaré no descargar mi mal humor contigo."
			],
			"second_positive": [
				"Hablar contigo siempre me deja una buena sensación.",
				"Gracias por tomarte el tiempo de hablar conmigo.",
				"Me gusta que podamos conversar así."
			],
			"second_negative": [
				"Creo que esta conversación no salió como esperaba.",
				"Perdón, quizá no estoy entendiendo bien tus palabras.",
				"Me siento un poco incómoda con esto."
			],
			"second_neutral": [
				"Supongo que aún nos estamos conociendo.",
				"No estuvo mal. Podemos hablar más otro día.",
				"Gracias por acercarte, aunque no tenga mucho que decir ahora."
			],
			"limit_happy": [
				"Me encantaría seguir hablando, pero dejémoslo para luego.",
				"Hablemos más otro día, ¿sí?",
				"Guardaré algo de conversación para mañana."
			],
			"limit_irritated": [
				"De verdad necesito descansar un poco.",
				"Perdón, pero ya no quiero hablar más por hoy.",
				"Mejor dejémoslo aquí antes de que diga algo feo."
			],
			"limit_neutral": [
				"Creo que ya hablamos suficiente por hoy.",
				"Podemos continuar otro día.",
				"Necesito ocuparme de otras cosas ahora."
			]
		},

		PERSONALITY_GRUNON: {
			"first_happy": [
				"No te acostumbres, pero hoy estoy de buen humor.",
				"Supongo que verte no arruinó mi día.",
				"Bueno... hoy puedo tolerar una conversación."
			],
			"first_irritated": [
				"¿Qué quieres ahora?",
				"No estoy de humor. Habla rápido.",
				"Este no es un buen momento."
			],
			"second_positive": [
				"No estuvo tan mal como esperaba.",
				"Bien. Admito que dijiste algo útil.",
				"Supongo que puedes ser menos molesto de lo normal."
			],
			"second_negative": [
				"Sabía que esto iba a ser una pérdida de tiempo.",
				"Eso fue exactamente lo que no quería escuchar.",
				"Me estás dando razones para terminar esta conversación."
			],
			"second_neutral": [
				"No tengo una opinión sobre eso.",
				"Ajá. ¿Eso era todo?",
				"No fue terrible. Tampoco interesante."
			],
			"limit_happy": [
				"Ya hablamos bastante. No arruines el momento.",
				"Terminemos aquí mientras aún estoy de buen humor.",
				"Vuelve luego. Tal vez."
			],
			"limit_irritated": [
				"Ya basta.",
				"No voy a repetirlo: déjame en paz por hoy.",
				"Se acabó la conversación."
			],
			"limit_neutral": [
				"Eso es suficiente por hoy.",
				"No tengo más que decir.",
				"Vuelve otro día si insistes."
			]
		},

		PERSONALITY_IMPREDECIBLE: {
			"first_happy": [
				"¡Hoy el aire sabe a aventura!",
				"Qué curioso verte justo ahora. Tal vez era destino.",
				"¡Perfecto! Necesitaba una interrupción interesante."
			],
			"first_irritated": [
				"No sé si quiero hablar... o lanzar una piedra al río.",
				"Hoy todo suena demasiado fuerte, incluso tus pasos.",
				"Mi humor está mordiendo. Cuidado."
			],
			"second_positive": [
				"Eso fue inesperadamente divertido.",
				"Me agradas un poco más. No preguntes por qué.",
				"Interesante... cambiaste el color del día."
			],
			"second_negative": [
				"Uy. Eso cayó como sopa fría.",
				"No sé qué esperaba, pero no era eso.",
				"Algo en mí acaba de cerrar una puerta imaginaria."
			],
			"second_neutral": [
				"Eso fue... una conversación.",
				"Ni bien ni mal. Como pan sin mermelada.",
				"Lo guardaré en mi caja mental de cosas raras."
			],
			"limit_happy": [
				"Sigamos otro día antes de que se evapore la magia.",
				"Me voy antes de cambiar de opinión.",
				"Demasiadas palabras arruinan los buenos misterios."
			],
			"limit_irritated": [
				"Ya no. Mi paciencia se fue caminando.",
				"Necesito silencio antes de convertirme en tormenta.",
				"Fin de la función por hoy."
			],
			"limit_neutral": [
				"Mi cabeza ya cambió de canal.",
				"Podemos hablar luego, si el universo insiste.",
				"Ya gasté mis palabras de este momento."
			]
		}
	}

	if not dialogues.has(personality):
		return ""

	var personality_dialogues: Dictionary = dialogues[personality]

	if not personality_dialogues.has(context):
		return ""

	var options: Array = personality_dialogues[context]

	if options.is_empty():
		return ""

	return options.pick_random()

func get_first_interaction_text() -> String:
	if mood == "happy":
		var dialogue: String = get_personality_dialogue("first_happy")
		if dialogue != "":
			return dialogue
		return "Me alegra verte por aquí."

	elif mood == "irritated":
		var dialogue: String = get_personality_dialogue("first_irritated")
		if dialogue != "":
			return dialogue
		return "No estoy de humor ahora mismo."

	return get_affinity_text()

func get_second_interaction_text(affinity_change: int) -> String:
	var dialogue: String = ""

	if affinity_change > 0:
		dialogue = get_personality_dialogue("second_positive")
		if dialogue == "":
			dialogue = "Supongo que hablar contigo no estuvo mal."

	elif affinity_change < 0:
		dialogue = get_personality_dialogue("second_negative")
		if dialogue == "":
			dialogue = "Te dije que no era un buen momento."

	else:
		dialogue = get_personality_dialogue("second_neutral")
		if dialogue == "":
			dialogue = "No tengo mucho más que decir."

	return dialogue + " Afinidad: " + str(affinity)

func get_limit_text() -> String:
	var dialogue: String = ""

	if mood == "irritated":
		dialogue = get_personality_dialogue("limit_irritated")
		if dialogue == "":
			dialogue = "Ya basta por hoy."

	elif mood == "happy":
		dialogue = get_personality_dialogue("limit_happy")
		if dialogue == "":
			dialogue = "Hablemos luego, ¿sí?"

	else:
		dialogue = get_personality_dialogue("limit_neutral")
		if dialogue == "":
			dialogue = "Creo que ya hablamos suficiente por hoy."

	return dialogue

func calculate_affinity_change() -> int:
	var mood_modifier: int = get_mood_modifier()
	var affinity_bias: int = get_affinity_bias()
	var personality_modifier: int = get_personality_affinity_modifier()

	var luck_roll: int = randi_range(-2, 2)

	var charisma_bonus: int = int(PlayerStats.charisma / 5)
	var luck_bonus: int = int(PlayerStats.luck / 5)

	var result: int = mood_modifier + affinity_bias + personality_modifier + luck_roll + charisma_bonus + luck_bonus

	return clamp(result, -5, 5)
	
func get_personality_affinity_modifier() -> int:
	match personality:
		PERSONALITY_AMABLE:
			return 1
		PERSONALITY_GRUNON:
			return -1
		PERSONALITY_IMPREDECIBLE:
			return randi_range(-2, 2)

	return 0

func get_mood_modifier() -> int:
	if mood == "happy":
		return 2
	elif mood == "irritated":
		return -2
	else:
		return 0

func get_affinity_bias() -> int:
	if affinity < -80:
		return -3
	elif affinity < -50:
		return -2
	elif affinity < -20:
		return -1
	elif affinity < 20:
		return 0
	elif affinity < 50:
		return 1
	elif affinity < 80:
		return 2
	else:
		return 3

func get_affinity_text() -> String:
	if affinity < -80:
		return "Te odio."
	elif affinity < -50:
		return "No te soporto."
	elif affinity < -20:
		return "No quiero hablar contigo."
	elif affinity < 0:
		return "¿Qué quieres ahora?"
	elif affinity < 20:
		return "No te conozco..."
	elif affinity < 50:
		return "Oh, eres tú otra vez."
	elif affinity < 80:
		return "Me agrada hablar contigo."
	else:
		return "Confío en ti."

func receive_gift(gift_type: String) -> void:
	var dialogue_box = get_tree().current_scene.get_node("DialogueBox")

	if has_received_gift_today:
		dialogue_box.show_dialogue(npc_name, "Ya me diste algo hoy.")
		return

	has_received_gift_today = true

	var affinity_change: int = calculate_gift_affinity_change(gift_type)
	affinity += affinity_change
	affinity = clamp(affinity, -100, 100)

	if affinity_change >= 6:
		mood = "happy"
	elif affinity_change < 0:
		mood = "irritated"
	else:
		mood = "neutral"

	dialogue_box.show_dialogue(npc_name, get_gift_response_text(gift_type, affinity_change))

func calculate_gift_affinity_change(gift_type: String) -> int:
	var base_change: int = 1

	if loved_gifts.has(gift_type):
		base_change = 12
	elif liked_gifts.has(gift_type):
		base_change = 6
	elif disliked_gifts.has(gift_type):
		base_change = -8

	var luck_modifier: int = int(PlayerStats.luck / 5)
	var result: int = base_change + luck_modifier

	return clamp(result, -12, 15)

func get_gift_response_text(gift_type: String, affinity_change: int) -> String:
	if affinity_change >= 10:
		return "¿Esto es para mí? Me encanta. Afinidad: " + str(affinity)
	elif affinity_change > 1:
		return "Gracias, me gusta. Afinidad: " + str(affinity)
	elif affinity_change == 1:
		return "Gracias... supongo. Afinidad: " + str(affinity)
	else:
		return "Esto no me gusta. Afinidad: " + str(affinity)

func reset_daily_interactions() -> void:
	interaction_count = 0
	has_received_gift_today = false
	
func can_receive_gift() -> bool:
	return not has_received_gift_today
