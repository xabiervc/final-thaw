extends Control
class_name MainMenu

const LEVEL_PATH := "res://scenes/levels/elena_test_room.tscn"
const BOX := "CenterContainer/Panel/MarginContainer/VBoxContainer"

@onready var title_label: Label = get_node(BOX + "/TitleLabel")
@onready var context_label: Label = get_node(BOX + "/ContextLabel")
@onready var start_button: Button = get_node(BOX + "/StartButton")
@onready var lang_es_button: Button = get_node(BOX + "/LanguageRow/LangESButton")
@onready var lang_en_button: Button = get_node(BOX + "/LanguageRow/LangENButton")

var current_locale: String = "es"
var base_context: String = ""

func _ready() -> void:
	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state != null and game_state.get_flag("ui_language_en", false):
		current_locale = "en"

	context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	context_label.custom_minimum_size = Vector2(620, 170)
	context_label.add_theme_font_size_override("font_size", 18)

	lang_es_button.pressed.connect(_on_lang_es_pressed)
	lang_en_button.pressed.connect(_on_lang_en_pressed)
	start_button.pressed.connect(_on_start_pressed)
	start_button.grab_focus()
	_apply_language(current_locale)

func _apply_language(locale: String) -> void:
	current_locale = locale
	NarrativeTextManager.set_locale(locale)

	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state != null:
		game_state.set_flag("ui_language_es", locale == "es")
		game_state.set_flag("ui_language_en", locale == "en")

	title_label.text = _title_text()
	base_context = _context_text()
	start_button.text = _start_text()
	_refresh_context()

func _title_text() -> String:
	var t: String = NarrativeTextManager.get_menu_title().replace("\n", " - ")
	return t if not t.is_empty() else "FINAL THAW"

func _context_text() -> String:
	var t: String = NarrativeTextManager.get_menu_context().strip_edges()
	if not t.is_empty():
		return t
	if current_locale == "es":
		return "Año 2047. El colapso climático ha sumido a las ciudades en caos."
	return "Year 2047. Climate collapse has plunged cities into chaos."

func _start_text() -> String:
	var t: String = NarrativeTextManager.get_menu_start_button()
	if not t.is_empty():
		return t
	return "Iniciar Demo" if current_locale == "es" else "Start Demo"

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
	get_tree().change_scene_to_file(LEVEL_PATH)
