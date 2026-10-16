extends Node
## Logic test of the expanded Phase 1 progression (scripts/phase1/phase1_transfer_state.gd): the drawer code, the two
## independent chains, the transfer door's four prerequisites in every exploration order, idempotence, the lift rule and the
## save round-trip. Pure model: no scene, no physics. The same rules are walked in the real scene by
## tests/test_phase1_transfer_chain.gd and tests/test_phase1_playthrough.gd.
## Run: godot --headless --path . res://tests/test_phase1_transfer_state.tscn

const State = preload("res://scripts/phase1/phase1_transfer_state.gd")

var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(30.0).timeout.connect(func():
		if not completed:
			push_error("Transfer state test did not complete (possible script error).")
			get_tree().quit(1))
	call_deferred("_run")


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


## The whole power chain, in its only valid order.
func _power_chain(s) -> void:
	s.try_drawer_code(State.solution())
	s.take_drawer_items()
	s.try_unlock_substation()
	s.try_insert_bridge()
	s.try_throw_disconnector()


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	_code()
	_power_chain_rules()
	_transfer_door_rules()
	_orders()
	_lift_and_aster_boundary()
	_persistence()
	completed = true
	print("Phase 1 transfer state: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


# --- the drawer code ---------------------------------------------------------------------------------------------------

func _code() -> void:
	_expect(State.solution() == "0437", "the readings B=0, D=4, A=3, C=7 taken in the shift board's order give 0437")
	_expect(State.TEST_ORDER == ["B", "D", "A", "C"] and int(State.STABLE_READINGS["A"]) == 3 and int(State.STABLE_READINGS["B"]) == 0
			and int(State.STABLE_READINGS["C"]) == 7 and int(State.STABLE_READINGS["D"]) == 4, "the clue data are exactly the approved ones")
	# Each clue alone is not the answer: reading the strip in alphabetical order, or the order without the strip, is wrong.
	var alphabetical := ""
	for point in ["A", "B", "C", "D"]:
		alphabetical += str(int(State.STABLE_READINGS[point]))
	_expect(alphabetical != State.solution() and alphabetical == "3074", "the strip read in alphabetical order (3074) is not the code: the board's order matters")
	var s = State.new()
	_expect(s.try_drawer_code("0000") == "wrong" and s.try_drawer_code("3074") == "wrong" and s.wrong_codes == 2, "wrong codes are refused and counted")
	_expect(s.try_drawer_code("043") == "malformed" and s.try_drawer_code("04370") == "malformed" and s.try_drawer_code("04a7") == "malformed" and s.wrong_codes == 2, "malformed codes are refused without counting as attempts")
	_expect(not s.drawer_open and s.take_drawer_items().is_empty(), "a closed drawer gives nothing")
	_expect(s.try_drawer_code("0437") == "ok" and s.drawer_open, "the deduced code opens the drawer")
	_expect(s.try_drawer_code("0437") == "already" and s.try_drawer_code("9999") == "already", "a drawer that is open stays open and never counts a later attempt")


# --- chain A ---------------------------------------------------------------------------------------------------------------

func _power_chain_rules() -> void:
	var s = State.new()
	_expect(s.try_unlock_substation() == "no_key" and not s.substation_unlocked, "the substation door refuses without the service key")
	s.items.append(State.TRANSFER_KEY)
	_expect(s.try_unlock_substation() == "no_key", "the transfer key never opens the substation")
	s.reset()
	_expect(s.try_insert_bridge() == "locked" and s.try_throw_disconnector() == "locked", "bridge and disconnector are out of reach while the substation is shut")
	s.try_drawer_code("0437")
	var got: Array[String] = s.take_drawer_items()
	_expect(got == [State.SERVICE_KEY, State.INSULATED_BRIDGE] and s.items.size() == 2, "the drawer gives exactly the service key and the insulated bridge")
	_expect(s.take_drawer_items().is_empty() and s.items.size() == 2, "emptying the drawer twice does not duplicate the items")
	_expect(not s.has_item(State.TRANSFER_KEY), "the drawer never holds the transfer key")
	_expect(s.try_throw_disconnector() == "locked", "the disconnector still needs the substation open")
	_expect(s.try_unlock_substation() == "ok" and s.substation_unlocked and s.try_unlock_substation() == "already", "the service key opens the substation once")
	_expect(s.try_throw_disconnector() == "open_circuit" and not s.power_restored, "the disconnector refuses with the terminal empty (circuit open)")
	_expect(s.try_insert_bridge() == "ok" and s.bridge_inserted and s.try_insert_bridge() == "already", "the bridge fits the terminal once")
	_expect(not s.power_restored, "the bridge alone does not restore power")
	_expect(s.try_throw_disconnector() == "restored" and s.power_restored and s.try_throw_disconnector() == "already", "the disconnector restores power once")
	# A bridge held without the substation key cannot be placed (the bridge in hand is not enough).
	var t = State.new()
	t.items.append(State.INSULATED_BRIDGE)
	_expect(t.try_insert_bridge() == "locked", "holding the bridge does not let the player skip the substation door")


# --- chain B and the door ------------------------------------------------------------------------------------------------------

func _transfer_door_rules() -> void:
	var s = State.new()
	_expect(s.door_missing(true) == [State.DOOR_UNDISCOVERED] and s.try_open_transfer_door(true) == State.DOOR_UNDISCOVERED, "an undiscovered door reports only that it is undiscovered")
	_expect(s.discover_hidden_door() and not s.discover_hidden_door(), "the anomaly reveals the door once")
	_expect(s.door_missing(false) == [State.DOOR_NO_KEY, State.DOOR_NO_POWER, State.DOOR_NO_RECORD], "a discovered door lists every missing prerequisite, in order")
	_expect(not s.transfer_door_open, "discovering the door does not open it")
	_expect(s.read_maintenance_note() and not s.read_maintenance_note(), "the maintenance note is read once")
	_expect(not s.has_item(State.TRANSFER_KEY) and s.door_missing(true).has(State.DOOR_NO_KEY), "reading the note alone grants nothing")
	_expect(s.try_open_dry_cabinet() == "ok" and s.has_item(State.TRANSFER_KEY) and s.try_open_dry_cabinet() == "already", "the dry cabinet gives the transfer key once")
	_expect(s.items.count(State.TRANSFER_KEY) == 1, "the transfer key is never duplicated")
	_expect(s.try_open_transfer_door(true) == State.DOOR_NO_POWER and not s.transfer_door_open, "key and record without power: the door stays shut and says power is missing")
	_power_chain(s)
	_expect(s.try_open_transfer_door(false) == State.DOOR_NO_RECORD and not s.transfer_door_open, "key and power without the restricted record: the door stays shut")
	_expect(s.try_open_transfer_door(true) == "ok" and s.transfer_door_open, "with every prerequisite the door opens")
	_expect(s.try_open_transfer_door(true) == "already" and s.try_open_transfer_door(false) == "already", "an open door stays open (no second opening, no relock)")
	# Truth table: the door opens if and only if all four hold, for every combination.
	var wrong := 0
	for mask in 16:
		var d = State.new()
		var known: bool = (mask & 1) != 0
		var key: bool = (mask & 2) != 0
		var power: bool = (mask & 4) != 0
		var record: bool = (mask & 8) != 0
		if known:
			d.discover_hidden_door()
		if key:
			d.try_open_dry_cabinet()
		if power:
			_power_chain(d)
		var result: String = d.try_open_transfer_door(record)
		if (result == "ok") != (known and key and power and record):
			wrong += 1
	_expect(wrong == 0, "the door opens exactly when discovered + TRANSFER_KEY + PowerRestored + RESTRICTED_RECORD_READ (16 combinations)")
	# The service items never stand in for the transfer key.
	var u = State.new()
	u.discover_hidden_door()
	_power_chain(u)
	_expect(u.has_item(State.SERVICE_KEY) and u.has_item(State.INSULATED_BRIDGE) and u.try_open_transfer_door(true) == State.DOOR_NO_KEY, "SERVICE_KEY and INSULATED_BRIDGE do not open the transfer door")


# --- exploration order ------------------------------------------------------------------------------------------------------

## Applies one of the five independent events.
func _apply(s, event: String, record: Array) -> void:
	match event:
		"discover":
			s.discover_hidden_door()
		"note":
			s.read_maintenance_note()
		"cabinet":
			s.try_open_dry_cabinet()
		"power":
			_power_chain(s)
		"record":
			record[0] = true


func _permutations(items: Array) -> Array:
	if items.size() <= 1:
		return [items.duplicate()]
	var out: Array = []
	for i in items.size():
		var rest := items.duplicate()
		var head = rest.pop_at(i)
		for tail in _permutations(rest):
			out.append([head] + tail)
	return out


func _orders() -> void:
	var events := ["discover", "note", "cabinet", "power", "record"]
	var perms := _permutations(events)
	var bad_open := 0
	var bad_closed := 0
	var early_open := 0
	for order in perms:
		var s = State.new()
		var record := [false]
		for idx in order.size():
			_apply(s, order[idx], record)
			var done: Array = order.slice(0, idx + 1)
			var complete: bool = done.has("discover") and done.has("cabinet") and done.has("power") and done.has("record")
			var missing := s.door_missing(bool(record[0]))
			if complete != missing.is_empty():
				early_open += 1
		if s.try_open_transfer_door(bool(record[0])) != "ok":
			bad_open += 1
		# A second pass over the same events changes nothing (idempotent), and the door state survives.
		var before := s.to_dict()
		for event in events:
			_apply(s, event, record)
		if s.to_dict() != before:
			bad_closed += 1
	_expect(perms.size() == 120, "all 120 exploration orders were walked")
	_expect(bad_open == 0, "the door opens in every one of the 120 orders")
	_expect(early_open == 0, "the door becomes available exactly at the event that completes the set, never before")
	_expect(bad_closed == 0, "repeating every event after the fact changes nothing")
	# The note is never a prerequisite: skipping it is fine; reading it first is fine.
	var s2 = State.new()
	s2.discover_hidden_door()
	s2.try_open_dry_cabinet()
	_power_chain(s2)
	_expect(not s2.maintenance_note_read and s2.try_open_transfer_door(true) == "ok", "the maintenance note is a pointer: the door opens without having read it")


# --- the lift and the Aster boundary --------------------------------------------------------------------------------------------

func _lift_and_aster_boundary() -> void:
	var s = State.new()
	_expect(not s.lift_powered(true) and not s.lift_powered(false), "without the auxiliary supply the lift is dead whatever the maintenance switch says")
	_power_chain(s)
	_expect(s.lift_powered(true) and not s.lift_powered(false), "with the auxiliary supply the lift needs the Aster maintenance condition too")
	# The model owns no Aster state at all: its dictionary carries none of the circuit's or the mission's fields.
	var keys := s.to_dict().keys()
	var aster_keys := ["SERVICE_OVERRIDE", "RESTRICTED_RECORD_READ", "AUDIT_SENT", "CONTAINMENT", "maintenance", "protection"]
	var leaks := 0
	for k in keys:
		if str(k) in aster_keys:
			leaks += 1
	_expect(leaks == 0, "the transfer model stores no circuit or mission-contract field")


# --- persistence ---------------------------------------------------------------------------------------------------------------

func _persistence() -> void:
	var steps := ["code", "take", "unlock", "bridge", "throw", "discover", "note", "cabinet", "open"]
	var s = State.new()
	var all_equal := true
	for step in steps:
		match step:
			"code":
				s.try_drawer_code("0437")
			"take":
				s.take_drawer_items()
			"unlock":
				s.try_unlock_substation()
			"bridge":
				s.try_insert_bridge()
			"throw":
				s.try_throw_disconnector()
			"discover":
				s.discover_hidden_door()
			"note":
				s.read_maintenance_note()
			"cabinet":
				s.try_open_dry_cabinet()
			"open":
				s.try_open_transfer_door(true)
		var copy = State.new()
		copy.from_dict(s.to_dict())
		if copy.to_dict() != s.to_dict():
			all_equal = false
	_expect(all_equal, "to_dict/from_dict round-trips the state after every step of the whole chain")
	_expect(s.transfer_door_open and s.items.size() == 3, "the finished chain holds exactly three items")
	var loaded = State.new()
	loaded.from_dict(s.to_dict())
	loaded.from_dict(loaded.to_dict())
	_expect(loaded.items.size() == 3 and loaded.items.count(State.SERVICE_KEY) == 1 and loaded.items.count(State.TRANSFER_KEY) == 1, "loading twice does not duplicate items")
	# Corrupt or hostile input never grants more than the flags justify.
	var c = State.new()
	c.from_dict({"BRIDGE_INSERTED": true, "PowerRestored": true, "TRANSFER_DOOR_OPEN": true, "ITEMS": ["SERVICE_KEY", "SERVICE_KEY", "GOLDEN_KEY", 7]})
	_expect(not c.substation_unlocked and not c.bridge_inserted and not c.power_restored and not c.transfer_door_open, "flags without their prerequisites are dropped on load")
	_expect(c.items == [State.SERVICE_KEY], "unknown and duplicate items are dropped on load")
	var repaired = State.new()
	repaired.from_dict({"DRAWER_EMPTIED": true, "CABINET_OPENED": true})
	_expect(repaired.drawer_open and repaired.has_item(State.SERVICE_KEY) and repaired.has_item(State.INSULATED_BRIDGE) and repaired.has_item(State.TRANSFER_KEY), "a save that records a taken item can never lose it (no softlock)")
	var empty = State.new()
	empty.from_dict({})
	_expect(empty.to_dict() == State.new().to_dict(), "an empty dictionary loads as a fresh mission")
	empty.from_dict({"ITEMS": "not an array", "WRONG_CODES": -5})
	_expect(empty.items.is_empty() and empty.wrong_codes == 0, "malformed fields fall back to defaults")
	s.reset()
	_expect(s.to_dict() == State.new().to_dict(), "reset returns the mission to its start")
