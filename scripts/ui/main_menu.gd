extends Control
class_name MainMenu

@onready var title_label: Label = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/TitleLabel")
@onready var context_label: Label = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/ContextLabel")
@onready var start_button: Button = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/StartButton")
@onready var lang_es_button: Button = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/LanguageRow/LangESButton")
@onready var lang_en_button: Button = get_node("CenterContainer/Panel/MarginContainer/VBoxContainer/LanguageRow/LangENButton")

var current_locale: String = "es"
var base_context: String = ""

func _ready() -> void:
	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state != null and game_state.get_flag("ui_language_en", false):
		current_locale = "en"

	base_context = NarrativeTextManager.get_menu_context()
	context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	context_label.custom_minimum_size = Vector2(620, 170)
	context_label.add_theme_font_size_override("font_size", 20)

	lang_es_button.pressed.connect(_on_lang_es_pressed)
	lang_en_button.pressed.connect(_on_lang_en_pressed)
	start_button.pressed.connect(_on_start_pressed)
	_apply_language(current_locale)

func _apply_language(locale: String) -> void:
	current_locale = locale
	NarrativeTextManager.set_locale(locale)

	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state != null:
		game_state.set_flag("ui_language_es", locale == "es")
		game_state.set_flag("ui_language_en", locale == "en")

	title_label.text = NarrativeTextManager.get_menu_title()
	base_context = NarrativeTextManager.get_menu_context()
	start_button.text = NarrativeTextManager.get_menu_start_button()
	_refresh_context()

func _refresh_context() -> void:
	var lines: Array[String] = [base_context]
	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state != null:
		var prior: Array[String] = []
		if game_state.get_flag("shelter_power_restored", false):
			prior.append(_refuge_power_text())
		if game_state.get_flag("shelter_valves_opened", false):
			prior.append(_refuge_valves_text())
		if game_state.get_flag("shelter_civilian_rescued", false):
			prior.append(_refuge_civilian_text())
		if not prior.is_empty():
			lines.append(_state_prev_text() + "\n" + "\n".join(prior))
	context_label.text = "\n\n".join(lines)

func _refuge_power_text() -> String:
	return "Refugio: energía restaurada." if current_locale == "es" else "Shelter: power restored."

func _refuge_valves_text() -> String:
	return "Refugio: válvulas abiertas." if current_locale == "es" else "Shelter: valves opened."

func _refuge_civilian_text() -> String:
	return "Refugio: civil rescatada." if current_locale == "es" else "Shelter: civilian rescued."

func _state_prev_text() -> String:
	return "Estado previo:" if current_locale == "es" else "Previous state:"

func _on_lang_es_pressed() -> void:
	_apply_language("es")

func _on_lang_en_pressed() -> void:
	_apply_language("en")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/flooded_shelter_2_5d.tscn")
