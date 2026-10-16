extends RefCounted
## Phase 1 progression of the expanded facility (docs/design/fase1_fase2_mapa_progresion.md v2.1, FASE1_SPATIAL_GRAPH.md v3.1):
## two parallel chains that converge, with the Aster investigation, at the transfer door in P-2.
##
##   A. SERVICE POWER   code 0437 -> drawer -> SERVICE_KEY + INSULATED_BRIDGE -> substation door -> bridge in the LIFT AUX
##                      terminal -> disconnector -> PowerRestored.
##   B. TRANSFER        anomaly in the dead workshop -> HiddenDoorDiscovered; maintenance note -> dry cabinet in the spares
##                      store -> TRANSFER_KEY.
##   Convergence        HiddenDoorDiscovered + TRANSFER_KEY + PowerRestored + RESTRICTED_RECORD_READ -> the door opens.
##
## Deliberately separate from the circuit model (FASE1_LOGIC_CONTRACT.md) and from phase1_mission_state.gd: nothing here
## changes circuit outputs, protection history, SERVICE_OVERRIDE or the field-note derivations. RESTRICTED_RECORD_READ
## stays owned by the mission state; this model only receives it as an argument. Session-only by contract (no save change),
## but to_dict()/from_dict() round-trip every flag so a later save can persist them without duplicating anything.

## Canonical item ids (the design documents' names; do not invent competing ones).
const SERVICE_KEY := "SERVICE_KEY"
const INSULATED_BRIDGE := "INSULATED_BRIDGE"
const TRANSFER_KEY := "TRANSFER_KEY"

## The drawer code is derived, never stored as text in the world: the shift board lists the order in which the test
## readings are taken and the pressure strip prints the last stable reading of each point.
const TEST_ORDER := ["B", "D", "A", "C"]
const STABLE_READINGS := {"A": 3, "B": 0, "C": 7, "D": 4}

## Reasons the transfer door can refuse, in the order they are reported (all missing ones are listed, never just one).
const DOOR_OK := "OK"
const DOOR_UNDISCOVERED := "UNDISCOVERED"
const DOOR_NO_KEY := "NO_KEY"
const DOOR_NO_POWER := "NO_POWER"
const DOOR_NO_RECORD := "NO_RECORD"

## Items the player carries (ids), in pickup order. A set in effect: an item is never duplicated.
var items: Array[String] = []
var drawer_open: bool = false
var drawer_emptied: bool = false
var substation_unlocked: bool = false
var bridge_inserted: bool = false
var power_restored: bool = false
var hidden_door_discovered: bool = false
var maintenance_note_read: bool = false
var cabinet_opened: bool = false
var transfer_door_open: bool = false
## Counters for the tests and the results (a repeated interaction must not count twice).
var wrong_codes: int = 0


## The code the clues lead to: the stable readings read in the shift board's order. "0437".
static func solution() -> String:
	var out := ""
	for point in TEST_ORDER:
		out += str(int(STABLE_READINGS[point]))
	return out


func has_item(id: String) -> bool:
	return id in items


func _give(id: String) -> bool:
	if id in items:
		return false
	items.append(id)
	return true


# --- chain A: service power -----------------------------------------------------------------------------------------

## "ok" (opened now), "already" (it was open), "wrong" (counts one attempt), "malformed" (not four digits).
func try_drawer_code(code: String) -> String:
	if drawer_open:
		return "already"
	if code.length() != 4 or not code.is_valid_int():
		return "malformed"
	if code != solution():
		wrong_codes += 1
		return "wrong"
	drawer_open = true
	return "ok"


## Takes what is in the open drawer. Returns the item ids newly obtained ([] when closed or already emptied).
func take_drawer_items() -> Array[String]:
	var got: Array[String] = []
	if not drawer_open or drawer_emptied:
		return got
	drawer_emptied = true
	for id in [SERVICE_KEY, INSULATED_BRIDGE]:
		if _give(id):
			got.append(id)
	return got


## "ok", "already" or "no_key" (the door needs the service key, never the transfer key).
func try_unlock_substation() -> String:
	if substation_unlocked:
		return "already"
	if not has_item(SERVICE_KEY):
		return "no_key"
	substation_unlocked = true
	return "ok"


## "ok", "already", "locked" (the substation is not open yet) or "no_bridge".
func try_insert_bridge() -> String:
	if bridge_inserted:
		return "already"
	if not substation_unlocked:
		return "locked"
	if not has_item(INSULATED_BRIDGE):
		return "no_bridge"
	bridge_inserted = true
	return "ok"


## "restored", "already", "locked" (substation closed) or "open_circuit" (the bridge is not in the terminal).
func try_throw_disconnector() -> String:
	if power_restored:
		return "already"
	if not substation_unlocked:
		return "locked"
	if not bridge_inserted:
		return "open_circuit"
	power_restored = true
	return "restored"


