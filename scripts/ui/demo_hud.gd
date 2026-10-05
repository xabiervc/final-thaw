extends CanvasLayer
class_name DemoHUD

@export var oxygen_label: Label
@export var objective_label: Label
@export var civilian_label: Label

var shelter: FloodedShelterController

func _ready() -> void:
	shelter = get_tree().get_first_node_in_group("flooded_shelter")
	if not shelter:
		return

	shelter.power_restored.connect(_on_power_restored)
	shelter.valves_progress_changed.connect(_on_valves_progress)
	shelter.civilian_status_changed.connect(_on_civilian_status)
	shelter.level_completed.connect(_on_level_completed)

	update_objective()

func update_oxygen(value: float, max_value: float) -> void:
	if oxygen_label:
		oxygen_label.text = "Oxígeno: %d%%" % int(100.0 * value / max_value)

func update_objective() -> void:
	if not objective_label or not shelter:
		return

	if not shelter.has_power:
		objective_label.text = "Objetivo: Activa el generador"
	elif shelter.valves_open < 2:
		objective_label.text = "Objetivo: Abre las válvulas para drenar el agua"
	elif shelter.civilian and shelter.civilian.state == Civilian.State.TRAPPED:
		objective_label.text = "Objetivo: Decide si rescatas a la civil antes de salir"
	else:
		objective_label.text = "Objetivo: Alcanza la salida"

func _on_power_restored() -> void:
	update_objective()

func _on_valves_progress(open_count: int) -> void:
	update_objective()

func _on_civilian_status(rescued: bool) -> void:
	if civilian_label:
		civilian_label.text = "Civil: " + ("Rescatada" if rescued else "Atrapada")
	update_objective()

func _on_level_completed(success: bool, rescued_civilian: bool) -> void:
	if not objective_label:
		return
	if success:
		objective_label.text = "Demo completada - Civil: " + ("Rescatada" if rescued_civilian else "No rescatada")
	else:
		objective_label.text = "Demo fallida - Elena no sobrevivió"
