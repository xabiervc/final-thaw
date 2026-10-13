extends Node
## Entrega B, paso 2: el escaner resalta interactuables y scannables sin cambiar el
## comportamiento previo con los interactuables, y las trazas no son objetivo de interaccion.
## Ejecutar: godot --headless --path . res://tests/test_scan_groups.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const ScanScript = preload("res://scripts/components/scan_system.gd")
const TraceScript = preload("res://scripts/components/conduit_trace.gd")
const InteractableScript = preload("res://scripts/components/interactable.gd")
const ManagerScript = preload("res://scripts/components/interaction_manager.gd")

var failed := 0
var passed := 0


class Stub extends Node3D:
	var scanned := false
	var times_on := 0

	func set_scanned(on: bool) -> void:
		scanned = on
		if on:
			times_on += 1


func _ready() -> void:
	await _test_scan_groups()
	await _test_trace_is_not_targetable()
	_test_trace_geometry()
	print("Scan groups: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _make_stub(group_names: Array, pos: Vector3) -> Stub:
	var stub := Stub.new()
	add_child(stub)
	stub.global_position = pos
	for group_name in group_names:
		stub.add_to_group(group_name)
	return stub


func _test_scan_groups() -> void:
	var actor := Node3D.new()
	add_child(actor)
	actor.global_position = Vector3.ZERO
	var scanner = ScanScript.new()
	scanner.actor = actor
	scanner.visuals_enabled = false
	scanner.scan_radius = 6.0
	scanner.highlight_seconds = 0.05
	add_child(scanner)

	var near_i := _make_stub(["interactables"], Vector3(3.0, 0.0, 0.0))
	var far_i := _make_stub(["interactables"], Vector3(10.0, 0.0, 0.0))
	var near_s := _make_stub(["scannables"], Vector3(0.0, 0.0, -4.0))
	var far_s := _make_stub(["scannables"], Vector3(0.0, 0.0, 9.0))
	var both := _make_stub(["interactables", "scannables"], Vector3(2.0, 0.0, 2.0))
	var trace = TraceScript.new()
	trace.trace_id = "c"
	trace.label_text = "East gate"
	trace.route = PackedVector3Array([Vector3.ZERO, Vector3(2.0, 0.0, 0.0), Vector3(2.0, 0.0, 3.0)])
	add_child(trace)
	trace.global_position = Vector3(1.0, 0.0, 1.0)
	var emitted: Array = []
	trace.scanned.connect(func(id: String) -> void: emitted.append(id))

	scanner.scan()
	_expect(near_i.scanned and near_i.times_on == 1, "B7: an interactable inside the radius is highlighted as before")
	_expect(not far_i.scanned, "B7: an interactable outside the radius is not highlighted")
	_expect(near_s.scanned and near_s.times_on == 1, "B1: a scannable inside the radius is highlighted")
	_expect(not far_s.scanned, "B1: a scannable outside the radius is not highlighted")
	_expect(both.scanned and both.times_on == 1, "B1: a node in both groups is highlighted only once")
	_expect(trace.is_scanned() and emitted == ["c"], "B1: the trace lights up and reports its id once")

	await get_tree().create_timer(0.3).timeout
	_expect(not near_i.scanned and not near_s.scanned and not both.scanned, "B1: highlights are cleared after the configured time")
	_expect(not trace.is_scanned(), "B1: the trace stops glowing after the configured time")

	for node in [actor, scanner, near_i, far_i, near_s, far_s, both, trace]:
		node.queue_free()
	await get_tree().process_frame


func _test_trace_is_not_targetable() -> void:
	var actor := Node3D.new()
	add_child(actor)
	actor.global_position = Vector3.ZERO
	var manager = ManagerScript.new()
	manager.actor = actor
	add_child(manager)
	var interactable = InteractableScript.new()
	add_child(interactable)
	interactable.global_position = Vector3(1.5, 0.0, 0.0)
	var trace = TraceScript.new()
	trace.route = PackedVector3Array([Vector3.ZERO, Vector3(1.0, 0.0, 0.0)])
	add_child(trace)
	trace.global_position = Vector3(0.3, 0.0, 0.0)

	_expect(trace.is_in_group("scannables"), "B2: the trace is in the scannables group")
	_expect(not trace.is_in_group("interactables"), "B2: the trace is not in the interactables group")
	manager._process(0.0)
	_expect(manager.current_target == interactable, "B2: the closest trace never steals the interaction target")
	interactable.queue_free()
	await get_tree().process_frame
	manager._process(0.0)
	_expect(manager.current_target == null, "B2: with no interactable nearby there is no target, even next to a trace")

	for node in [actor, manager, trace]:
		node.queue_free()
	await get_tree().process_frame


func _test_trace_geometry() -> void:
	var trace = TraceScript.new()
	trace.route = PackedVector3Array([Vector3.ZERO, Vector3(2.0, 0.0, 0.0), Vector3(2.0, 0.0, 3.0), Vector3(2.0, 0.0, 3.0)])
	trace.label_text = "Light fixture"
	add_child(trace)
	_expect(trace.segment_count() == 2, "B1: a route builds one segment per non-degenerate leg")
	_expect(trace.get_scan_label() == "Light fixture", "B1: the scan label is exposed")
	var empty = TraceScript.new()
	add_child(empty)
	_expect(empty.segment_count() == 0, "B1: an empty route builds nothing and does not fail")
	empty.set_scanned(true)
	_expect(empty.is_scanned(), "B1: an empty trace can still be scanned safely")
	trace.queue_free()
	empty.queue_free()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