# --- chain B: the transfer door ---------------------------------------------------------------------------------------

## Inspecting the anomaly (clean strip, drag marks, draught at the seam) reveals the panel. True the first time only.
func discover_hidden_door() -> bool:
	if hidden_door_discovered:
		return false
	hidden_door_discovered = true
	return true


## The maintenance note is a pointer, not a prerequisite: nothing depends on having read it. True the first time only.
func read_maintenance_note() -> bool:
	if maintenance_note_read:
		return false
	maintenance_note_read = true
	return true


## The dry cabinet in the spares store. The cabinet needs no other item: finding it is the puzzle. "ok", "already".
func try_open_dry_cabinet() -> String:
	if cabinet_opened:
		return "already"
	cabinet_opened = true
	_give(TRANSFER_KEY)
	return "ok"


## What is missing for the door, in report order. Empty when it can open. Undiscovered doors report only that.
func door_missing(record_read: bool) -> Array[String]:
	var out: Array[String] = []
	if not hidden_door_discovered:
		out.append(DOOR_UNDISCOVERED)
		return out
	if not has_item(TRANSFER_KEY):
		out.append(DOOR_NO_KEY)
	if not power_restored:
		out.append(DOOR_NO_POWER)
	if not record_read:
		out.append(DOOR_NO_RECORD)
	return out


## "ok" (opened now), "already", or the first missing reason (see door_missing for the full list).
func try_open_transfer_door(record_read: bool) -> String:
	if transfer_door_open:
		return "already"
	var missing := door_missing(record_read)
	if not missing.is_empty():
		return str(missing[0])
	transfer_door_open = true
	return "ok"


# --- lift --------------------------------------------------------------------------------------------------------------

## The service lift needs the auxiliary supply AND the Aster maintenance condition (FASE1_FUNCTIONAL_SPEC.md, item 4).
func lift_powered(maintenance_on: bool) -> bool:
	return power_restored and maintenance_on


# --- lifecycle and persistence -------------------------------------------------------------------------------------------

func reset() -> void:
	items.clear()
	drawer_open = false
	drawer_emptied = false
	substation_unlocked = false
	bridge_inserted = false
	power_restored = false
	hidden_door_discovered = false
	maintenance_note_read = false
	cabinet_opened = false
	transfer_door_open = false
	wrong_codes = 0


func to_dict() -> Dictionary:
	return {
		"ITEMS": items.duplicate(),
		"DRAWER_OPEN": drawer_open,
		"DRAWER_EMPTIED": drawer_emptied,
		"SUBSTATION_UNLOCKED": substation_unlocked,
		"BRIDGE_INSERTED": bridge_inserted,
		"PowerRestored": power_restored,
		"HiddenDoorDiscovered": hidden_door_discovered,
		"MAINTENANCE_NOTE_READ": maintenance_note_read,
		"CABINET_OPENED": cabinet_opened,
		"TRANSFER_DOOR_OPEN": transfer_door_open,
		"WRONG_CODES": wrong_codes,
	}


## Restores a dictionary produced by to_dict(). Unknown or malformed fields are ignored; items are de-duplicated and
## restricted to the three canonical ids, so a corrupt save can never grant anything new or twice.
func from_dict(data: Dictionary) -> void:
	reset()
	var raw = data.get("ITEMS", [])
	if typeof(raw) == TYPE_ARRAY:
		for id in raw:
			if str(id) in [SERVICE_KEY, INSULATED_BRIDGE, TRANSFER_KEY]:
				_give(str(id))
	drawer_open = bool(data.get("DRAWER_OPEN", false))
	drawer_emptied = bool(data.get("DRAWER_EMPTIED", false))
	if drawer_emptied:  # an emptied drawer implies the code was solved and both items were taken (repairs a lost item)
		drawer_open = true
		_give(SERVICE_KEY)
		_give(INSULATED_BRIDGE)
	cabinet_opened = bool(data.get("CABINET_OPENED", false))
	if cabinet_opened:
		_give(TRANSFER_KEY)
	# Every later step needs the one before it; a flag without its prerequisite is dropped, never trusted.
	substation_unlocked = bool(data.get("SUBSTATION_UNLOCKED", false)) and has_item(SERVICE_KEY)
	bridge_inserted = bool(data.get("BRIDGE_INSERTED", false)) and substation_unlocked and has_item(INSULATED_BRIDGE)
	power_restored = bool(data.get("PowerRestored", false)) and bridge_inserted
	hidden_door_discovered = bool(data.get("HiddenDoorDiscovered", false))
	maintenance_note_read = bool(data.get("MAINTENANCE_NOTE_READ", false))
	transfer_door_open = bool(data.get("TRANSFER_DOOR_OPEN", false)) and hidden_door_discovered and power_restored and has_item(TRANSFER_KEY)
	wrong_codes = maxi(0, int(data.get("WRONG_CODES", 0)))
