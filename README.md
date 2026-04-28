# Another Life Project

## 📌 Descripción

Another Life Project es un juego 2D top-down hecho en **Godot 4**, estilo **Life Sim / Social Sim inspirado en SimGirls**, con una estructura pensada para crecer hacia algo tipo **Stardew Valley sin granja/mina**, centrado principalmente en:

- Relaciones con NPCs
- Romance / afinidad
- Diálogos por personalidad
- Regalos
- Stats del jugador
- Actividades diarias
- Sistema de tiempo
- Datos externos en JSON para facilitar expansión

El objetivo del proyecto es aprender Godot construyendo un juego real paso a paso, sin asumir conocimiento previo del motor.

---

# 🎮 Estado actual del proyecto

El juego actualmente usa personajes representados con formas simples/cuadritos. Los assets visuales se agregarán más adelante, cuando los sistemas principales estén más sólidos.

Ya existe un vertical slice social básico con:

- Movimiento 2D top-down
- NPCs interactuables
- Sistema de afinidad
- Sistema de mood
- Personalidades de NPC
- Diálogos según personalidad
- Regalos dinámicos desde datos
- Inventario inicial desde datos
- Sistema de relaciones centralizado
- Sistema de tiempo diario
- Actividades para subir stats
- UI básica de diálogo, stats y regalos

---

# 🧱 Estructura general del proyecto

/assets
/data
/scenes
  /world
  /npc
  /player
  /ui
/scripts
/systems
/ui

Carpetas principales
/data

Contiene datos del juego en JSON. La idea es que nuevo contenido pueda agregarse aquí sin tocar demasiada lógica.

Archivos actuales importantes:

data/npcs.json
data/items.json
data/npc_personality_dialogues.json
/scripts

Contiene scripts de escenas o nodos concretos.

Archivos importantes:

scripts/npc.gd
scripts/player.gd
scripts/gift_menu.gd
scripts/dialogue_box.gd
scripts/stats_hud.gd
scripts/training_spot.gd
scripts/library_spot.gd
/systems

Contiene sistemas globales/autoloads.

Archivos importantes:

systems/game_constants.gd
systems/dialogue_database.gd
systems/player_stats.gd
systems/time_system.gd
systems/relationship_system.gd
⚙️ Autoloads actuales

El proyecto depende de varios Autoloads. El orden recomendado es:

GameConstants
DialogueDatabase
RelationshipSystem
PlayerStats
TimeSystem
GameConstants

Ruta:

systems/game_constants.gd

Contiene constantes globales tipo enum/string constants:

Personalidades
Moods
Contextos de diálogo
Tipos de regalo base

Ejemplos:

GameConstants.PERSONALITY_AMABLE
GameConstants.PERSONALITY_GRUNON
GameConstants.PERSONALITY_IMPREDECIBLE

GameConstants.MOOD_HAPPY
GameConstants.MOOD_NEUTRAL
GameConstants.MOOD_IRRITATED

También contiene contextos de diálogo como:

GameConstants.DIALOGUE_FIRST_HAPPY
GameConstants.DIALOGUE_SECOND_POSITIVE
GameConstants.DIALOGUE_LIMIT_NEUTRAL

Último trabajo pendiente relacionado:
se agregaron o se iban a agregar contextos de regalos como:

GameConstants.DIALOGUE_GIFT_LOVED
GameConstants.DIALOGUE_GIFT_LIKED
GameConstants.DIALOGUE_GIFT_NEUTRAL
GameConstants.DIALOGUE_GIFT_DISLIKED
GameConstants.DIALOGUE_GIFT_ALREADY_RECEIVED

Revisar si ya están en game_constants.gd. Si no están, agregarlos.

🗃️ Datos JSON
data/npcs.json

Define perfiles base de NPCs.

Ejemplo de estructura:

{
  "lyria": {
    "display_name": "Lyria",
    "personality": "amable",
    "loved_gifts": ["joya"],
    "liked_gifts": ["flor", "libro"],
    "disliked_gifts": ["extrano"]
  },
  "doran": {
    "display_name": "Doran",
    "personality": "grunon",
    "loved_gifts": ["comida"],
    "liked_gifts": ["artesania"],
    "disliked_gifts": ["libro"]
  },
  "mira": {
    "display_name": "Mira",
    "personality": "impredecible",
    "loved_gifts": ["libro"],
    "liked_gifts": ["extrano", "flor"],
    "disliked_gifts": ["comida"]
  }
}

