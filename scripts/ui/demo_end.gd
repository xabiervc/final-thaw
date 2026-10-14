extends Control
class_name DemoEnd

@export var title_label: Label
@export var summary_label: Label
@export var menu_button: Button
@export var restart_button: Button

var shelter: FloodedShelterController
var success: bool = false
var rescued: bool = false

func _ready() -> void:
	visible = false
	shelter = get_tree().get_first_node_in_group("flooded_shelter") as FloodedShelterController

	if menu_button:
		menu_button.text = NarrativeTextManager.get_end_button_menu()
		menu_button.pressed.connect(_on_menu_pressed)
	if restart_button:
		restart_button.text = NarrativeTextManager.get_end_button_restart()
		restart_button.pressed.connect(_on_restart_pressed)

	NarrativeTextManager.language_changed.connect(_on_language_changed)

func _exit_tree() -> void:
	if NarrativeTextManager.language_changed.is_connected(_on_language_changed):
		NarrativeTextManager.language_changed.disconnect(_on_language_changed)

func show_end(success_result: bool, rescued_civilian: bool) -> void:
	success = success_result
	rescued = rescued_civilian
	visible = true
	_update_text()

func _update_text() -> void:
	if title_label:
		title_label.text = NarrativeTextManager.get_end_title(success)
	if not summary_label:
		return

	var lines: Array[String] = [NarrativeTextManager.get_end_elena(success)]
	if shelter and shelter.civilian:
		lines.append(NarrativeTextManager.get_end_civilian(rescued, not shelter.civilian.is_alive, false))
	else:
		lines.append(NarrativeTextManager.get_end_civilian(false, false, true))

	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm:
		if gsm.get_flag("shelter_power_restored", false):
			lines.append(NarrativeTextManager.get_end_power_restored())
		if gsm.get_flag("shelter_valves_opened", false):
			lines.append(NarrativeTextManager.get_end_valves_opened())
		if gsm.get_flag("shelter_civilian_rescued", false):
			lines.append(NarrativeTextManager.get_end_civilian_rescued())
		elif shelter and shelter.civilian and not rescued:
			lines.append(NarrativeTextManager.get_end_civilian_not_rescued())

	summary_label.text = "\n".join(lines.filter(func(line: String) -> bool: return not line.is_empty()))

func _on_language_changed(_locale: String) -> void:
	if menu_button:
		menu_button.text = NarrativeTextManager.get_end_button_menu()
	if restart_button:
		restart_button.text = NarrativeTextManager.get_end_button_restart()
	if visible:
		_update_text()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
