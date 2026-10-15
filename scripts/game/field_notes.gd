extends RefCounted
## Elena's field notes: the investigation as state, not as text dumps.
##
## Observations are recorded when the player actually examines, scans or causes something. Inferences are DERIVED
## from observations, never granted: the hypothesis appears only once the intended schematic and a physical
## contradiction (the bridge, or the scanner's continuity reading) have both been observed; the test result
## appears only after the player provokes a real trip; the conclusion needs the restricted record.
## The notes never name the control to use or the order of operations: they record what Elena knows.
## Session-only (mission state contract): nothing here is written to the save file.

signal noted(id: String, kind: String)  # kind: "observation" | "inference" | "event"

const T := preload("res://scripts/game/game_text.gd")

## Display order (inferences sit right after the observations that support them).
const ORDER := ["anomaly", "official_report", "access_plan", "schematic", "bridge", "workshop_tag", "scan_bridge", "hypothesis",
	"maintenance_risk", "trip", "test_result", "archive_stable", "record", "conclusion", "containment", "unit",
	"exit_plan", "parking", "parking_devices"]

var _have: Dictionary = {}


func has(id: String) -> bool:
	return _have.has(id)


## Records an observation or event once; returns true the first time. Derives any inference it unlocks.
func add(id: String, kind: String = "observation") -> bool:
	if _have.has(id):
		return false
	_have[id] = kind
	noted.emit(id, kind)
	_derive()
	return true


func _derive() -> void:
	if not _have.has("hypothesis") and _have.has("schematic") and (_have.has("bridge") or _have.has("scan_bridge")):
		_add_inference("hypothesis")
	if not _have.has("test_result") and _have.has("hypothesis") and _have.has("trip"):
		_add_inference("test_result")
	if not _have.has("conclusion") and _have.has("record"):
		_add_inference("conclusion")


func _add_inference(id: String) -> void:
	_have[id] = "inference"
	noted.emit(id, "inference")


func count() -> int:
	return _have.size()


func ids() -> Array:
	var out: Array = []
	for id in ORDER:
		if _have.has(id):
			out.append(id)
	return out


## Entries for the pause menu, in reading order: {"title", "body"}.
func entries() -> Array:
	var out: Array = []
	for id in ids():
		out.append({"title": T.t("note_%s_title" % id), "body": T.t("note_%s_body" % id), "kind": _have[id]})
	return out


func to_dict() -> Dictionary:
	return _have.duplicate()
