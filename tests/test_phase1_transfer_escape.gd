extends Node
## The escape that starts in the second building, with the recovery unit live: the staff notice Elena in the vestibule, the bay
## door opens and the unit comes through it; she runs back through the transfer door, the dead workshop, the cable gallery and
## the stair, along the south band to S1, down to the pit, through the evacuation gallery and across the yard.
## Fairness and continuity: the run must be completable without a catch by a player who runs at once; the unit must start in
## the bay (not in front of her), follow her on foot without ever jumping position, and still be hunting at the yard's mouth.
## Also the catch on this route: restored at checkpoint B2 on the stair side, with the unit restarted well behind her.
## Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_transfer_escape.tscn

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const RouteBot := preload("res://tests/support/route_bot.gd")

var passed := 0
var failed := 0
var scene: Node3D
var bot
var results_seen: Dictionary = {}
var _unit_trace: Array[Vector3] = []


func _ready() -> void:
	get_tree().create_timer(600.0).timeout.connect(func(): push_error("transfer escape watchdog"); get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _walk(label: String, pts: Array, opts: Dictionary) -> bool:
	var r: Dictionary = await bot.walk(label, pts, opts)
	if not bool(r["ok"]):
		print("leg %s: %s %s (catches=%d)" % [label, r.get("kind", ""), r.get("detail", ""), scene.catches])
	return bool(r["ok"])


func _record_unit() -> void:
	if scene != null and scene.unit != null and is_instance_valid(scene.unit):
		_unit_trace.append(scene.unit.global_position)


func _run() -> void:
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("play_intro", false)
	scene.set("ending_override", func(r): results_seen = r)
	add_child(scene)
	await get_tree().physics_frame
	bot = RouteBot.new()
	add_child(bot)
	bot.player = scene.player
	bot.before_step = func(): scene.player.set("orbit_yaw", 0.0)
	get_tree().physics_frame.connect(_record_unit)
	# The investigation as a player leaves it: the whole chain done, the record read, the door open, Elena at the bay's window.
	scene.circuit.set_maintenance(true)
	scene.mission.on_maintenance(false, true)
	scene.transfer.apply_state_for_test({"DRAWER_OPEN": true, "DRAWER_EMPTIED": true, "SUBSTATION_UNLOCKED": true, "BRIDGE_INSERTED": true,
		"PowerRestored": true, "HiddenDoorDiscovered": true, "CABINET_OPENED": true, "TRANSFER_DOOR_OPEN": true})
	scene.mission.on_record_read()
	scene.player.global_position = Vector3(34.7, -3.95, 18.9)
	scene.player.velocity = Vector3.ZERO
	await bot.wait(0.6)
	_expect(scene.transfer.crossed and not scene.transfer.detected and scene.unit == null, "Elena is inside, unnoticed, and no unit exists yet")
	# The staff notice her (the same call the 22 s clock and the bay-door proximity make).
	scene.transfer.call("_noticed")
	_expect(scene.phase == "containment" and scene.checkpoint_index == scene.CP_B2, "noticed: Containment, checkpoint B2")
	var t0 := Time.get_ticks_msec()
	# A player who runs at once: out through the transfer door, along the gallery, up the stair.
	var ok: bool = await _walk("vestibule -> transfer door -> dead workshop -> gallery (run)", [Vector3(31.0, -4, 17.2), Vector3(29.0, -4, 17.2), Vector3(27.4, -4, 15.5), Vector3(26.9, -4, 13.7), Vector3(26.9, -4, 12.4), Vector3(14.8, -4, 12.4)], {"min_y": -4.6, "run": true})
	_expect(scene.unit != null, "the unit came into the world while she ran")
	if scene.unit != null:
		var first: Vector3 = _unit_trace[0] if not _unit_trace.is_empty() else Vector3.ZERO
		_expect(first.distance_to(Vector3(31.2, -4.0, 22.6)) < 1.5 and absf(first.y - (-4.0)) < 0.3, "the unit starts in the bay, behind the glass and the bay door (%s), not in front of her" % first)
	ok = ok and await _walk("stair up -> south band -> S1 (run)", [Vector3(11.2, -2, 12.4), Vector3(8.4, -0.1, 12.4), Vector3(7.6, 0, 12.0), Vector3(7.6, 0, 10.6), Vector3(8.6, 0, 10.0), Vector3(22.5, 0, 10.0), Vector3(23.2, 0, 12.4), Vector3(25, 0, 12.4), Vector3(25, 0, 11.6)], {"min_y": -4.6, "run": true})
	var unit_at_s1: String = str(scene.unit.state) if scene.unit != null else "-"
	ok = ok and await _walk("S1 -> gallery -> mouth (run)", [Vector3(25, -1, 9.5), Vector3(25, -2, 7.2), Vector3(27, -2, 6.0), Vector3(29.5, -2, 6.0), Vector3(33.2, -2, 6.0), Vector3(36.0, -2, 6.0)], {"min_y": -2.5, "run": true})
	var unit_state_at_mouth: String = str(scene.unit.state) if scene.unit != null else "-"
	print("at the yard: %.1f s, catches %d, unit %s (at S1: %s) at %s" % [(Time.get_ticks_msec() - t0) / 1000.0, scene.catches, unit_state_at_mouth, unit_at_s1, scene.unit.global_position if scene.unit != null else Vector3.ZERO])
	ok = ok and await _walk("yard: north lane, walking", [Vector3(38.5, -2, 6.0), Vector3(38.5, -2, -6.6), Vector3(49, -2, -6.6), Vector3(56.5, -2, -6.6), Vector3(61, -2, -6.6), Vector3(66.5, -2, -6.0)], {"min_y": -2.5})
	ok = ok and await _walk("yard: convergence (run)", [Vector3(68.2, -2, -0.4), Vector3(70.5, -2, 1.2)], {"min_y": -2.5, "run": true})
	ok = ok and await _walk("yard: O3 aperture -> emergency lane -> out", [Vector3(72.95, -2, 0.6), Vector3(72.95, -2, -2.4), Vector3(72.95, -2, -10.0), Vector3(72.7, -2, -14.2), Vector3(72.7, -2, -15.6), Vector3(72.7, -1.7, -17.2)], {"min_y": -2.5, "run": true})
	bot.release_all()
	print("escape time %.1f s, catches %d" % [(Time.get_ticks_msec() - t0) / 1000.0, scene.catches])
	_expect(ok, "a player who runs at once completes the route from the second building to the north gate")
	_expect(scene.catches == 0, "the route is fair: no catch (%d)" % scene.catches)
	_expect(unit_state_at_mouth in ["chase", "alert", "search", "investigate", "sweep"] and scene.unit != null, "the unit is still hunting when she reaches the yard (not reset at the mouth)")
	var worst := 0.0
	for i in range(1, _unit_trace.size()):
		worst = maxf(worst, _unit_trace[i].distance_to(_unit_trace[i - 1]))
	_expect(_unit_trace.size() > 60 and worst < 0.5, "the unit never jumps: largest step in one physics frame is %.2f m over %d frames" % [worst, _unit_trace.size()])
	_expect(scene.phase in ["escaped", "ended"], "the escape ends at the north gate")
	await _catch_and_restore()
	print("Phase 1 transfer escape: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


## A catch on this route restores her at B2 (the stair side), with the unit restarted well behind her.
func _catch_and_restore() -> void:
	var s2 = (load(SCENE) as PackedScene).instantiate()
	s2.set("play_intro", false)
	add_child(s2)
	await get_tree().physics_frame
	s2.circuit.set_maintenance(true)
	s2.transfer.apply_state_for_test({"DRAWER_OPEN": true, "DRAWER_EMPTIED": true, "SUBSTATION_UNLOCKED": true, "BRIDGE_INSERTED": true,
		"PowerRestored": true, "HiddenDoorDiscovered": true, "CABINET_OPENED": true, "TRANSFER_DOOR_OPEN": true})
	s2.mission.on_record_read()
	s2.player.global_position = Vector3(32.0, -3.95, 17.2)
	await get_tree().physics_frame
	s2.transfer.call("_noticed")
	await get_tree().create_timer(2.2).timeout
	_expect(s2.unit != null, "(catch test) the unit exists")
	s2.player.global_position = Vector3(27.0, -3.95, 15.6)
	s2.unit.global_position = Vector3(27.0, -4.0, 14.5)
	s2.unit.set("state", "chase")
	await get_tree().create_timer(0.4).timeout
	_expect(s2.catches >= 1, "(catch test) contact catches Elena in the dead workshop")
	await get_tree().create_timer(1.8).timeout
	var cp: Dictionary = s2.CHECKPOINTS[s2.CP_B2]
	_expect(s2.player.global_position.distance_to(cp["pos"]) < 1.0, "(catch test) she is restored at checkpoint B2 on the stair side (%s)" % s2.player.global_position)
	_expect(bool(s2.player.call("_capsule_fits", s2.player.global_position + Vector3(0, 0.05, 0), 1.7)), "(catch test) the restore point is not inside geometry")
	var g = s2.unit.graph
	var route: float = g.route_length(g.path(g.nearest(s2.unit.global_position), g.nearest(s2.player.global_position)))
	_expect(route > 15.0, "(catch test) the unit restarts well behind her along the route (%.0f m)" % route)
	var chest: Vector3 = s2.player.global_position + Vector3(0, 1.2, 0)
	_expect(not bool(s2.unit.call("line_clear", s2.unit.global_position + Vector3(0, 1.7, 0), chest)) or s2.unit.global_position.distance_to(s2.player.global_position) > 15.0, "(catch test) the unit has no immediate line of sight to the restore point")
	s2.queue_free()
