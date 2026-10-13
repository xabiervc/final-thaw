extends Node
## Entrega B, paso 5: pruebas headless de la telemetria local.
## Escribe solo en user://telemetry_test_run y lo borra al terminar.
## Ejecutar: godot --headless --path . res://tests/test_control_room_telemetry.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const TelemetryScript = preload("res://scripts/vertical_slice/control_room_telemetry.gd")
const TEST_DIR := "user://telemetry_test_run"

var failed := 0
var passed := 0


func _ready() -> void:
	_cleanup()
	_test_off_by_default()
	_test_not_started_is_inert()
	_test_full_run()
	_test_idle_marks()
	_test_sessions_are_independent()
	_cleanup()
	print("Control room telemetry: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _make():
	var telemetry = TelemetryScript.new()
	telemetry.enabled = true
	telemetry.base_dir = TEST_DIR
	return telemetry


func _test_off_by_default() -> void:
	var off = TelemetryScript.new()
	off.base_dir = TEST_DIR
	_expect(not off.enabled, "B6: telemetry is off by default")
	_expect(not off.start_session("contextual", {}, "t"), "B6: an off telemetry does not start a session")
	off.log_read("a", 1.0)
	off.scan_used(true, 2.0)
	off.breaker_used("A", false, 3.0)
	off.hint_shown(1, "idle", 4.0)
	off.gate_opened(5.0)
	off.solved(5.0)
	_expect(off.tick(500.0) == 0, "B6: an off telemetry emits no idle events")
	_expect(off.events_written == 0 and off.file_path() == "" and not off.is_active(), "B6: an off telemetry writes nothing")
	_expect(not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(TEST_DIR)), "B6: an off telemetry creates no directory or file")


func _test_not_started_is_inert() -> void:
	var telemetry = _make()
	telemetry.log_read("a", 1.0)
	telemetry.breaker_used("C", true, 2.0)
	_expect(telemetry.events_written == 0 and not telemetry.is_active(), "B6: events before start_session are ignored")
	_expect(not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(TEST_DIR)), "B6: events before start_session create no file")


func _test_full_run() -> void:
	var telemetry = _make()
	_expect(telemetry.start_session("contextual", {"drain_zones": false}, "proto-1"), "B6: an enabled telemetry starts a session")
	var path: String = telemetry.file_path()
	_expect(FileAccess.file_exists(path) and path.begins_with(TEST_DIR), "B6: the session file exists inside the configured directory")
	telemetry.breaker_used("A", false, 5.0)
	telemetry.log_read("maintenance_0614", 8.0)
	telemetry.log_read("post_incident_review", 12.0)
	telemetry.scan_used(false, 14.0)
	telemetry.scan_used(true, 16.0)
	telemetry.hint_shown(1, "idle", 20.0)
	telemetry.breaker_used("C", true, 25.0)
	telemetry.gate_opened(27.0)
	telemetry.solved(27.0)

	var lines := _read_lines(path)
	_expect(lines.size() == 10 and telemetry.events_written == 10, "B6: every event of a full run is written (10)")
	var names: Array = []
	for line in lines:
		names.append(line["e"])
	_expect(names == ["session_start", "breaker_used", "log_read", "log_read", "scan_used", "scan_used", "hint_shown", "breaker_used", "gate_opened", "solved"], "B6: events are written in order with the expected names")
	_expect(lines.all(func(line: Dictionary) -> bool: return line.has("e") and line.has("t")), "B6: every line has an event name and a time")

	var start: Dictionary = lines[0]
	_expect(start["version"] == "proto-1" and start["hint_mode"] == "contextual" and start["sid"] == telemetry.session_id, "B6: session_start records version, hint mode and session id")
	_expect(start["flags"].has("drain_zones") and start["flags"]["drain_zones"] == false, "B6: session_start records the difficulty flags")
	var first_attempt: Dictionary = lines[1]
	_expect(first_attempt["id"] == "A" and first_attempt["correct"] == false, "B6: breaker_used records the breaker and whether it was correct")
	_expect(first_attempt["read_both_logs"] == false and first_attempt["scanned_before"] == false, "B6: an early attempt records that nothing had been read or scanned")
	_expect(lines[2]["id"] == "maintenance_0614" and lines[2]["t"] == 8.0, "B6: log_read records the log id and time")
	_expect(lines[4]["near_traces"] == false and lines[5]["near_traces"] == true, "B6: scan_used records whether traces were nearby")
	_expect(lines[6]["level"] == 1 and lines[6]["trigger"] == "idle", "B6: hint_shown records level and trigger")
	var last_attempt: Dictionary = lines[7]
	_expect(last_attempt["id"] == "C" and last_attempt["correct"] == true, "B6: the correct attempt is recorded")
	_expect(last_attempt["read_both_logs"] == true and last_attempt["scanned_before"] == true, "B6: a late attempt records that both logs were read and traces scanned")
	_expect(lines[8]["e"] == "gate_opened" and lines[8]["t"] == 27.0, "B6: gate_opened records its time")
	var summary: Dictionary = lines[9]
	_expect(summary["t_total"] == 27.0 and summary["attempts"] == 2 and summary["logs_read"] == 2 and summary["scans"] == 2 and summary["hints"] == 1, "B6: solved summarizes attempts, logs, scans and hints")

	var raw := _read_raw_first_line(path)
	_expect(raw.begins_with("{\"e\":\"session_start\""), "B6: lines are compact JSON with sorted keys")

	_expect(telemetry.tick(1000.0) == 0, "B6: no idle events after the puzzle is solved")


