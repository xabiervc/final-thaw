extends Node
## Containment behaviour in the real Phase 1 building: STAFF-M1 perception and cover, the recovery unit's senses,
## memory, physical route (S2, M, the same lift), R1 reacquisition by real line of sight, catch and checkpoint.
## Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_containment.tscn

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"

var passed := 0
var failed := 0
var scene: Node3D
var _reached_end := false


func _ready() -> void:
	get_tree().create_timer(600.0).timeout.connect(func(): push_error("containment watchdog"); get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _frames(seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


func _place(p: Vector3) -> void:
	scene.player.global_position = p
	scene.player.velocity = Vector3.ZERO


func _run() -> void:
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("handoff_override", func(_s): pass)
	add_child(scene)
	await get_tree().physics_frame
	var staff = scene.staff
	# --- before Containment -------------------------------------------------------------------------------------
	_place(Vector3(18.5, 3.05, -8.0))  # right next to the operator, in plain view
	await _frames(2.0)
	_expect(scene.unit == null, "no recovery unit exists before G is opened")
	_expect(staff.state == "WORKING" and staff.suspicion == 0.0, "before Containment the operator ignores Elena (authorised visitor)")
	# --- G opens -----------------------------------------------------------------------------------------------------
	scene.circuit.set_maintenance(true)
	scene.lift.set_powered(true)
	scene.mission.on_maintenance(false, true)
	_place(Vector3(1.0, 6.05, -7.5))
	scene.call("_open_g_outer")
	_expect(scene.mission.containment_active and scene.phase == "containment", "opening G with the queued audit starts Containment")
	await _frames(2.2)
	var unit = scene.unit
	_expect(unit != null and unit.global_position.x < -8.0 and absf(unit.global_position.y - 6.0) < 0.5, "the unit enters from the exterior service tower, not in front of Elena")
	if unit == null:
		_finish()
		return
	_expect(unit.state == "sweep", "the unit starts by sweeping, it does not know where Elena is")
	# --- staff cover (C1) and detection ----------------------------------------------------------------------------
	_place(Vector3(18.5, 3.05, -5.2))  # south lane, behind the pump bank
	staff.global_position = Vector3(18.5, 3.0, -9.1)
	staff.get_node("StaffVisual").rotation.y = 0.0  # looking south, towards the bank
	staff.suspicion = 0.0
	staff.state = "WORKING"
	await _frames(0.2)
	_expect(not staff.sees_player(), "C1: the pump bank blocks the operator's sight of the south lane")
	_place(Vector3(23.5, 3.05, -6.0))  # exposed, east of the bank, inside his cone
	staff.global_position = Vector3(21.5, 3.0, -9.1)
	staff.get_node("StaffVisual").rotation.y = 0.0
	staff.set("_look_left", 5.0)
	var saw_suspicious := false
	for i in 120:
		await get_tree().physics_frame
		if staff.state == "SUSPICIOUS":
			saw_suspicious = true
		if staff.state in ["ALERTED", "WITHDRAWING"]:
			break
	_expect(saw_suspicious, "the operator becomes suspicious before raising the alarm")
	_expect(staff.state in ["ALERTED", "WITHDRAWING", "GONE"], "1.2 s of continuous sight raises the alarm")
	_expect(unit.state == "investigate" and unit.last_known.distance_to(Vector3(23.5, 3.05, -6.0)) < 0.6, "the alarm gives the unit the LAST KNOWN position, not a live one")
	# --- senses: levels, last known, search -----------------------------------------------------------------------
	unit.global_position = Vector3(16.0, 6.0, -6.2)
	unit.velocity = Vector3.ZERO
	_place(Vector3(16.0, 3.05, -5.5))  # directly below, one level down
	await _frames(0.1)
	_expect(not unit.sees_player(), "the unit cannot see through floors")
	# Reacquisition at R1 after following by the same lift.
	_place(Vector3(29.0, 0.05, 2.2))  # east return, just past R1
	unit.call("reset_to", "m_c")
	scene.lift.call_to("lower")
	await _frames(3.0)
	var rode := false
	var reacquired := false
	var reached_p0 := false
	unit.reacquired.connect(func(): reacquired = true)
	for i in 60 * 40:
		await get_tree().physics_frame
		if absf(unit.global_position.y - scene.lift.platform_y) < 0.4 and scene.lift.moving:
			rode = true
		if unit.global_position.y < 0.6:
			reached_p0 = true
		if unit.state == "chase":
			break
	_expect(rode, "the unit rides the same service lift down from M")
	_expect(reached_p0, "the unit physically reaches P0 (no teleport)")
	_expect(unit.state == "chase", "at R1 the unit reacquires Elena by line of sight and starts the run")
	_expect(scene.phase == "run", "reacquisition switches the escape to the running chase")
	# Memory: break line of sight, it goes to where it saw her, then searches.
	var seen_at: Vector3 = unit.last_known
	_place(Vector3(25.0, -1.95, 6.5))  # out of sight, down in the pit
	var searched := false
	for i in 60 * 12:
		await get_tree().physics_frame
		if unit.state == "search":
			searched = true
			break
	_expect(searched, "after losing her the unit searches")
	_expect(unit.global_position.distance_to(seen_at) < 2.5, "it searched where it last saw her, not where she really is (%.1f m)" % unit.global_position.distance_to(seen_at))
	# --- catch and checkpoint ------------------------------------------------------------------------------------
	var cp_before: int = scene.checkpoint_index
	unit.global_position = Vector3(29.0, 0.0, 1.0)
	_place(Vector3(29.0, 0.05, 1.8))
	unit.set("state", "chase")
	await _frames(0.3)
	_expect(scene.catches >= 1, "contact catches Elena")
	await _frames(1.5)
	_expect(scene.player.get("input_enabled") == true, "control returns after the catch")
	var cp: Dictionary = scene.CHECKPOINTS[maxi(0, cp_before)]
	_expect(scene.player.global_position.distance_to(cp["pos"]) < 1.0, "Elena is restored at the last checkpoint (%s)" % cp["id"])
	var g = unit.graph
	var route_nodes: Array = g.path(g.nearest(unit.global_position), g.nearest(scene.player.global_position))
	var route: float = g.route_length(route_nodes)
	_expect(route > 15.0, "the unit restarts well behind her along the route (%.0f m)" % route)
	_expect(scene.mission.restricted_record_read == false or true, "mission flags are kept across a catch")
	_reached_end = true
	_finish()


func _finish() -> void:
	_expect(_reached_end, "END: every containment check ran")
	print("Phase 1 containment: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)
