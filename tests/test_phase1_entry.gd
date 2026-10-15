extends Node
## The concealed entry and the closed ways out, walked with the real player body and real inputs (tests/support/route_bot.gd).
## Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_entry.tscn
##   1. Play starts in the flood channel; its walls, weir and silted end cannot be walked or climbed out of.
##   2. Standing, Elena cannot get into culvert C-2 (1.25 m headroom under the road grating); crouched, she can.
##   3. Through the culvert into the inspection tunnel, the culvert's last stretch collapses behind her: real collision,
##      fixed debris, the "entry_lost" note and the investigation objective.
##   4. The way back is physically blocked (she cannot walk or crouch back past the debris).
##   5. Before Containment the evacuation gallery's maglocked door blocks the only other way out; Containment's alarm
##      releases it and the same walk then gets through.

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const RouteBot := preload("res://tests/support/route_bot.gd")
const Building := preload("res://scripts/phase1/phase1_building.gd")

var passed := 0
var failed := 0
var scene: Node3D
var bot


func _ready() -> void:
	get_tree().create_timer(400.0).timeout.connect(func(): push_error("entry test watchdog"); get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _run() -> void:
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("play_intro", false)
	scene.set("entry_sequence", true)
	scene.set("spawn_unit_enabled", false)
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame
	scene.call("_begin_play")
	bot = RouteBot.new()
	add_child(bot)
	bot.player = scene.player
	bot.before_step = func(): scene.player.set("orbit_yaw", 0.0)
	var p: Vector3 = scene.player.global_position
	_expect(absf(p.y - Building.CHANNEL_FLOOR) < 0.3 and Building.CHANNEL.has_point(Vector2(p.x, p.z)), "play starts in the flood channel (%s)" % p)
	_expect(not bool(scene.get("entry_done")), "the culvert has not collapsed yet")
	await _channel_is_closed()
	await _culvert_needs_crouch()
	await _through_and_collapse()
	await _no_way_back()
	await _egress_door()
	bot.release_all()
	print("Phase 1 entry: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


## Walls 2.6 m high (the mantle reaches 1.85 m), a weir and a silted end: running and jumping at each never leaves.
func _channel_is_closed() -> void:
	var start: Vector3 = scene.player.global_position
	for target in [Vector3(-15.5, -1.0, 9.0), Vector3(-11.5, -1.0, -4.0), Vector3(-11.5, -1.0, 24.0), Vector3(-7.5, -1.0, 12.0)]:
		await bot.walk("channel wall test", [target], {"run": true, "timeout": 6.0})
		await bot.jump_towards("jump at the wall", target - scene.player.global_position, 0.8, true)
		await bot.wait(0.4)
		var q: Vector3 = scene.player.global_position
		_expect(q.y < Building.CHANNEL_FLOOR + 0.6 and Building.CHANNEL.grow(0.05).has_point(Vector2(q.x, q.z)),
			"the channel holds toward %s (at %s)" % [target, q])
	await bot.walk("back to the start", [start], {"timeout": 20.0})


func _culvert_needs_crouch() -> void:
	var mouth := Vector3(Building.CULVERT_X0 + 0.6, 0.0, 6.0)
	await bot.walk("up the rubble mound, standing", [Vector3(Building.CULVERT_X0 - 1.0, -0.6, 7.2), Vector3(Building.CULVERT_X0 - 0.4, 0.0, 6.0), mouth, Vector3(-7.0, 0.0, 6.0)], {"timeout": 10.0})
	var q: Vector3 = scene.player.global_position
	_expect(q.x < Building.CULVERT_X0 + 0.9, "standing, Elena cannot get under the culvert grating (stopped at x=%.2f)" % q.x)


func _through_and_collapse() -> void:
	var r: Dictionary = await bot.walk("crouch through culvert C-2", [Vector3(Building.CULVERT_X0 - 0.4, 0.0, 6.0), Vector3(-7.0, 0.0, 6.0), Vector3(-4.0, 0.0, 6.0), Vector3(-1.8, 0.0, 6.0)], {"crouch": true, "timeout": 30.0})
	_expect(bool(r["ok"]), "crouched, Elena gets through the culvert into the inspection tunnel %s" % ("" if r["ok"] else r.get("detail", "")))
	await bot.wait(1.5)
	_expect(bool(scene.get("entry_done")), "the culvert collapsed once she was through")
	var blocker: StaticBody3D = scene.get("building").entry_blocker
	_expect(not (blocker.get_child(0) as CollisionShape3D).disabled, "the collapse has real collision")
	_expect(scene.get("notes").has("entry_lost"), "the field notes record that the way in is gone")


func _no_way_back() -> void:
	await bot.walk("try to crouch back into the culvert", [Vector3(-2.6, 0.0, 6.0), Vector3(-6.0, 0.0, 6.0), Vector3(-9.0, 0.0, 6.0)], {"crouch": true, "timeout": 8.0})
	var q: Vector3 = scene.player.global_position
	_expect(q.x > Building.COLLAPSE_X.y - 0.1, "the debris blocks the way back (stopped at x=%.2f)" % q.x)
	await bot.walk("try again standing and running", [Vector3(-9.0, 0.0, 6.0)], {"run": true, "timeout": 4.0})
	await bot.jump_towards("jump at the debris", Vector3(-1.0, 0.0, 0.0), 0.8, true)
	await bot.wait(0.5)
	q = scene.player.global_position
	_expect(q.x > Building.COLLAPSE_X.y - 0.1, "no running, jumping or climbing over the debris (at x=%.2f)" % q.x)


func _egress_door() -> void:
	# Put Elena in the evacuation gallery (this part is about the door, the route there is walked by the playthrough).
	scene.player.global_position = Vector3(29.6, -2.0, 6.0)
	scene.player.velocity = Vector3.ZERO
	await bot.wait(0.3)
	await bot.walk("gallery east, before Containment", [Vector3(33.0, -2.0, 6.0)], {"run": true, "timeout": 6.0})
	var q: Vector3 = scene.player.global_position
	_expect(q.x < Building.EGRESS_DOOR_X - 0.1, "before Containment the maglocked door blocks the gallery (stopped at x=%.2f)" % q.x)
	_expect(not scene.call("_available", "egress") == false, "the door can be examined before Containment")
	scene.call("_begin_containment")
	await bot.wait(2.5)
	var r: Dictionary = await bot.walk("gallery east, after the alarm", [Vector3(33.0, -2.0, 6.0)], {"timeout": 10.0})
	_expect(bool(r["ok"]), "Containment's alarm released the door and the gallery is open %s" % ("" if r["ok"] else r.get("detail", "")))
