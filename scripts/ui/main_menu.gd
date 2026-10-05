extends Control
class_name MainMenu

@export var title_label: Label
@export var context_label: Label
@export var start_button: Button

func _ready() -> void:
	if title_label:
		title_label.text = "Final Thaw\nVertical Slice"
	if context_label:
		context_label.text = (
			"Año 2047. El colapso climático ha sumido a las ciudades en caos. " +
			"Elena Vast, científica del Aster, y Marcus Reyes, oficial de seguridad, " +
			"deben cooperar para salvar lo que queda de la humanidad."
		)
	if start_button:
		start_button.pressed.connect(_on_start_pressed)

	_update_context_with_flags()

func _update_context_with_flags() -> void:
	var gsm = GameStateManager if "GameStateManager" in get_tree()
	if not gsm or not context_label:
		return

	var extra := ""
	if gsm.get_flag("shelter_power_restored", false):
		extra += "\n- Refugio: energía restaurada."
	if gsm.get_flag("shelter_valves_opened", false):
		extra += "\n- Refugio: válvulas abiertas."
	if gsm.get_flag("shelter_civilian_rescued", false):
		extra += "\n- Refugio: civil rescatada."

	if extra != "":
		context_label.text += "\n\nEstado previo:\n" + extra

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/flooded_shelter_2_5d.tscn")
