extends Node
## Entrega A: pruebas headless de la logica del puzle de registros y cableado.
## Ejecutar: godot --headless --path . res://tests/test_control_room_rules.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const RulesScript = preload("res://scripts/vertical_slice/control_room_rules.gd")

const MAX_SEQUENCE_LENGTH := 6
const ACTIONS: Array[String] = ["log_before", "log_after", "A", "B", "C", "wait_1", "wait_5"]
const MAX_REPORTED_FAILURES := 5

var failed := 0
var passed := 0


func _ready() -> void:
	_test_initial_state()
	_test_logs()
	_test_breaker_a()
	_test_breaker_b_cooldown()
	_test_breaker_c()
	_test_gate()
	_test_invalid_ids()
	_test_state_round_trip()
	_test_malformed_state()
	_test_reset()
	_test_exhaustive_sequences()
	print("Control room rules: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _test_initial_state() -> void:
	var rules = RulesScript.new()
	_expect(not rules.can_open_gate(), "A5: gate cannot open at start")
	_expect(not rules.is_gate_open(), "A5: gate starts closed")
	_expect(not rules.lamp_lit and not rules.pressure_on, "Start: no breaker has been used")
	_expect(rules.total_attempts() == 0, "Start: no attempts")
	_expect(rules.is_breaker_available("B", 0.0), "A3: B is available at start")


func _test_logs() -> void:
	var rules = RulesScript.new()
	_expect(rules.read_log(RulesScript.LOG_BEFORE), "A1: first read of the earlier log is registered")
	_expect(not rules.read_log(RulesScript.LOG_BEFORE), "A1: rereading is allowed but not counted twice")
	_expect(not rules.has_read_both_logs(), "A1: one log is not both")
	_expect(rules.read_log(RulesScript.LOG_AFTER), "A1: first read of the later log is registered")
	_expect(rules.has_read_both_logs(), "A1: both logs read")
	_expect(not rules.read_log("unknown_log"), "A1: unknown log id is ignored")
	_expect(not rules.can_open_gate() and rules.total_attempts() == 0, "A1: reading logs never changes solvability or attempts")


func _test_breaker_a() -> void:
	var rules = RulesScript.new()
	for i in 3:
		var r: Dictionary = rules.use_breaker("A", float(i))
		_expect(r["accepted"] and r["result"] == "lamp" and not r["correct"] and not r["gate_powered"], "A2: A only lights the lamp (try %d)" % (i + 1))
	_expect(rules.lamp_lit, "A2: lamp stays lit")
	_expect(not rules.can_open_gate(), "A2: A never powers the gate")
	_expect(rules.attempts_for("A") == 3, "A2: A attempts are counted")


func _test_breaker_b_cooldown() -> void:
	var rules = RulesScript.new()
	var first: Dictionary = rules.use_breaker("B", 10.0)
	_expect(first["accepted"] and first["result"] == "burned" and not first["correct"], "A3: B burns the fuse")
	_expect(not rules.is_breaker_available("B", 10.0), "A3: B is unavailable right after")
	var blocked: Dictionary = rules.use_breaker("B", 13.999)
	_expect(not blocked["accepted"] and blocked["result"] == "cooldown", "A3: B stays on cooldown before 4 s")
	_expect(rules.attempts_for("B") == 1, "A3: a blocked B does not count as an attempt")
	_expect(is_equal_approx(rules.breaker_b_remaining(12.0), 2.0), "A3: remaining cooldown is reported")
	_expect(rules.is_breaker_available("B", 14.0), "A3: B is available again at exactly 4 s")
	var again: Dictionary = rules.use_breaker("B", 14.0)
	_expect(again["accepted"] and again["result"] == "burned", "A3: B can burn again after the cooldown")
	rules.use_breaker("B", 20.0)
	var during: Dictionary = rules.use_breaker("A", 21.0)
	_expect(during["accepted"], "A3: A works while B is on cooldown")
	var c_during: Dictionary = rules.use_breaker("C", 21.0)
	_expect(c_during["accepted"] and c_during["correct"], "A3: C works while B is on cooldown")
	_expect(rules.can_open_gate(), "A3: gate can open after C even if B was spammed")


func _test_breaker_c() -> void:
	var rules = RulesScript.new()
	var first: Dictionary = rules.use_breaker("C", 0.0)
	_expect(first["accepted"] and first["result"] == "pressure" and first["correct"] and first["gate_powered"], "A4: C powers the gate")
	var state_before: Dictionary = rules.get_state()
	rules.use_breaker("C", 1.0)
	rules.use_breaker("C", 2.0)
	var state_after: Dictionary = rules.get_state()
	_expect(rules.pressure_on and rules.attempts_for("C") == 3, "A4: repeating C keeps pressure and counts attempts")
	state_before.erase("attempts")
	state_after.erase("attempts")
	_expect(_same(state_before, state_after), "A4: repeating C changes nothing but the attempt counter")
	rules.use_breaker("A", 3.0)
	rules.use_breaker("B", 4.0)
	_expect(rules.pressure_on and rules.can_open_gate(), "A4: using A or B after C does not undo it")


func _test_gate() -> void:
	var rules = RulesScript.new()
	_expect(not rules.open_gate(), "A5: gate does not open before C")
	_expect(not rules.is_gate_open(), "A5: gate is still closed after a failed attempt")
	rules.use_breaker("A", 0.0)
	_expect(not rules.open_gate(), "A5: A does not unlock the gate")
	rules.use_breaker("C", 1.0)
	_expect(rules.can_open_gate(), "A5: gate can open after C")
	_expect(rules.open_gate() and rules.is_gate_open(), "A5: gate opens after C")
	_expect(not rules.open_gate(), "A5: opening twice reports no change")
	_expect(rules.is_gate_open() and rules.can_open_gate(), "A5: gate stays open")


func _test_invalid_ids() -> void:
	var rules = RulesScript.new()
	var r: Dictionary = rules.use_breaker("Z", 0.0)
	_expect(not r["accepted"] and r["result"] == "invalid" and not r["correct"], "Invalid breaker id is rejected")
	_expect(not rules.is_breaker_available("Z", 0.0), "Invalid breaker id is never available")
	_expect(rules.total_attempts() == 0 and not rules.can_open_gate(), "Invalid breaker id changes nothing")


func _test_state_round_trip() -> void:
	var rules = RulesScript.new()
	rules.read_log(RulesScript.LOG_AFTER)
	rules.use_breaker("A", 0.0)
	rules.use_breaker("B", 1.0)
	rules.use_breaker("C", 2.0)
	rules.open_gate()
	var state: Dictionary = rules.get_state()
	var restored = RulesScript.new()
	restored.apply_state(state)
	_expect(_same(state, restored.get_state()), "A7: state round trip is identical")
	var parsed: Variant = JSON.parse_string(JSON.stringify(state))
	var from_json = RulesScript.new()
	from_json.apply_state(parsed)
	_expect(_same(state, from_json.get_state()), "A7: state survives a JSON save/load")
	_expect(restored.is_breaker_available("B", 0.0), "A7: B cooldown is not persisted")
	state["lamp_lit"] = false
	_expect(rules.lamp_lit, "A7: get_state returns a copy, not live references")


func _test_malformed_state() -> void:
	var rules = RulesScript.new()
	rules.apply_state({"gate_open": true})
	_expect(not rules.is_gate_open(), "A7: gate_open without pressure is rejected")
	rules.apply_state({"logs_read": ["unknown", "maintenance_0614"], "attempts": {"A": -4, "C": "x"}})
	_expect(rules.has_read_log("maintenance_0614") and not rules.has_read_both_logs(), "A7: unknown log ids are ignored")
	_expect(rules.attempts_for("A") == 0 and rules.attempts_for("C") == 0, "A7: negative or invalid attempts become 0")
	rules.apply_state({"logs_read": "not an array", "attempts": 5, "extra": 1})
	_expect(rules.total_attempts() == 0 and not rules.has_read_log("maintenance_0614"), "A7: wrong types fall back to defaults")
	rules.apply_state({})
	_expect(_same(rules.get_state(), RulesScript.new().get_state()), "A7: empty state equals a fresh state")


func _test_reset() -> void:
	var rules = RulesScript.new()
	rules.read_log(RulesScript.LOG_BEFORE)
	rules.use_breaker("B", 0.0)
	rules.use_breaker("C", 1.0)
	rules.open_gate()
	rules.reset()
	_expect(_same(rules.get_state(), RulesScript.new().get_state()), "Reset returns to the initial state")
	_expect(rules.is_breaker_available("B", 0.0), "Reset clears the B cooldown")
	_expect(not rules.can_open_gate(), "Reset relocks the gate")


func _test_exhaustive_sequences() -> void:
	var alphabet_size := ACTIONS.size()
	var sequences := 0
	var bad := 0
	for length in range(1, MAX_SEQUENCE_LENGTH + 1):
		var total := int(pow(alphabet_size, length))
		for index in range(total):
			sequences += 1
			if not _sequence_recovers(index, length):
				bad += 1
				if bad <= MAX_REPORTED_FAILURES:
					push_error("FAIL: sequence does not recover: " + _describe(index, length))
	_expect(sequences > 0, "A6: sequences were generated (%d)" % sequences)
	_expect(bad == 0, "A6: every sequence up to %d actions recovers and can open the gate (%d checked)" % [MAX_SEQUENCE_LENGTH, sequences])


@warning_ignore("integer_division")
func _sequence_recovers(index: int, length: int) -> bool:
	var alphabet_size := ACTIONS.size()
	var rules = RulesScript.new()
	var now := 0.0
	var used_c := false
	var code := index
	for _step in length:
		var action: String = ACTIONS[code % alphabet_size]
		code = code / alphabet_size
		if action == "log_before":
			rules.read_log(RulesScript.LOG_BEFORE)
		elif action == "log_after":
			rules.read_log(RulesScript.LOG_AFTER)
		elif action == "wait_1":
			now += 1.0
		elif action == "wait_5":
			now += 5.0
		else:
			rules.use_breaker(action, now)
			if action == "C":
				used_c = true
	if rules.can_open_gate() != used_c:
		return false
	if not used_c and (rules.open_gate() or rules.is_gate_open()):
		return false
	if rules.is_gate_open() and not rules.pressure_on:
		return false
	var state: Dictionary = rules.get_state()
	var copy = RulesScript.new()
	copy.apply_state(JSON.parse_string(JSON.stringify(state)))
	if not _same(state, copy.get_state()):
		return false
	now += 10.0
	var recovery: Dictionary = rules.use_breaker("C", now)
	if not (recovery["accepted"] and recovery["correct"] and rules.can_open_gate()):
		return false
	rules.open_gate()
	return rules.is_gate_open()


@warning_ignore("integer_division")
func _describe(index: int, length: int) -> String:
	var alphabet_size := ACTIONS.size()
	var names: Array[String] = []
	var code := index
	for _step in length:
		names.append(ACTIONS[code % alphabet_size])
		code = code / alphabet_size
	return " > ".join(names)


func _same(a: Variant, b: Variant) -> bool:
	return JSON.stringify(a, "", true) == JSON.stringify(b, "", true)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
