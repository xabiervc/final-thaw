extends Node
## Containment behaviour in the real building and yard: the recovery unit's senses (cone, floors, crouch, darkness,
## hearing), readable suspicion, memory and trail check, search and loss of contact, noise misdirection, physical
## route (the same lift), R1 reacquisition by real line of sight, difficulty tuning, catch and checkpoint.
## (2026-10-15: STAFF-M1 was removed from the game, so its perception checks were replaced by the unit's own
## suspicion stage, which now carries the quiet section.)
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


## Puts the unit at `at`, facing `facing` (a point), in a fresh sweep with no awareness.
func _pose_unit(unit, at: Vector3, facing: Vector3) -> void:
	unit.global_position = at
	unit.velocity = Vector3.ZERO
	unit.awareness = 0.0
	var to := facing - at
	unit.get_node("UnitVisual").rotation.y = atan2(to.x, to.z)


func _run() -> void:
	GameSettings.set_value("difficulty", "standard")
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("play_intro", false)
	add_child(scene)
	await get_tree().physics_frame
	# --- before Containment -------------------------------------------------------------------------------------
	_place(Vector3(18.5, 3.05, -6.0))
	await _frames(1.0)
	_expect(scene.unit == null, "no recovery unit exists before G is opened")
	_expect(not scene.has_node("StaffM1"), "STAFF-M1 is no longer part of the game")
	# --- G opens -----------------------------------------------------------------------------------------------------
	scene.circuit.set_maintenance(true)
	scene.transfer.complete_power_chain_for_test()  # the lift runs on maintenance AND the auxiliary supply
	scene.mission.on_maintenance(false, true)
	scene.mission.on_record_read()
	_place(Vector3(1.0, 6.05, -7.5))
	scene.call("_open_g_outer")
	_expect(scene.mission.containment_active and scene.phase == "containment", "opening G with the queued audit (record read) starts Containment")
	await _frames(2.2)
	var unit = scene.unit
	_expect(unit != null and unit.global_position.x < -8.0 and absf(unit.global_position.y - 6.0) < 0.5, "the unit enters from the exterior service tower, not in front of Elena")
	if unit == null:
		_finish()
		return
	_expect(unit.state == "sweep", "the unit starts by sweeping, it does not know where Elena is")
	# --- readable suspicion and fair recovery -------------------------------------------------------------------
	_pose_unit(unit, Vector3(11.0, 6.0, -6.2), Vector3(20.0, 6.0, -6.2))
	unit.set("_path", [])
	_place(Vector3(18.6, 6.05, -6.2))  # 7.6 m ahead, in the cone, standing still
	var suspicious := false
	for i in 40:
		await get_tree().physics_frame
		unit.set("_path", [])
		if str(unit.call("display_state")) == "suspicious":
			suspicious = true
	_expect(suspicious, "at the edge of its range the unit first becomes SUSPICIOUS ('?' fading in), not instantly alerted")
	_place(Vector3(16.0, 3.05, -5.5))  # drop out of sight (one level down): nothing new to perceive
	var stayed_calm := true
	for i in 150:
		await get_tree().physics_frame
		if unit.state in ["alert", "chase"]:
			stayed_calm = false
	_expect(stayed_calm and unit.awareness < 0.2, "breaking line of sight early lets the suspicion decay without an alert (%.2f)" % unit.awareness)
	# --- senses: floors, crouch, hearing ------------------------------------------------------------------------
	# Pure perception queries, made right after posing (no frame passes, so the unit cannot turn away).
	_pose_unit(unit, Vector3(16.0, 6.0, -6.2), Vector3(16.0, 6.0, -1.0))
	_place(Vector3(16.0, 3.05, -5.5))
	_expect(not unit.sees_player(), "the unit cannot see through floors")
	_pose_unit(unit, Vector3(11.0, 6.0, -6.2), Vector3(20.0, 6.0, -6.2))
	_place(Vector3(17.5, 6.05, -6.2))  # 6.5 m ahead
	var standing_seen: bool = unit.sees_player()
	scene.player.call("_set_crouching", true)
	var crouched_seen: bool = unit.sees_player()
	scene.player.call("_set_crouching", false)
	_expect(standing_seen and not crouched_seen, "6.5 m ahead: seen standing, not seen crouched (cone x0.55)")
	_pose_unit(unit, Vector3(11.0, 6.0, -6.2), Vector3(4.0, 6.0, -6.2))  # facing away
	_place(Vector3(17.0, 6.05, -6.2))
	scene.player.velocity = Vector3(6.5, 0, 0)
	scene.player.set("is_running", true)
	var heard_running: bool = unit.hears_player()
	scene.player.set("is_running", false)
	scene.player.set("is_crouching", true)
	scene.player.velocity = Vector3(1.2, 0, 0)
	var heard_crouched: bool = unit.hears_player()
	scene.player.set("is_crouching", false)
	scene.player.velocity = Vector3.ZERO
	_expect(heard_running and not heard_crouched, "behind it at 6 m: running is heard, crouch-walking is not")
	# --- darkness in the yard -------------------------------------------------------------------------------------
	var lit: float = scene.parking.exposure_at(Vector3(35.8, -2.0, 6.0))
	var dark: float = scene.parking.exposure_at(Vector3(56.0, -2.0, -12.0))
	_expect(lit > 0.9 and dark < 0.1, "the yard has lit pools and dark pockets (%.2f / %.2f)" % [lit, dark])
	_place(Vector3(56.0, -1.95, -12.0))
	var range_dark: float = unit.vision_range()
	_place(Vector3(35.8, -1.95, 6.0))
	var range_lit: float = unit.vision_range()
	_expect(range_dark < range_lit * 0.7, "in the dark the unit sees less far (%.1f m vs %.1f m)" % [range_dark, range_lit])
	# --- difficulty changes what the unit can do ----------------------------------------------------------------
	GameSettings.set_value("difficulty", "explorer")
	var explorer_range: float = unit.vision_range_base
	var explorer_speed: float = unit.chase_speed
	GameSettings.set_value("difficulty", "demanding")
	var demanding_range: float = unit.vision_range_base
	GameSettings.set_value("difficulty", "standard")
	_expect(explorer_range < 9.0 and demanding_range > 9.0 and explorer_speed < unit.chase_speed, "difficulty changes the unit's vision (%.1f / 9 / %.1f m) and pace" % [explorer_range, demanding_range])
	_expect(is_equal_approx(float(scene.player.get("run_drain")), GameSettings.tuning("run_drain")), "difficulty changes Elena's stamina drain while running")
	# --- lift ride and reacquisition at R1 ------------------------------------------------------------------------
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
	_expect(str(scene.player.get("camera_mode")) == "pursuit", "the chase switches to the closer pursuit camera")
	# --- memory: last known, trail check, search, loss of contact ------------------------------------------------
	var seen := {"lost": false}  # lambdas capture locals by value: share a dictionary
	unit.lost_contact.connect(func(): seen["lost"] = true)
	var seen_at: Vector3 = unit.last_known
	_place(Vector3(25.0, -1.95, 6.5))  # out of sight, down in the pit
	var searched := false
	for i in 60 * 14:
		await get_tree().physics_frame
		if unit.state == "search":
			searched = true
			break
	_expect(bool(seen["lost"]), "breaking contact is reported (lost_contact)")
	_expect(searched, "after losing her the unit searches")
	_expect(unit.global_position.distance_to(seen_at) < 7.0, "it searched around where it last saw her (and the trail she took), not where she is (%.1f m)" % unit.global_position.distance_to(seen_at))
	var returned := false
	for i in 60 * 8:
		await get_tree().physics_frame
		if unit.state == "sweep":
			returned = true
			break
	_expect(returned and unit.awareness < 0.01, "with no new contact it gives up the search and resumes the protocol sweep")
	_expect(str(scene.player.get("camera_mode")) == "explore", "the camera returns to the exploration framing after contact is lost")
	# --- noise misdirection in the yard ---------------------------------------------------------------------------
	_place(Vector3(37.0, -1.95, 6.0))
	await _frames(0.3)
	_expect(scene.in_yard, "Elena is in the yard")
	unit.call("reset_to", "ya_2")
	_place(Vector3(41.5, -1.95, -12.4))  # in an empty bay of the dark north row, far from the unit
	scene.call("_start_compressor")
	await _frames(2.6)
	_expect(unit.state == "investigate" and unit.last_known.distance_to(scene.Parking.COMPRESSOR_NOISE_AT) < 0.5, "the delayed compressor draws the unit to the cage (a place, not Elena)")
	# --- climbing onto cover is not a safe spot next to the unit -----------------------------------------------
	unit.global_position = Vector3(46.05, -2.0, -13.0)  # beside the covered car in bay 44.5 (north row)
	_place(Vector3(45.2, -0.55, -13.0))  # standing on the car roof, at the edge
	unit.set("state", "chase")
	var caught_before: int = scene.catches
	await _frames(0.2)
	_expect(scene.catches > caught_before, "the unit's manipulators reach Elena on a car roof at the edge (no safe exploit)")
	await _frames(1.5)
	# --- catch and checkpoint ------------------------------------------------------------------------------------
	scene.set("in_yard", false)
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
	_expect(bool(scene.player.call("_capsule_fits", scene.player.global_position + Vector3(0, 0.05, 0), 1.7)), "the restore point is not inside geometry")
	var g = unit.graph
	var route_nodes: Array = g.path(g.nearest(unit.global_position), g.nearest(scene.player.global_position))
	var route: float = g.route_length(route_nodes)
	_expect(route > 15.0, "the unit restarts well behind her along the route (%.0f m)" % route)
	_expect(scene.mission.restricted_record_read and scene.notes.has("containment"), "mission flags and notes are kept across a catch")
	_reached_end = true
	_finish()


func _finish() -> void:
	_expect(_reached_end, "END: every containment check ran")
	print("Phase 1 containment: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)
