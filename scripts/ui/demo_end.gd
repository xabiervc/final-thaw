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
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)

func show_end(success_result: bool, rescued_civilian: bool) -> void:
	success = success_result
	rescued = rescued_civilian
	visible = true
	_update_text()

func _update_text() -> void:
	if title_label:
		title_label.text = "Demo completada" if success else "Demo fallida"

	if not summary_label:
		return

	var lines := []
	lines.append("Elena: " + ("Sobrevivió" if success else "No sobrevivió"))
	lines.append("Civil: " + ("Rescatada" if rescued else "No rescatada"))

	var gsm = GameStateManager if "GameStateManager" in get_tree()
	if gsm:
		if gsm.get_flag("shelter_power_restored", false):
			lines.append("Refugio: energía restaurada")
		if gsm.get_flag("shelter_valves_opened", false):
			lines.append("Refugio: válvulas abiertas")

	summary_label.text = "\n".join(lines)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_restart_pressed() -> void:
	# Simple restart: reload current scene
	get_tree().reload_current_scene()
