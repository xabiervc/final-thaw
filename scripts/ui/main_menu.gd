extends Control
class_name MainMenu

@onready var title_label: Label = get_node_or_null("MarginContainer/VBoxContainer/TitleLabel")
@onready var context_label: Label = get_node_or_null("MarginContainer/VBoxContainer/ContextLabel")
@onready var start_button: Button = get_node_or_null("MarginContainer/VBoxContainer/StartButton")
@onready var lang_es_button: Button = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/LangESButton")
@onready var lang_en_button: Button = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/LangENButton")

var current_locale: String = "es"

func _ready() -> void:
	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state != null:
		if game_state.get_flag("ui_language_en", false):
			current_locale = "en"
		else:
			current_locale = "es"

	if lang_es_button != null:
		lang_es_button.pressed.connect(_on_lang_es_pressed)
	if lang_en_button != null:
		lang_en_button.pressed.connect(_on_lang_en_pressed)
	if start_button != null:
		start_button.pressed.connect(_on_start_pressed)

	_apply_language(current_locale)

func _apply_language(locale: String) -> void:
	current_locale = locale
	var narrative = get_node_or_null("/root/NarrativeTextManager")
	if narrative == null:
		push_error("NarrativeTextManager autoload is missing.")
		return
	narrative.set_locale(locale)

	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state != null:
		game_state.set_flag("ui_language_es", locale == "es")
		game_state.set_flag("ui_language_en", locale == "en")

	if title_label != null:
		title_label.text = narrative.get_menu_title()
	if context_label != null:
		context_label.text = narrative.get_menu_context()
		_update_context_with_flags()
	if start_button != null:
		start_button.text = narrative.get_menu_start_button()

func _update_context_with_flags() -> void:
	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state == null or context_label == null:
		return

	var extra := ""
	if game_state.get_flag("shelter_power_restored", false):
		extra += "\n- " + _refuge_power_text()
	if game_state.get_flag("shelter_valves_opened", false):
		extra += "\n- " + _refuge_valves_text()
	if game_state.get_flag("shelter_civilian_rescued", false):
		extra += "\n- " + _refuge_civilian_text()

	if not extra.is_empty():
		context_label.text += "\n\n" + _state_prev_text() + "\n" + extra

func _refuge_power_text() -> String:
	if current_locale == "es":
		return "Refugio: energía restaurada."
	return "Shelter: power restored."

func _refuge_valves_text() -> String:
	if current_locale == "es":
		return "Refugio: válvulas abiertas."
	return "Shelter: valves opened."

func _refuge_civilian_text() -> String:
	if current_locale == "es":
		return "Refugio: civil rescatada."
	return "Shelter: civilian rescued."

func _state_prev_text() -> String:
	if current_locale == "es":
		return "Estado previo:"
	return "Previous state:"

func _on_lang_es_pressed() -> void:
	_apply_language("es")

func _on_lang_en_pressed() -> void:
	_apply_language("en")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/flooded_shelter_2_5d.tscn")