Cada escena/nodo NPC usa un npc_id, por ejemplo:

@export var npc_id: String = "lyria"

Ese npc_id se usa para cargar el perfil desde npcs.json.

La idea es que para agregar un nuevo NPC en el futuro:

Se agrega una entrada nueva en data/npcs.json.
Se crea o duplica una escena de NPC.
Se cambia el npc_id en el Inspector.
No se toca npc.gd salvo que se agregue una mecánica nueva.
data/items.json

Define items del juego, actualmente regalos.

Ejemplo:

{
  "comida": {
    "display_name": "Comida",
    "type": "gift",
    "starting_amount": 2
  },
  "flor": {
    "display_name": "Flor",
    "type": "gift",
    "starting_amount": 1
  },
  "joya": {
    "display_name": "Joya",
    "type": "gift",
    "starting_amount": 1
  },
  "libro": {
    "display_name": "Libro",
    "type": "gift",
    "starting_amount": 1
  },
  "artesania": {
    "display_name": "Artesanía",
    "type": "gift",
    "starting_amount": 1
  },
  "extrano": {
    "display_name": "Extraño",
    "type": "gift",
    "starting_amount": 1
  },
  "perfume": {
    "display_name": "Perfume",
    "type": "gift",
    "starting_amount": 1
  }
}

El menú de regalos ya es dinámico:

Lee los items con "type": "gift".
Crea botones automáticamente.
Muestra el display_name.
Muestra la cantidad actual desde PlayerStats.

Esto fue probado agregando perfume, y apareció automáticamente en el menú.

data/npc_personality_dialogues.json

Contiene diálogos por personalidad y contexto.

Personalidades actuales:

amable
grunon
impredecible

Contextos actuales principales:

first_happy
first_irritated
second_positive
second_negative
second_neutral
limit_happy
limit_irritated
limit_neutral

Se estaba trabajando en agregar contextos de regalos:

gift_loved
gift_liked
gift_neutral
gift_disliked
gift_already_received

Objetivo: que Lyria, Doran y Mira reaccionen de forma distinta a regalos según personalidad.

👥 NPCs actuales
Lyria

Personalidad:

amable

Idea de comportamiento:

Más fácil de agradar
Tiende más a estar feliz
Responde de forma cálida
Doran

Personalidad:

grunon

Idea de comportamiento:

Más difícil de agradar
Tiende más a estar irritado
Responde seco o brusco
Mira

Personalidad:

impredecible

Idea de comportamiento:

Reacciones más aleatorias
Mood más variable
Diálogos raros o excéntricos
❤️ Sistema de relaciones

El estado social ya fue movido fuera del NPC visual.

Archivo:

systems/relationship_system.gd

Este sistema guarda por npc_id:

affinity
mood
interaction_count
has_received_gift_today

Ejemplo conceptual:

{
  "lyria": {
    "affinity": 10,
    "mood": "happy",
    "interaction_count": 1,
    "has_received_gift_today": false
  }
}
Responsabilidad de RelationshipSystem

Se encarga de:

Crear estado de NPC si no existe
Obtener afinidad
Modificar afinidad
Obtener mood
Modificar mood
Contar interacciones diarias
Registrar si recibió regalo hoy
Resetear estado diario

Esto prepara el proyecto para:

Guardado/carga
Cambio de mapas
NPCs en distintas locaciones
Eventos por afinidad
Citas/romance
Horarios
🧍 scripts/npc.gd

Actualmente npc.gd representa al NPC visual/interactivo.

Responsabilidades actuales:

Exportar npc_id
Cargar perfil desde data/npcs.json
Cargar personalidad y gustos
Interactuar con el jugador
Pedir/mostrar diálogos
Calcular cambios de afinidad por conversación
Calcular cambios de afinidad por regalo
Usar RelationshipSystem para estado social

Ya NO debe guardar localmente:

affinity
mood
interaction_count
has_received_gift_today

Eso debe vivir en RelationshipSystem.

Pendiente cercano

