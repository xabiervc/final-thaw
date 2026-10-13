extends Node
## Entrega B, paso 6: prueba de integracion de la escena prototipo (sin interfaz grafica).
## Recorre el camino de solucion llamando a los componentes directamente y comprueba que la
## escena cablea bien reglas, pistas, telemetria y compuerta.
## Escribe solo en user://telemetry_test_proto y lo borra al terminar.
## Ejecutar: godot --headless --path . res://tests/test_control_room_proto.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const RoomScript = preload("res://scripts/levels/proto/control_room_proto.gd")
const RulesScript = preload("res://scripts/vertical_slice/control_room_rules.gd")
const TEST_DIR := "user://telemetry_test_proto"

var failed := 0
var passed := 0


func _ready() -> void:
	_cleanup()
	var room = RoomScript.new()
	room.telemetry_enabled = true
	room.telemetry_dir = TEST_DIR
	room.hint_mode = 2
	add_child(room)
	await get_tree().process_frame
	_check_setup(room)
	_check_solution_path(room)
	_check_telemetry(room)
	room.queue_free()
	await get_tree().process_frame
	_cleanup()
	print("Control room proto: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _check_setup(room) -> void:
	_expect(room.rules != null and room.hints != null and room.telemetry != null, "B: the scene creates rules, hints and telemetry")
	_expect(room.breakers.size() == 3 and room.logs.size() == 2 and room.traces.size() == 3, "B: the room has 3 breakers, 2 logs and 3 traces")
	_expect(room.door != null and room.door.locked and not room.door.is_open, "B: the gate starts locked and closed")
	_expect(room.door.locked_message != "", "B5: the gate message comes from the localized texts")
	_expect(room.breakers["A"].text_lamp != "" and room.breakers["B"].text_burned != "" and room.breakers["C"].text_pressure != "", "B5: breaker responses come from the localized texts")
	_expect(room.hints.mode == 2, "B4: the exported hint mode reaches the hint logic")
	_expect(room.telemetry.is_active() and room.telemetry.file_path().begins_with(TEST_DIR), "B6: telemetry starts in the configured directory when enabled")
	var all_scannable := true
	for trace in room.traces:
		if not trace.is_in_group("scannables") or trace.is_in_group("interactables"):
			all_scannable = false
	_expect(all_scannable, "B2: every trace is scannable and none is an interactable")


func _check_solution_path(room) -> void:
	room.door.interact(null)
	_expect(not room.door.is_open and not room.rules.is_gate_open(), "A5: the locked gate does not open")
	room.logs[RulesScript.LOG_BEFORE].interact(null)
	room.logs[RulesScript.LOG_AFTER].interact(null)
	_expect(room.rules.has_read_both_logs() and room.door.locked, "A1: reading both logs does not unlock the gate")
	room.breakers["A"].interact(null)
	_expect(room.rules.lamp_lit and room.door.locked, "A2: breaker A lights the lamp but the gate stays locked")
	room.breakers["B"].interact(null)
	room.breakers["B"].interact(null)
	_expect(room.rules.attempts_for("B") == 1 and room.door.locked, "A3: breaker B burns once and a second press is blocked")
	room.breakers["C"].interact(null)
	_expect(room.rules.can_open_gate() and not room.door.locked, "A4: breaker C unlocks the gate")
	_expect(not room.door.is_open, "A5: unlocking does not open the gate by itself")
	room.door.interact(null)
	_expect(room.door.is_open and room.rules.is_gate_open(), "A5: the gate opens and the rules record it")
	_expect(room.hints.solved, "B4: hints stop once the gate is open")
	_expect(room.hints.advance(room.now() + 500.0).is_empty(), "B4: no hint appears after the puzzle is solved")


func _check_telemetry(room) -> void:
	var names: Array = []
	var summary: Dictionary = {}
	var file := FileAccess.open(room.telemetry.file_path(), FileAccess.READ)
	while file != null and not file.eof_reached():
		var line := file.get_line()
		if line.is_empty():
			continue
		var parsed: Dictionary = JSON.parse_string(line)
		names.append(parsed["e"])
		if parsed["e"] == "solved":
			summary = parsed
	_expect(names.has("session_start") and names.has("log_read") and names.has("breaker_used"), "B6: the session records logs and breaker attempts")
	_expect(names.has("gate_opened") and names.has("solved"), "B6: the session records the gate opening and the summary")
	_expect(not summary.is_empty() and summary["attempts"] == 3 and summary["logs_read"] == 2, "B6: the summary counts 3 accepted attempts and 2 logs")


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
