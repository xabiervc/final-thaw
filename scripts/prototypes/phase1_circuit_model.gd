extends RefCounted
## Isolated reference implementation of FASE1_LOGIC_CONTRACT.md.
## No autoloads, world changes, save schema, extraction or narrative.

const TRIAL := "ENSAYO"
const ARCHIVE := "ARCHIVO"
const TRIP_CAUSE := "DEMANDA_SIMULTANEA"

var maintenance_on: bool = false
var destination: String = TRIAL
var trial_isolated: bool = false
var protection_available: bool = true
var last_trip: String = "" # Empty means no recorded trip.
var _knowledge: Dictionary = {}


func fault_present() -> bool:
	return destination == ARCHIVE and not trial_isolated


func set_maintenance(on: bool) -> void:
	maintenance_on = on


func select_destination(value: String) -> bool:
	if value != TRIAL and value != ARCHIVE:
		return false
	destination = value
	_evaluate_protection()
	return true


func set_isolated(on: bool) -> void:
	trial_isolated = on
	_evaluate_protection()


func _evaluate_protection() -> void:
	if protection_available and fault_present():
		protection_available = false
		last_trip = TRIP_CAUSE


func rearm() -> bool:
	if fault_present():
		return false
	protection_available = true
	return true


func outputs() -> Dictionary:
	return {
		"diagnostic": true,
		"maintenance": maintenance_on,
		"archive": protection_available and destination == ARCHIVE and trial_isolated,
		"trial": protection_available and destination == TRIAL and not trial_isolated,
		"machine_running": false,
	}


func inspect() -> Dictionary:
	var current := "ARCHIVE_UNPOWERED"
	if not protection_available:
		current = "RECOVERY_TRIPPED_FAULT_PRESENT" if fault_present() else "RECOVERY_TRIPPED_REARM_PENDING"
	elif outputs()["archive"]:
		current = "ARCHIVE_STABLE"
	return {"current": current, "destination": destination, "last_trip": last_trip}


func consult() -> bool:
	if not outputs()["archive"]:
		return false
	_knowledge["REFERENCE_CLUE"] = true
	return true


func known_clues() -> Array:
	return _knowledge.keys()


func snapshot() -> Dictionary:
	return {
		"maintenance": maintenance_on, "destination": destination,
		"isolated": trial_isolated, "protection": protection_available,
		"last_trip": last_trip, "knowledge": _knowledge.duplicate(),
	}