Revisar si todavía existe:

func reset_daily_interactions() -> void:
    pass

Si existe, puede eliminarse porque el reset diario ya lo hace:

RelationshipSystem.reset_daily_state()

desde TimeSystem.

🎁 Sistema de regalos
Regalos actuales

Items tipo "gift" en data/items.json.

Ejemplos:

comida
flor
joya
libro
artesania
extrano
perfume
Menú de regalos

Archivo:

scripts/gift_menu.gd

Escena:

scenes/ui/gift_menu.tscn

El menú fue refactorizado para ser dinámico:

Usa un VBoxContainer llamado GiftButtonContainer.
Crea botones por código según los items tipo "gift".
Ya no depende de botones fijos como FoodButton, FlowerButton, etc.

Estructura esperada de escena:

GiftMenu
└── GiftPanel
    ├── TitleLabel
    └── GiftButtonContainer
Reglas actuales de regalos
1 regalo efectivo por NPC por día.
Si ya recibió regalo, debe responder con mensaje de bloqueo.
La afinidad cambia según gustos del NPC.

Valores base actuales:

loved -> +12
liked -> +6
neutral -> +1
disliked -> -8

También se suma modificador por suerte del jugador.

📦 Inventario

Archivo:

systems/player_stats.gd

El inventario inicial ya no está hardcodeado. Se carga desde:

data/items.json

usando:

DialogueDatabase.get_starting_inventory()

PlayerStats maneja:

Stats del jugador
Energía
Inventario
Gasto/restauración de energía
Obtener cantidad de item
Quitar item
🧠 Stats del jugador

Stats actuales:

strength
intelligence
dexterity
charisma
constitution
luck

También existen:

max_energy
current_energy
life_path

charisma y luck ya afectan interacciones sociales.

constitution afecta energía máxima.

🏋️ Actividades

Existen spots de actividad:

scripts/training_spot.gd
scripts/library_spot.gd

Actualmente la idea es:

Training Spot
Gasta energía
Sube fuerza
Sube constitución
Library Spot
Gasta energía
Sube inteligencia
Sube suerte

Pendiente futuro:
mover actividades a datos, por ejemplo:

data/activities.json

para poder agregar más lugares de entrenamiento sin tocar tantos scripts.

⏳ Sistema de tiempo

Archivo:

systems/time_system.gd

Función principal:

TimeSystem.next_day()

Al pasar el día:

Incrementa current_day
Restaura energía del jugador
Resetea estado diario en RelationshipSystem

El reset diario ya no debería buscar nodos NPC en escena.

Forma esperada:

func next_day() -> void:
    current_day += 1
    restore_player()
    RelationshipSystem.reset_daily_state()
🗣️ Sistema de diálogos

Archivo:

systems/dialogue_database.gd

Aunque se llama DialogueDatabase, actualmente carga:

Diálogos por personalidad
Perfiles de NPC
Items

Pendiente futuro:
renombrarlo a algo más general como:

GameDatabase

Pero no hacerlo todavía si puede romper demasiadas referencias. Primero estabilizar los sistemas.

💾 Guardado

Todavía NO hay sistema de guardado.

Más adelante se debe crear:

systems/save_system.gd

El guardado debería guardar:

current_day
player stats
player energy
inventory
relationships
event flags

Ejemplo futuro:

{
  "current_day": 12,
  "player": {
    "strength": 3,
    "intelligence": 5,
    "charisma": 2,
    "current_energy": 60,
    "inventory": {
      "comida": 1,
      "flor": 0
    }
  },
  "relationships": {
    "lyria": {
      "affinity": 30,
      "mood": "happy",
      "interaction_count": 1,
      "has_received_gift_today": false
    }
  }
}

El archivo de guardado debería vivir en:

user://save_game.json

No en /data.

🚧 Última tarea en curso

La última tarea que se estaba haciendo antes de parar fue:

Add personality-based gift dialogue and clean NPC script
Objetivo de esa tarea

Hacer que las respuestas a regalos dependan de personalidad.

Pendientes específicos:

