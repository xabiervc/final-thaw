extends Node
## Entrega B, paso 4: pruebas headless de la logica de pistas.
## Ejecutar: godot --headless --path . res://tests/test_control_room_hints.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const HintsScript = preload("res://scripts/vertical_slice/control_room_hints.gd")
const RulesScript = preload("res://scripts/vertical_slice/control_room_rules.gd")

var failed := 0
var passed := 0


func _ready() -> void:
	_test_off_mode()
	_test_contextual_idle()
	_test_full_idle()
	_test_useful_action_resets_idle()
	_test_wrong_attempt_hint()
	_test_manual_requests()
	_test_solved_stops_hints()
	_test_reset_and_time_jump()
	_test_text_keys()
	print("Control room hints: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _make(mode: int):
	var hints = HintsScript.new()
	hints.mode = mode
	return hints


func _is_single(events: Array, level: int, trigger: String) -> bool:
	return events.size() == 1 and events[0]["level"] == level and events[0]["trigger"] == trigger


func _test_off_mode() -> void:
	var hints = _make(HintsScript.Mode.OFF)
	hints.notify_breaker_result(RulesScript.RESULT_LAMP, 10.0)
	_expect(hints.advance(11.5).is_empty() and hints.advance(50.0).is_empty() and hints.advance(200.0).is_empty(), "B4: OFF never shows a hint on its own")
	_expect(hints.request_hint(5.0).is_empty(), "B4: OFF ignores manual requests")


func _test_contextual_idle() -> void:
	var hints = _make(HintsScript.Mode.CONTEXTUAL)
	_expect(hints.advance(44.9).is_empty(), "B4: no hint before 45 s without a useful action")
	_expect(_is_single(hints.advance(45.0), 1, "idle"), "B4: CONTEXTUAL shows level 1 at 45 s of inactivity")
	_expect(hints.advance(46.0).is_empty() and hints.advance(100.0).is_empty() and hints.advance(200.0).is_empty(), "B4: CONTEXTUAL shows level 1 once per idle period and never level 2")


func _test_full_idle() -> void:
	var hints = _make(HintsScript.Mode.FULL)
	_expect(_is_single(hints.advance(45.0), 1, "idle"), "B4: FULL shows level 1 at 45 s")
	_expect(hints.advance(99.9).is_empty(), "B4: FULL shows nothing between the two levels")
	_expect(_is_single(hints.advance(100.0), 2, "idle"), "B4: FULL shows level 2 at 100 s")
	_expect(hints.advance(150.0).is_empty(), "B4: FULL shows level 2 once per idle period")


func _test_useful_action_resets_idle() -> void:
	var hints = _make(HintsScript.Mode.CONTEXTUAL)
	hints.notify_useful_action(40.0)
	_expect(hints.advance(45.0).is_empty() and hints.advance(84.9).is_empty(), "B4: a useful action restarts the inactivity clock")
	_expect(_is_single(hints.advance(85.0), 1, "idle"), "B4: level 1 returns 45 s after the last useful action")
	var again = _make(HintsScript.Mode.CONTEXTUAL)
	_expect(_is_single(again.advance(45.0), 1, "idle"), "B4: first idle hint")
	again.notify_useful_action(50.0)
	_expect(again.advance(94.9).is_empty() and _is_single(again.advance(95.0), 1, "idle"), "B4: a new idle period can show level 1 again")
	var manual = _make(HintsScript.Mode.FULL)
	manual.request_hint(0.0)
	_expect(manual.advance(44.9).is_empty() and _is_single(manual.advance(45.0), 1, "idle"), "B4: asking for a hint counts as a useful action")


func _test_wrong_attempt_hint() -> void:
	var hints = _make(HintsScript.Mode.CONTEXTUAL)
	hints.notify_breaker_result(RulesScript.RESULT_LAMP, 10.0)
	_expect(hints.advance(11.4).is_empty(), "B3: the hint waits for the response (nothing before 1.5 s)")
	_expect(_is_single(hints.advance(11.5), 1, "wrong_attempt"), "B3: the hint arrives 1.5 s after the specific response")
	hints.notify_breaker_result(RulesScript.RESULT_BURNED, 20.0)
	_expect(hints.advance(22.0).is_empty(), "B3: only the first wrong attempt triggers a hint")
	var neutral = _make(HintsScript.Mode.CONTEXTUAL)
	neutral.notify_breaker_result(RulesScript.RESULT_COOLDOWN, 10.0)
	neutral.notify_breaker_result(RulesScript.RESULT_PRESSURE, 11.0)
	_expect(neutral.advance(13.0).is_empty(), "B3: a blocked B or the correct C do not trigger a wrong-attempt hint")
	var full = _make(HintsScript.Mode.FULL)
	full.notify_breaker_result(RulesScript.RESULT_BURNED, 5.0)
	_expect(_is_single(full.advance(6.5), 1, "wrong_attempt"), "B3: FULL also starts with level 1 after a wrong attempt")


func _test_manual_requests() -> void:
	var contextual = _make(HintsScript.Mode.CONTEXTUAL)
	_expect(_is_single(contextual.request_hint(0.0), 1, "manual"), "B4: CONTEXTUAL manual request gives level 1")
	_expect(_is_single(contextual.request_hint(10.0), 1, "manual"), "B4: CONTEXTUAL never escalates to level 2")
	var full = _make(HintsScript.Mode.FULL)
	_expect(_is_single(full.request_hint(0.0), 1, "manual"), "B4: FULL first request gives level 1")
	_expect(_is_single(full.request_hint(29.0), 2, "manual"), "B4: FULL second request within 30 s gives level 2")
	_expect(_is_single(full.request_hint(59.0), 2, "manual"), "B4: the escalation window is measured from the last request")
	var boundary = _make(HintsScript.Mode.FULL)
	boundary.request_hint(0.0)
	_expect(_is_single(boundary.request_hint(30.0), 2, "manual"), "B4: exactly 30 s still escalates")
	var late = _make(HintsScript.Mode.FULL)
	late.request_hint(0.0)
	_expect(_is_single(late.request_hint(30.5), 1, "manual"), "B4: after the window the request gives level 1 again")


func _test_solved_stops_hints() -> void:
	var hints = _make(HintsScript.Mode.FULL)
	hints.notify_breaker_result(RulesScript.RESULT_LAMP, 10.0)
	hints.notify_solved()
	_expect(hints.advance(11.5).is_empty() and hints.advance(500.0).is_empty(), "B4: no hints after the gate is open, even a pending one")
	_expect(hints.request_hint(12.0).is_empty(), "B4: no manual hints after the gate is open")


func _test_reset_and_time_jump() -> void:
	var hints = _make(HintsScript.Mode.CONTEXTUAL)
	hints.reset(100.0)
	_expect(hints.advance(144.9).is_empty() and _is_single(hints.advance(145.0), 1, "idle"), "B4: reset measures inactivity from the given time")
	var jump = _make(HintsScript.Mode.FULL)
	_expect(_is_single(jump.advance(500.0), 2, "idle"), "B4: a long jump shows one level 2, not both levels")
	_expect(jump.advance(501.0).is_empty(), "B4: nothing more after that jump")


func _test_text_keys() -> void:
	var hints = _make(HintsScript.Mode.CONTEXTUAL)
	_expect(hints.text_key_for(1) == "cr_hint_level_1" and hints.text_key_for(2) == "cr_hint_level_2", "B4: levels map to the localized text keys")
	_expect(hints.text_key_for(0) == "" and hints.text_key_for(3) == "", "B4: unknown levels have no text key")


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
