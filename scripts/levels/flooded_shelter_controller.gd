extends Node
class_name FloodedShelterController

@export var elena: Elena
@export var civilian: Civilian

@export var power_console: Node
@export var valve_station_left: Node
@export var valve_station_right: Node
@export var flood_gate_exit: Node

@export var oxygen_refill_on_power: float = 40.0
@export var oxygen_refill_on_valves: float = 30.0

var has_power: bool = false
var valves_open: int = 0
var civilian_rescued: bool = false
var level_complete: bool = false

signal power_restored
signal valves_progress_changed(open_count: int)
signal civilian_status_changed(rescued: bool)
signal level_completed(success: bool, rescued_civilian: bool)

func _ready() -> void:
	add_to_group("flooded_shelter")

	if power_console:
		power_console.connect("power_activated", _on_power_activated)
	if valve_station_left:
		valve_station_left.connect("valve_opened", _on_valve_opened)
	if valve_station_right:
		valve_station_right.connect("valve_opened", _on_valve_opened)
	if civilian:
		civilian.connect("civilian_rescued", _on_civilian_rescued)
	if elena:
		elena.player_died.connect(_on_elena_died)

	restore_from_persistence()
	_emit_initial_state()

func _on_elena_died() -> void:
	complete_level(false)

func _emit_initial_state() -> void:
	if has_power:
		power_restored.emit()
	valves_progress_changed.emit(valves_open)
	civilian_status_changed.emit(civilian_rescued)

	if elena:
		elena.oxygen_changed.emit(elena.oxygen)

func _on_power_activated() -> void:
	if has_power:
		return
	has_power = true
	if elena:
		elena.add_oxygen(oxygen_refill_on_power)
	power_restored.emit()

func _on_valve_opened() -> void:
	valves_open = mini(2, valves_open + 1)
	if elena and valves_open == 1:
		elena.add_oxygen(oxygen_refill_on_valves)
	valves_progress_changed.emit(valves_open)
	if valves_open >= 2 and flood_gate_exit:
		flood_gate_exit.open_gate()

func _on_civilian_rescued() -> void:
	civilian_rescued = true
	civilian_status_changed.emit(true)

func complete_level(success: bool = true) -> void:
	if level_complete:
		return
	level_complete = true
	persist_state()
	level_completed.emit(success, civilian_rescued)

func get_persistent_state() -> Dictionary:
	return {
		"shelter_power_restored": has_power,
		"shelter_valves_opened": valves_open >= 2,
		"shelter_civilian_rescued": civilian_rescued
	}

func persist_state() -> void:
	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm == null:
		return
	var data := get_persistent_state()
	for key in data:
		gsm.set_flag(key, data[key])

func restore_from_persistence() -> void:
	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm == null:
		return
	has_power = gsm.get_flag("shelter_power_restored", false)
	if gsm.get_flag("shelter_valves_opened", false):
		valves_open = 2
	else:
		valves_open = 0
	civilian_rescued = gsm.get_flag("shelter_civilian_rescued", false)

	if valves_open >= 2 and flood_gate_exit:
		flood_gate_exit.open_gate()
