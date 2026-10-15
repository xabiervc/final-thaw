extends Node
## Simulated first playthrough of Phases 1 and 2 with the real player body and real input actions
## (tests/support/route_bot.gd). Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_playthrough.tscn
## Every leg is walked by pressing movement actions; the player is never moved by the test. A failure names the leg,
## the kind (STUCK, FELL, TIMEOUT) and the place. The escape is walked with the recovery unit disabled: this test
## proves the route is physically continuous from the tunnel to the street; the unit has its own tests.
## (2026-10-15: the Phase 1 -> parking scene handoff no longer exists; the yard is part of the same scene, so the
## old handoff assertions were replaced by the yard route, the ending and the results.)

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const RouteBot := preload("res://tests/support/route_bot.gd")

var passed := 0
var failed := 0
var scene: Node3D
var bot
var results_seen: Dictionary = {}
var _reached_end := false


func _ready() -> void:
	get_tree().create_timer(900.0).timeout.connect(func(): push_error("playthrough watchdog"); get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _leg(result: Dictionary) -> bool:
	_expect(bool(result["ok"]), "%s%s" % [result["label"], "" if result["ok"] else " -> %s %s" % [result.get("kind", ""), result.get("detail", "")]])
	return bool(result["ok"])


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("play_intro", false)
	scene.set("spawn_unit_enabled", false)
	scene.set("ending_override", func(r): results_seen = r)
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame
	bot = RouteBot.new()
	add_child(bot)
	bot.player = scene.player
	bot.before_step = func(): scene.player.set("orbit_yaw", 0.0)
	if await _investigation() and await _control_room() and await _escape():
		_reached_end = true
	bot.release_all()
	_expect(_reached_end, "END: the whole Phase 1 + 2 route was walked without teleporting Elena")
	print("Phase 1 playthrough: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _investigation() -> bool:
	_expect(scene.phase == "investigation" and bool(scene.player.get("input_enabled")), "without the intro, play starts at once with input enabled")
	if not _leg(await bot.walk("tunnel -> access A -> evacuation plan", [Vector3(-0.5, 0, 6), Vector3(1.4, 0, 7.6), Vector3(1.1, 0, 8.9)], {"min_y": -0.5})):
		return false
	await bot.interact("evacuation plan")
	_expect(scene.notes.has("access_plan"), "the evacuation plan at the access can be examined")
	if not _leg(await bot.walk("access A -> nave B", [Vector3(3, 0, 6.5), Vector3(8, 0, 7), Vector3(12, 0, 0)], {"min_y": -0.5})):
		return false
	if not _leg(await bot.walk("nave -> workshop tag", [Vector3(16.5, 0, -1.2), Vector3(19, 0, -6.0), Vector3(21.0, 0, -6.0)], {"min_y": -0.5})):
		return false
	await bot.interact("workshop repair tag")
	_expect(scene.notes.has("workshop_tag"), "the workshop repair tag can be examined")
	if not _leg(await bot.walk("workshop -> around the pit -> S1 top", [Vector3(19, 0, -6.0), Vector3(16.5, 0, -1.2), Vector3(8.6, 0, 0.6), Vector3(8.6, 0, 10.0), Vector3(22.5, 0, 10.0), Vector3(23.2, 0, 12.4), Vector3(25, 0, 12.4)], {"min_y": -0.5})):
		return false
	if not _leg(await bot.walk("S1 down -> D2", [Vector3(25, -1, 9.5), Vector3(25, -2, 7.2), Vector3(26.7, -2, 3.6)], {"min_y": -2.5})):
		return false
	await bot.interact("schematic")
	_expect(scene.notes.has("schematic"), "the schematic is readable from the pit floor")
	_expect(not scene.notes.has("hypothesis"), "the schematic alone does not form the hypothesis")
	if not _leg(await bot.walk("D2 -> bridge A-T", [Vector3(21.5, -2, 5.0)], {"min_y": -2.5})):
		return false
	await bot.interact("bridge")
	_expect(scene.notes.has("bridge"), "the tampered bridge can be examined")
	_expect(scene.notes.has("hypothesis"), "schematic + physical contradiction derive the hypothesis")
	if not _leg(await bot.walk("bridge -> maintenance switch", [Vector3(26.4, -2, 2.4)], {"min_y": -2.5})):
		return false
	await bot.interact("maintenance switch")
	_expect(scene.circuit.maintenance_on, "maintenance switch reachable and accepted from the pit floor")
	_expect(scene.mission.service_override_queued, "maintenance OFF -> ON queued SERVICE_OVERRIDE")
	_expect(scene.notes.has("maintenance_risk"), "the queued audit is recorded in the notes (cause made explicit)")
	if not _leg(await bot.walk("D2 -> S1 up -> south band -> east return -> bridge -> service gallery", [Vector3(25, -2, 7.2), Vector3(25, 0, 12.4), Vector3(29, 0, 12.4), Vector3(29, 0, 9.6), Vector3(29, 0.35, 6.0), Vector3(29, 0, 2.7), Vector3(29, 0, 0.0), Vector3(28.2, 0, -1.0)], {"min_y": -2.5})):
		return false
	await bot.interact("lift call P0")
	await bot.wait(1.0)
	if not _leg(await bot.walk("step onto the lift deck", [Vector3(26.5, 0, -0.6), Vector3(26.0, 0, -3.0)], {"min_y": -0.7})):
		return false
	await bot.interact("lift send")
	await bot.wait(5.0)
	_expect(scene.player.global_position.y > 2.8, "the lift carried Elena to M (y=%.2f)" % scene.player.global_position.y)
	if not _leg(await bot.walk("lift -> pump room south lane -> S2 foot", [Vector3(26, 3, -5.6), Vector3(23, 3, -5.4), Vector3(18.5, 3, -5.4), Vector3(12, 3, -5.4), Vector3(8.3, 3, -5.2)], {"min_y": 2.5})):
		return false
	return _leg(await bot.walk("S2 up -> walkway -> control E", [Vector3(8.3, 3.0, -3.2), Vector3(13.0, 5.7, -3.2), Vector3(15.5, 6, -4.0), Vector3(17.5, 6, -6.4)], {"min_y": 2.5}))


func _control_room() -> bool:
	if not _leg(await bot.walk("E -> official report desk", [Vector3(13.6, 6, -7.2)], {"min_y": 5.5})):
		return false
	await bot.interact("official report")
	_expect(scene.notes.has("official_report"), "the official report can be read in control")
	# Safe order: isolate trial, select ARCHIVO, check.
	if not _leg(await bot.walk("E -> isolator", [Vector3(16, 6, -6.4), Vector3(19, 6, -7.4)], {"min_y": 5.5})):
		return false
	await bot.interact("isolator")
	_expect(scene.circuit.trial_isolated, "the isolator isolates the trial branch")
	if not _leg(await bot.walk("isolator -> selector", [Vector3(15, 6, -6.4), Vector3(12, 6, -7.4)], {"min_y": 5.5})):
		return false
	await bot.interact("selector")
	_expect(scene.circuit.outputs()["archive"], "isolate-then-select gives a stable ARCHIVO without a trip")
	_expect(scene.circuit.last_trip == null or str(scene.circuit.last_trip) == "", "the safe order records no trip")
	# Negative path: leaving before reading the record is refused (Elena will not go without it), no audit.
	if not _leg(await bot.walk("selector -> F -> G inner door (record not read yet)", [Vector3(10.5, 6, -6.6), Vector3(7.5, 6, -6.6), Vector3(4.0, 6, -7.3)], {"min_y": 5.5})):
		return false
	await bot.interact("G inner door")
	_expect(scene.get("_g_inner_open"), "the inner leaf of G opens")
	if not _leg(await bot.walk("into the airlock G", [Vector3(1.6, 6, -7.4), Vector3(0.75, 6, -7.5)], {"min_y": 5.5})):
		return false
	await bot.interact("G outer door (too early)")
	_expect(scene.phase == "investigation" and not scene.mission.audit_sent, "G's outer leaf is not operated before the record is read")
	if not _leg(await bot.walk("back to the archive console", [Vector3(1.6, 6, -7.4), Vector3(4.0, 6, -7.3), Vector3(4.6, 6, -8.6)], {"min_y": 5.5})):
		return false
	await bot.interact("archive")
	_expect(scene.mission.restricted_record_read, "the archive is readable with ARCHIVO stable (RESTRICTED_RECORD_READ)")
	_expect(not scene.mission.containment_active and scene.phase == "investigation", "reading the record does not start Containment")
	_expect(scene.notes.has("conclusion"), "the record derives the conclusion")
	if not _leg(await bot.walk("archive -> airlock G", [Vector3(4.0, 6, -7.3), Vector3(1.6, 6, -7.4), Vector3(0.75, 6, -7.5)], {"min_y": 5.5})):
		return false
	await bot.interact("G outer door")
	_expect(scene.mission.audit_sent and scene.mission.containment_active, "opening G's outer leaf sends the audit and starts Containment")
	scene.call("_open_g_outer")
	_expect(scene.mission.on_open_g() == "already", "a second opening does not duplicate the audit")
	return true


func _escape() -> bool:
	await bot.wait(1.2)
	if not _leg(await bot.walk("retreat G -> F -> past the fallen shelf -> E", [Vector3(1.6, 6, -7.4), Vector3(4.0, 6, -7.3), Vector3(6.0, 6, -6.4), Vector3(9.6, 6, -6.4), Vector3(12, 6, -6.0), Vector3(16, 6, -5.6)], {"min_y": 5.5})):
		return false
	if not _leg(await bot.walk("walkway -> S2 down -> pump room", [Vector3(15.5, 6, -4.0), Vector3(13.0, 5.7, -3.2), Vector3(8.3, 3.0, -3.2), Vector3(8.3, 3, -5.2), Vector3(12, 3, -5.4)], {"min_y": 2.5})):
		return false
	if not _leg(await bot.walk("pump room south lane (behind C1) -> lift", [Vector3(18.5, 3, -5.4), Vector3(23, 3, -5.4), Vector3(26, 3, -5.6)], {"min_y": 2.5})):
		return false
	await bot.interact("lift call M")
	await bot.wait(1.0)
	if not _leg(await bot.walk("onto the deck at M", [Vector3(26, 3, -3.0)], {"min_y": 2.5})):
		return false
	await bot.interact("lift send down")
	await bot.wait(5.0)
	_expect(absf(scene.player.global_position.y) < 0.3, "the lift brought Elena down to P0")
	if not _leg(await bot.walk("P0 lift -> service gallery -> R1 crank", [Vector3(26, 0, -0.9), Vector3(26.6, 0, -1.2), Vector3(29.0, 0, -1.0), Vector3(29.4, 0, 0.2)], {"min_y": -0.5, "run": true})):
		return false
	_expect(scene.r1_opening < 0.05, "Containment sealed the sector shutter at R1")
	await bot.interact("R1 emergency release")
	var waited := 0.0
	while scene.r1_opening < 1.15 and waited < 15.0:
		await bot.wait(0.25)
		waited += 0.25
	_expect(scene.r1_opening >= 1.1, "the emergency release raises the shutter to crouching height (%.1f s)" % waited)
	if not _leg(await bot.walk("crouch under the shutter -> east return", [Vector3(29, 0, 0.6), Vector3(29, 0, 1.8), Vector3(29, 0, 2.7)], {"min_y": -0.5, "crouch": true})):
		return false
	_expect(scene.get("_o3_dropped"), "O3 (cable tray) came down in the service gallery behind Elena")
	if not _leg(await bot.walk("bridge -> south band -> S1 top", [Vector3(29, 0.35, 6.0), Vector3(29, 0, 9.6), Vector3(28, 0, 12.4), Vector3(25, 0, 12.4), Vector3(25, 0, 11.6)], {"min_y": -0.5, "run": true})):
		return false
	if not _leg(await bot.walk("S1 down -> pit -> evacuation gallery -> east mouth -> yard", [Vector3(25, -1, 9.5), Vector3(25, -2, 7.2), Vector3(27, -2, 6.0), Vector3(29.5, -2, 6.0), Vector3(33.2, -2, 6.0), Vector3(36.0, -2, 6.0)], {"min_y": -2.5, "run": true})):
		return false
	await bot.wait(0.3)
	_expect(scene.in_yard and scene.notes.has("parking"), "the yard is entered in the same scene (no scene change, no teleport)")
	await bot.wait(4.0)
	_expect(scene.parking.pool_on.count(true) == scene.parking.POOLS.size(), "the facility response switched on every yard floodlight")
	_expect(absf(scene.parking.boom.rotation.z) < 0.05, "the vehicle-lane boom came down")
	if not _leg(await bot.walk("yard route A (south, exposed) -> convergence", [Vector3(38.5, -2, 6.0), Vector3(43, -2, 4.5), Vector3(52, -2, 4.5), Vector3(61, -2, 4.5), Vector3(68, -2, 4.0), Vector3(70.5, -2, 1.2)], {"min_y": -2.5})):
		return false
	_expect(scene.checkpoint_index >= 5, "the convergence checkpoint is set")
	if not _leg(await bot.walk("O3 aperture -> egress enclosure -> emergency lane", [Vector3(72.95, -2, 0.6), Vector3(72.95, -2, -2.4), Vector3(72.95, -2, -10.0), Vector3(72.7, -2, -14.2)], {"min_y": -2.5})):
		return false
	if not _leg(await bot.walk("through the pedestrian emergency lane (beside the lowered boom)", [Vector3(72.7, -2, -15.6), Vector3(72.7, -1.7, -17.2)], {"min_y": -2.5})):
		return false
	_expect(scene.phase in ["escaped", "ended"], "crossing the north gate ends the escape")
	var end_wait := 0.0
	while results_seen.is_empty() and end_wait < 60.0:
		await bot.wait(0.5)
		end_wait += 0.5
	_expect(not results_seen.is_empty(), "the ending cinematic plays to the end and reports the results (%.0f s)" % end_wait)
	if not results_seen.is_empty():
		_expect(int(results_seen["notes"]) >= 12 and int(results_seen["catches"]) == 0, "results: %d notes, %d catches" % [int(results_seen["notes"]), int(results_seen["catches"])])
	_expect(not get_tree().paused, "the game is not left paused after the ending")
	return true
