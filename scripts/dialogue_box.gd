extends CanvasLayer

const MAX_CHARACTERS_PER_PAGE: int = 170

@onready var name_label: Label = $DialoguePanel/NameLabel
@onready var dialogue_label: Label = $DialoguePanel/DialogueLabel

var current_speaker_name: String = ""
var pages: Array[String] = []
var current_page_index: int = 0

func _ready() -> void:
	visible = false

func show_dialogue(speaker_name: String, text: String) -> void:
	current_speaker_name = speaker_name
	pages = split_text_into_pages(text, MAX_CHARACTERS_PER_PAGE)
	current_page_index = 0

	if pages.is_empty():
		pages.append("")

	show_current_page()
	visible = true

func hide_dialogue() -> void:
	visible = false
	pages.clear()
	current_page_index = 0
	current_speaker_name = ""

func is_open() -> bool:
	return visible

func advance_dialogue() -> bool:
	if not visible:
		return false

	if current_page_index < pages.size() - 1:
		current_page_index += 1
		show_current_page()
		return true

	hide_dialogue()
	return false

func show_current_page() -> void:
	name_label.text = current_speaker_name

	var page_text: String = pages[current_page_index]

	if pages.size() > 1:
		page_text += "\n[" + str(current_page_index + 1) + "/" + str(pages.size()) + "]"

	dialogue_label.text = page_text

func split_text_into_pages(text: String, max_characters: int) -> Array[String]:
	var result: Array[String] = []
	var words: PackedStringArray = text.split(" ")
	var current_page: String = ""

	for word in words:
		var candidate: String = word

		if current_page != "":
			candidate = current_page + " " + word

		if candidate.length() > max_characters and current_page != "":
			result.append(current_page)
			current_page = word
		else:
			current_page = candidate

	if current_page != "":
		result.append(current_page)

	return result
