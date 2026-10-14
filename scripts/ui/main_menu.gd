extends Control
class_name MainMenu

const LEVEL_PATH := "res://scenes/levels/elena_test_room.tscn"
const OPTIONS_PATH := "res://scenes/ui/options_menu.tscn"
const CREDITS_PATH := "res://scenes/ui/credits.tscn"
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
	_apply_font_scale()

	lang_es_button.pressed.connect(_on_lang_es_pressed)
	lang_en_button.pressed.connect(_on_lang_en_pressed)
	start_button.pressed.connect(_on_start_pressed)
	start_button.grab_focus()
	_create_secondary_buttons()
	_apply_language(current_locale)

func _create_secondary_buttons() -> void:
	var box: VBoxContainer = get_node(BOX)
	var row := HBoxContainer.new()
	row.name = "SecondaryRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	box.move_child(row, box.get_child_count() - 1)

	var options_button := Button.new()
	options_button.name = "OptionsButton"
	options_button.text = _options_text()
	options_button.custom_minimum_size = Vector2(160, 42)
	options_button.add_to_group("menu_button")
	options_button.pressed.connect(_on_options_pressed)
	row.add_child(options_button)

	var credits_button := Button.new()
	credits_button.name = "CreditsButton"
	credits_button.text = _credits_text()
	credits_button.custom_minimum_size = Vector2(160, 42)
	credits_button.add_to_group("menu_button")
	credits_button.pressed.connect(_on_credits_pressed)
	row.add_child(credits_button)

	start_button.add_to_group("menu_button")
	lang_es_button.add_to_group("menu_button")
	lang_en_button.add_to_group("menu_button")

func _apply_font_scale() -> void:
	var scale := clampf(GameManager.font_scale, 0.75, 2.0)
	title_label.add_theme_font_size_override("font_size", int(48.0 * scale))
	context_label.add_theme_font_size_override("font_size", int(18.0 * scale))
	start_button.add_theme_font_size_override("font_size", int(22.0 * scale))
	lang_es_button.add_theme_font_size_override("font_size", int(18.0 * scale))
	lang_en_button.add_theme_font_size_override("font_size", int(18.0 * scale))

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
	_refresh_secondary_buttons()

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

func _options_text() -> String:
	var t: String = NarrativeTextManager.get_menu_options_button()
	return t if not t.is_empty() else ("Opciones" if current_locale == "es" else "Options")

func _credits_text() -> String:
	var t: String = NarrativeTextManager.get_menu_credits_button()
	return t if not t.is_empty() else ("Créditos" if current_locale == "es" else "Credits")

func _refresh_context() -> void:
	var lines: Array[String] = [base_context]
	var game_state = get_node_or_null("/root/GameStateManager")
	if game_state != null:
		var prior: Array[String] = []
		if game_state.get_flag("shelter_power_restored", false):
			prior.append(NarrativeTextManager.get_shelter_state_power(true))
		if game_state.get_flag("shelter_valves_opened", false):
			prior.append(NarrativeTextManager.get_shelter_state_valves(true))
		if game_state.get_flag("shelter_civilian_rescued", false):
			prior.append(NarrativeTextManager.get_shelter_civilian_state_short())
		if not prior.is_empty():
			lines.append(NarrativeTextManager.get_shelter_previous_state() + "\n" + "\n".join(prior))
	context_label.text = "\n\n".join(lines)

func _refresh_secondary_buttons() -> void:
	var options_button := get_node_or_null(BOX + "/SecondaryRow/OptionsButton") as Button
	var credits_button := get_node_or_null(BOX + "/SecondaryRow/CreditsButton") as Button
	if options_button != null:
		options_button.text = _options_text()
	if credits_button != null:
		credits_button.text = _credits_text()

func _on_lang_es_pressed() -> void:
	_apply_language("es")

func _on_lang_en_pressed() -> void:
	_apply_language("en")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_PATH)

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file(OPTIONS_PATH)

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(CREDITS_PATH)
