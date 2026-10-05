extends Control
class_name MainMenu

@export var title_label: Label
@export var context_label: Label
@export var start_button: Button
@export var lang_es_button: Button
@export var lang_en_button: Button

var current_locale: String = "es"

func _ready() -> void:
	_load_language_preference()
	_setup_language_buttons()
	_apply_language(current_locale)

func _load_language_preference() -> void:
	var gsm = GameStateManager if "GameStateManager" in get_tree()
	if gsm:
		current_locale = gsm.get_flag("ui_language_es", true) if gsm.get_flag("ui_language_es", true) else "es"
		if gsm.get_flag("ui_language_en", false):
			current_locale = "en"

func _setup_language_buttons() -> void:
	if lang_es_button:
		lang_es_button.pressed.connect(_on_lang_es_pressed)
	if lang_en_button:
		lang_en_button.pressed.connect(_on_lang_en_pressed)

func _apply_language(locale: String) -> void:
	current_locale = locale
	NarrativeTextManager.set_locale(locale)

	# Save preference
	var gsm = GameStateManager if "GameStateManager" in get_tree()
	if gsm:
		gsm.set_flag("ui_language_es", locale == "es")
		gsm.set_flag("ui_language_en", locale == "en")

	# Refresh UI
	if title_label:
		title_label.text = NarrativeTextManager.get_menu_title()
	if context_label:
		context_label.text = NarrativeTextManager.get_menu_context()
		_update_context_with_flags()
	if start_button:
		start_button.text = NarrativeTextManager.get_menu_start_button()

func _update_context_with_flags() -> void:
	var gsm = GameStateManager if "GameStateManager" in get_tree()
	if not gsm or not context_label:
		return

	var extra := ""
	if gsm.get_flag("shelter_power_restored", false):
		extra += "\n- " + (_refuge_power_text())
	if gsm.get_flag("shelter_valves_opened", false):
		extra += "\n- " + (_refuge_valves_text())
	if gsm.get_flag("shelter_civilian_rescued", false):
		extra += "\n- " + (_refuge_civilian_text())

	if extra != "":
		context_label.text += "\n\n" + _state_prev_text() + "\n" + extra

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