Agregar constantes en GameConstants:
const DIALOGUE_GIFT_LOVED: String = "gift_loved"
const DIALOGUE_GIFT_LIKED: String = "gift_liked"
const DIALOGUE_GIFT_NEUTRAL: String = "gift_neutral"
const DIALOGUE_GIFT_DISLIKED: String = "gift_disliked"
const DIALOGUE_GIFT_ALREADY_RECEIVED: String = "gift_already_received"
Agregar esos contextos a data/npc_personality_dialogues.json dentro de cada personalidad:
amable
grunon
impredecible
Cambiar npc.gd para que:
Si el NPC ya recibió regalo, use diálogo por personalidad.
Si recibe un regalo amado/gustado/neutral/odiado, use diálogo por personalidad.
Siga mostrando afinidad actual al final.
Cambiar esta función:
func get_gift_response_text(gift_type: String, affinity_change: int, current_affinity: int) -> String:

por algo como:

func get_gift_response_text(affinity_change: int, current_affinity: int) -> String:
    var dialogue_context: String = get_gift_dialogue_context(affinity_change)
    var dialogue: String = get_personality_dialogue(dialogue_context)

    if dialogue == "":
        dialogue = get_default_gift_response_text(affinity_change)

    return dialogue + " Afinidad: " + str(current_affinity)
Agregar helpers:
func get_gift_dialogue_context(affinity_change: int) -> String:
    if affinity_change >= 10:
        return GameConstants.DIALOGUE_GIFT_LOVED
    elif affinity_change > 1:
        return GameConstants.DIALOGUE_GIFT_LIKED
    elif affinity_change == 1:
        return GameConstants.DIALOGUE_GIFT_NEUTRAL
    else:
        return GameConstants.DIALOGUE_GIFT_DISLIKED
func get_default_gift_response_text(affinity_change: int) -> String:
    if affinity_change >= 10:
        return "¿Esto es para mí? Me encanta."
    elif affinity_change > 1:
        return "Gracias, me gusta."
    elif affinity_change == 1:
        return "Gracias... supongo."
    else:
        return "Esto no me gusta."
Agregar:
func get_gift_already_received_text() -> String:
    var dialogue: String = get_personality_dialogue(GameConstants.DIALOGUE_GIFT_ALREADY_RECEIVED)

    if dialogue != "":
        return dialogue

    return "Ya me diste algo hoy."
Eliminar reset_daily_interactions() si todavía existe y solo contiene pass.
🧹 Limpiezas pendientes
Formateo

Hay archivos JSON con indentación irregular por pegado de bloques. No rompe el juego, pero conviene formatearlos.

Recomendación:

Usar VS Code para JSON.
Usar Shift + Alt + F en Windows para formatear documento.
En Godot, probar Ctrl + I para autoindentar GDScript.

Archivos a formatear:

data/items.json
data/npc_personality_dialogues.json
data/npcs.json
scripts/npc.gd
.godot

El archivo estructura.txt mostró que se versionó la carpeta .godot.

Más adelante revisar .gitignore y considerar no versionar cachés/editor local de Godot.

No tocar todavía si no es necesario.

🧭 Qué pedir en el siguiente chat

Copia y pega esto:

Continuemos con Another Life Project.

Lee el README.md del repo antes de responder.

Estamos haciendo un juego 2D en Godot 4 estilo SimGirls / Social Sim moderno. Ya movimos NPCs, items y diálogos a JSON, creamos RelationshipSystem, y el siguiente paso pendiente es terminar “Add personality-based gift dialogue and clean NPC script”.

Por favor revisa:
- scripts/npc.gd
- systems/game_constants.gd
- data/npc_personality_dialogues.json
- systems/relationship_system.gd
- scripts/gift_menu.gd
- systems/dialogue_database.gd

Quiero continuar paso a paso, sin asumir que sé dónde poner las cosas.
✅ Filosofía de arquitectura del proyecto

Este proyecto debe crecer evitando scripts gigantes.

Regla general:

Si es contenido editable → /data JSON
Si es estado de partida → sistema global y luego SaveSystem
Si es lógica de cálculo → systems
Si es comportamiento de una escena concreta → scripts

Objetivo:

Agregar contenido futuro como:

nuevo NPC romance
nuevo regalo
nueva personalidad
nueva actividad
nueva locación
evento por afinidad

sin tener que editar mil archivos ni duplicar lógica.