func _test_idle_marks() -> void:
	var telemetry = _make()
	telemetry.start_session("full", {}, "proto-1")
	_expect(telemetry.tick(29.9) == 0, "B6: no idle event before 30 s")
	_expect(telemetry.tick(30.0) == 1, "B6: an idle event at 30 s")
	_expect(telemetry.tick(30.0) == 0, "B6: the same mark is not repeated")
	_expect(telemetry.tick(59.9) == 0 and telemetry.tick(60.0) == 1, "B6: the next idle event at 60 s")
	telemetry.log_read("maintenance_0614", 61.0)
	_expect(telemetry.tick(90.9) == 0 and telemetry.tick(91.0) == 1, "B6: a useful action restarts the idle count")
	_expect(telemetry.tick(500.0) == 1 and telemetry.tick(501.0) == 0, "B6: a long jump writes a single idle event")
	var seconds: Array = []
	for line in _read_lines(telemetry.file_path()):
		if line["e"] == "idle":
			seconds.append(line["seconds"])
	_expect(seconds == [30.0, 60.0, 30.0, 420.0], "B6: idle events record the inactivity reached")
	var scan_only = _make()
	scan_only.start_session("full", {}, "proto-1")
	scan_only.scan_used(false, 20.0)
	_expect(scan_only.tick(30.0) == 1, "B6: a scan far from the traces is not a useful action")
	scan_only.scan_used(true, 31.0)
	_expect(scan_only.tick(60.9) == 0 and scan_only.tick(61.0) == 1, "B6: a scan near the traces restarts the idle count")


func _test_sessions_are_independent() -> void:
	var first = _make()
	var second = _make()
	first.start_session("off", {}, "proto-1")
	second.start_session("off", {}, "proto-1")
	_expect(first.session_id != second.session_id and first.session_id.length() == 16, "B6: each session gets its own random id")
	_expect(first.file_path() != second.file_path(), "B6: each session writes its own file")
	first.log_read("a", 1.0)
	_expect(_read_lines(second.file_path()).size() == 1, "B6: events from one session never reach another file")


func _read_lines(path: String) -> Array:
	var out: Array = []
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return out
	while not file.eof_reached():
		var line := file.get_line()
		if not line.is_empty():
			out.append(JSON.parse_string(line))
	return out


func _read_raw_first_line(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_line()


func _cleanup() -> void:
	var dir := DirAccess.open(TEST_DIR)
	if dir != null:
		for file_name in dir.get_files():
			dir.remove(file_name)
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_DIR))


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
