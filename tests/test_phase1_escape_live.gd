extends Node
## The escape with the recovery unit and STAFF-M1 live, played like a careful first-time player: retreat as soon
## as G opens, cross the pump room crouched behind the pump bank, take the lift, run from P0 to the east mouth.
## Fairness check: the escape must be completable, the run must be triggered by a real reacquisition, and the
## parking handoff must carry an active pursuit. Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_escape_live.tscn

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const RouteBot := preload("res://tests/support/route_bot.gd")
const Handoff := preload("res://scripts/phase1/phase1_handoff.gd")

var passed := 0
var failed := 0
var scene: Node3D
var bot
var handoff_seen: Dictionary = {}


func _ready() -> void:
	get_tree().create_timer(600.0).timeout.connect(func(): push_error("escape watchdog"); get_tree().quit(1))
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


func _run() -> void:
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("handoff_override", func(state): handoff_seen = state)
	add_child(scene)
	await get_tree().physics_frame
	bot = RouteBot.new()
	add_child(bot)
	bot.player = scene.player
	bot.before_step = func(): scene.player.set("orbit_yaw", 0.0)
	# Investigation state as a player would leave it: maintenance on, archive read, Elena inside G.
	scene.circuit.set_maintenance(true)
	scene.lift.set_powered(true)
	scene.mission.on_maintenance(false, true)
	scene.lift.call_to("upper")
	scene.call("_toggle_g_inner")  # she came in through the inner leaf
	scene.player.global_position = Vector3(1.0, 6.05, -7.4)
	await bot.wait(3.0)
	scene.call("_open_g_outer")
	var t0 := Time.get_ticks_msec()
	var ok: bool = await _walk("retreat through F/E", [Vector3(4.0, 6, -7.3), Vector3(6.0, 6, -6.4), Vector3(9.6, 6, -6.4), Vector3(12, 6, -6.0), Vector3(16, 6, -5.6)], {"min_y": 5.5})
	ok = ok and await _walk("walkway -> S2 down", [Vector3(15.5, 6, -4.0), Vector3(13.0, 5.7, -3.2), Vector3(8.3, 3.0, -3.2), Vector3(8.3, 3, -5.2)], {"min_y": 2.5})
	ok = ok and await _walk("pump room, crouched behind C1", [Vector3(12, 3, -5.3), Vector3(15.2, 3, -5.1), Vector3(21.8, 3, -5.1)], {"min_y": 2.5, "crouch": true})
	ok = ok and await _walk("to the lift", [Vector3(26, 3, -5.6)], {"min_y": 2.5})
	if ok:
		await bot.interact("lift call M")
		await bot.wait(0.6)
	ok = ok and await _walk("onto the deck", [Vector3(26, 3, -3.0)], {"min_y": 2.5})
	if ok:
		await bot.interact("lift send down")
		await bot.wait(3.6)
	ok = ok and await _walk("P0 -> R1 crank", [Vector3(26, 0, -0.9), Vector3(26.6, 0, -1.2), Vector3(29.0, 0, -1.0), Vector3(29.4, 0, 0.2)], {"min_y": -0.5, "run": true})
	if ok:
		await bot.interact("R1 emergency release")
		var waited := 0.0
		while scene.r1_opening < 1.15 and waited < 15.0 and scene.catches == 0:
			await bot.wait(0.2)
			waited += 0.2
	ok = ok and await _walk("crouch under the shutter", [Vector3(29, 0, 0.6), Vector3(29, 0, 1.8)], {"min_y": -0.5, "crouch": true})
	ok = ok and await _walk("east return (run)", [Vector3(29, 0, 2.7)], {"min_y": -0.5, "run": true})
	ok = ok and await _walk("bridge -> S1 (run)", [Vector3(29, 0.35, 6.0), Vector3(29, 0, 9.6), Vector3(28, 0, 12.4), Vector3(25, 0, 12.4), Vector3(25, 0, 11.6)], {"min_y": -0.5, "run": true})
	ok = ok and await _walk("S1 -> gallery -> mouth (run)", [Vector3(25, -1, 9.5), Vector3(25, -2, 7.2), Vector3(27, -2, 6.0), Vector3(29.5, -2, 6.0), Vector3(33.2, -2, 6.0), Vector3(36.0, -2, 6.0)], {"min_y": -2.5, "run": true})
	await bot.wait(0.3)
	bot.release_all()
	print("escape time %.1f s, catches %d, staff %s, unit %s, unit spotted %d" % [(Time.get_ticks_msec() - t0) / 1000.0, scene.catches, scene.staff.state, scene.unit.state if scene.unit != null else "-", scene.unit.times_spotted if scene.unit != null else 0])
	_expect(ok, "a careful first attempt completes the escape route")
	_expect(scene.catches == 0, "the careful route is fair: no catch (%d)" % scene.catches)
	_expect(scene.unit != null and scene.unit.has_reacquired, "the run was triggered by a real reacquisition, not a timer")
	_expect(not handoff_seen.is_empty(), "the parking handoff happens at the east mouth")
	if not handoff_seen.is_empty():
		_expect(str(handoff_seen["unit_state"]) in ["chase", "alert", "search", "investigate"], "the pursuit is still on at the handoff (%s)" % handoff_seen["unit_state"])
	Handoff.consume()
	print("Phase 1 escape live: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)
