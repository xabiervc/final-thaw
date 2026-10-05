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
		oxygen_label.text = NarrativeTextManager.get_hud_oxygen_label(100.0 * value / max_value)

func update_objective() -> void:
	if not objective_label or not shelter:
		return

	var civilian_exists := shelter.civilian != null
	var civilian_trapped := civilian_exists and shelter.civilian.state == Civilian.State.TRAPPED

	var text := NarrativeTextManager.get_hud_objective(
		shelter.has_power,
		shelter.valves_open,
		civilian_exists,
		civilian_trapped
	)
	objective_label.text = text

func _on_power_restored() -> void:
	update_objective()

func _on_valves_progress(open_count: int) -> void:
	update_objective()

func _on_civilian_status(rescued: bool) -> void:
	if civilian_label and shelter and shelter.civilian:
		var trapped := shelter.civilian.state == Civilian.State.TRAPPED
		var dead := not shelter.civilian.is_alive
		civilian_label.text = NarrativeTextManager.get_hud_civilian_state(trapped, rescued, dead)
	update_objective()

func _on_level_completed(success: bool, rescued_civilian: bool) -> void:
	if not objective_label:
		return
	if success:
		var civil_state := NarrativeTextManager.get_hud_civilian_state(false, rescued_civilian, false)
		objective_label.text = "Demo completada - " + civil_state
	else:
		objective_label.text = "Demo fallida - Elena no sobrevivió"
