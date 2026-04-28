extends CanvasLayer

@onready var name_label: Label = $DialoguePanel/NameLabel
@onready var dialogue_label: Label = $DialoguePanel/DialogueLabel

func _ready() -> void:
	visible = false

func show_dialogue(speaker_name: String, text: String) -> void:
	name_label.text = speaker_name
	dialogue_label.text = text
	visible = true

func hide_dialogue() -> void:
	visible = false

func is_open() -> bool:
	return visible
