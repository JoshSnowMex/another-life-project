# Another Life Project

## 📌 Descripción

Another Life Project es un juego 2D estilo **Life Sim / Social Sim inspirado en SimGirls**, donde el jugador vive una nueva vida en un mundo isekai llamado Lyndrall.

El enfoque actual del proyecto es construir un **sistema social profundo**, con:

- Relaciones dinámicas con NPCs
- Afinidad variable (-100 a 100)
- Estados emocionales (mood)
- Regalos con impacto real
- Sistema de tiempo diario
- Progresión de stats del jugador

---

## 🎮 Mecánicas implementadas

### 🧍 Movimiento
- Movimiento en 2D top-down con WASD

---

### 💬 Sistema de diálogo
- Interacción con NPCs usando tecla `F`
- Diálogo dinámico basado en afinidad y estado emocional

---

### ❤️ Sistema de relaciones
Cada NPC tiene:

- Afinidad: `-100 a 100`
- Mood:
  - `happy`
  - `neutral`
  - `irritated`

#### Interacciones diarias:
- 1ra interacción → muestra estado/mood
- 2da interacción → modifica afinidad
- 3ra+ → bloqueada (no cambia nada)

---

### 🎁 Sistema de regalos
- Menú de regalos con tecla `E`
- Selección con mouse
- Inventario real

Tipos de regalo:

- comida
- flor
- joya
- libro
- artesania
- extrano

#### Reglas:
- 1 regalo efectivo por NPC por día
- Gustos:
  - loved → +12 afinidad
  - liked → +6 afinidad
  - neutral → +1
  - disliked → -8

---

### 📦 Inventario
Gestionado desde `PlayerStats`:

```gdscript
inventory = {
	"comida": 2,
	"flor": 1,
	...
}

🧠 Sistema de stats del jugador
Fuerza
Inteligencia
Destreza
Carisma
Constitución
Suerte
Energía

Los stats afectan:

Interacciones sociales
Resultados RNG
Progresión
🏋️ Actividades
Training Spot
Gasta energía
+Fuerza
+Constitución
Library Spot
Gasta energía
+Inteligencia
+Suerte
⏳ Sistema de tiempo

Tecla: T

Al pasar el día:

Se restaura energía
Se reinician interacciones
Se reinician regalos
👥 NPCs actuales
Lyria
Amable
Le gusta: flor, libro
Ama: joya
Doran
Gruñón
Le gusta: artesania
Ama: comida
Odia: libro
Mira
Curiosa
Le gusta: extraño, flor
Ama: libro
Odia: comida

🧱 Arquitectura
Scripts principales

/systems
  player_stats.gd
  time_system.gd

/scripts
  npc.gd
  player.gd
  training_spot.gd
  library_spot.gd
  gift_menu.gd
  dialogue_box.gd
  stats_hud.gd

Escenas
/scenes
  /world
  /npc
  /player
  /ui

🎯 Estado actual del proyecto

El proyecto cuenta con un vertical slice funcional, incluyendo:

Loop diario completo
Sistema social base
Sistema de progreso
UI básica
Inventario funcional
🚀 Próximos pasos
Sistema de personalidad en NPCs
Panel de información de NPCs (conocimiento descubierto)
Eventos por afinidad
Más locaciones
Sistema de citas / preguntas tipo SimGirls

---

# 🧭 Qué pedir en el siguiente chat

Copia y pega algo así:

```text
Estamos desarrollando un juego en Godot 4 estilo SimGirls / Life Sim.

Ya tenemos:
- NPCs con afinidad, mood y regalos
- Inventario
- Sistema de tiempo
- Actividades
- UI básica

Queremos continuar con:
👉 sistema de personalidad de NPCs (Lyria amable, Doran gruñón, Mira impredecible)
y que eso afecte el mood, reacciones y RNG.
