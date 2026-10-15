extends Node
## Elena's movement verbs on the shared controller, in a small arena (independent of any level):
## walk/run speeds, run drains and walking recovers stamina, crouch lowers the capsule and refuses to stand under a
## low ceiling, the ledge mantle climbs a crate but never a 2 m wall, a guard rail or through a rail, and jump
## keeps working (coyote time). Run: godot --headless --fixed-fps 60 --path . res://tests/test_elena_movement.tscn

const Controller := preload("res://scripts/characters/elena_controller.gd")
const RouteBot := preload("res://tests/support/route_bot.gd")

var passed := 0
var failed := 0
var elena: CharacterBody3D
var bot


func _ready() -> void:
	get_tree().create_timer(300.0).timeout.connect(func(): push_error("movement watchdog"); get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _box(size: Vector3, center: Vector3, layer: int = 1) -> void:
	var b := StaticBody3D.new()
	b.collision_layer = layer
	b.position = center
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	b.add_child(cs)
	add_child(b)


func _arena() -> void:
	_box(Vector3(60, 0.5, 60), Vector3(0, -0.25, 0))           # floor
	_box(Vector3(1.2, 0.8, 1.2), Vector3(0, 0.4, -4))           # crate 0.8 m (mantle-able)
	_box(Vector3(4, 2.2, 0.4), Vector3(6, 1.1, -4))             # wall 2.2 m (too high)
	_box(Vector3(4, 1.1, 0.1), Vector3(12, 0.55, -4), 16)       # guard rail (layer 5)
	_box(Vector3(1.0, 1.1, 1.0), Vector3(18, 0.55, -4))         # block with a rail along its far edge
	_box(Vector3(1.0, 1.1, 0.1), Vector3(18, 1.65, -4.5), 16)
	_box(Vector3(3, 0.2, 3), Vector3(-8, 1.4, 0))               # low ceiling slab (bottom at 1.3 m)


func _run() -> void:
	_arena()
	elena = Controller.new()
	elena.use_mpfb_model = false
	add_child(elena)
	elena.global_position = Vector3(0, 0.05, 6)
	await get_tree().physics_frame
	bot = RouteBot.new()
	add_child(bot)
	bot.player = elena

	# Speeds.
	await bot.walk("walk", [Vector3(0, 0, 0)], {})
	var walk_speed := await _speed_towards(Vector3(0, 0, 20), false)
	var run_speed := await _speed_towards(Vector3(0, 0, -15), true)
	_expect(walk_speed > 3.9 and walk_speed < 4.6, "default pace is about 4.2 m/s (%.2f)" % walk_speed)
	_expect(run_speed > walk_speed * 1.5, "running (Shift) is clearly faster (%.2f vs %.2f)" % [run_speed, walk_speed])

	# Stamina: running drains it, walking recovers it.
	elena.condition.stamina = 100.0
	await bot.walk("run drain", [Vector3(0, 0, 25), Vector3(0, 0, 0)], {"run": true})
	var after_run: float = elena.condition.stamina
	_expect(after_run < 80.0, "running drains stamina (%.0f)" % after_run)
	await bot.walk("walk recover", [Vector3(0, 0, 10), Vector3(0, 0, 0)], {})
	await bot.wait(3.0)
	_expect(elena.condition.stamina > after_run + 10.0, "walking and standing recover stamina (%.0f)" % elena.condition.stamina)

	# Crouch: capsule and ceiling.
	elena.global_position = Vector3(-8, 0.05, 4)
	await bot.wait(0.3)
	var stood: Dictionary = await bot.walk("standing into the low gap", [Vector3(-8, 0, -4)], {"timeout": 4.0})
	_expect(not bool(stood["ok"]), "standing, Elena cannot pass under a 1.3 m ceiling")
	elena.global_position = Vector3(-8, 0.05, 4)
	await bot.wait(0.3)
	var crouched: Dictionary = await bot.walk("crouched under the low gap", [Vector3(-8, 0, 0)], {"crouch": true, "timeout": 6.0})
	_expect(bool(crouched["ok"]) and elena.is_crouching, "crouched (Ctrl/C), Elena passes under it")
	bot.release_all()
	await bot.wait(0.5)
	_expect(elena.is_crouching, "she refuses to stand up while the ceiling is above her")
	await bot.walk("crawl out", [Vector3(-8, 0, -4)], {"crouch": true, "timeout": 6.0})
	bot.release_all()
	await bot.wait(0.4)
	_expect(not elena.is_crouching, "she stands up once there is room")

	# Mantle.
	_expect(await _mantle_from(Vector3(0, 0.05, -2.6), Vector3(0, 0, -1)), "jumping at a 0.8 m crate mantles onto it")
	_expect(elena.global_position.y > 0.7, "she stands on the crate (y=%.2f)" % elena.global_position.y)
	_expect(not await _mantle_from(Vector3(6, 0.05, -3.3), Vector3(0, 0, -1)), "a 2.2 m wall is never mantled")
	_expect(not await _mantle_from(Vector3(12, 0.05, -3.4), Vector3(0, 0, -1)), "a guard rail is never mantled")
	_expect(not await _mantle_from(Vector3(18, 0.05, -2.9), Vector3(0, 0, -1)) or elena.global_position.z > -4.45, "a mantle never carries Elena through a rail")

	# Turning keeps momentum; a reversal brakes quickly (no sliding through zero for a second).
	elena.global_position = Vector3(-20, 0.05, 20)
	await bot.wait(0.3)
	await _speed_towards(Vector3(-20, 0, -20), false)
	var turn := await _hold_dir(Vector2(1, 0), 0.25)
	_expect(turn["speed"] > 3.0 and turn["dir"].dot(Vector3(1, 0, 0)) > 0.9, "a 90-degree turn at pace keeps its speed (%.2f m/s) and points the new way within 0.25 s" % turn["speed"])
	await _hold_dir(Vector2(0, -1), 1.0)
	var reverse := await _time_to_reverse()
	_expect(reverse < 0.45, "a full reversal at pace brakes and turns back in %.2f s" % reverse)
	# Fatigue costs sprinting, not walking.
	elena.condition.stamina = 0.0
	var tired_speed := await _speed_towards(elena.global_position + Vector3(0, 0, -12), false)
	_expect(tired_speed >= 0.85 * 4.2 - 0.05, "with no stamina left Elena still walks at >= 85 %% pace (%.2f)" % tired_speed)
	elena.condition.stamina = 100.0
	# Jump.
	elena.global_position = Vector3(25, 0.05, 0)
	await bot.wait(0.3)
	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")
	var peak := 0.0
	for i in 40:
		await get_tree().physics_frame
		peak = maxf(peak, elena.global_position.y)
	_expect(peak > 0.45 and peak < 0.8, "a standing jump peaks around 0.6 m (%.2f)" % peak)
	bot.release_all()
	print("Elena movement: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


## Holds a stick direction (world x/z) for `seconds`; returns final horizontal speed and direction.
func _hold_dir(stick: Vector2, seconds: float) -> Dictionary:
	var t := 0.0
	while t < seconds:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		bot.release_all()
		Input.action_press("move_right", maxf(0, stick.x))
		Input.action_press("move_left", maxf(0, -stick.x))
		Input.action_press("move_down", maxf(0, stick.y))
		Input.action_press("move_up", maxf(0, -stick.y))
	bot.release_all()
	var v := Vector3(elena.velocity.x, 0, elena.velocity.z)
	return {"speed": v.length(), "dir": v.normalized()}


## From moving -z at pace, pushes +z and measures how long until the velocity points +z.
func _time_to_reverse() -> float:
	var t := 0.0
	while t < 2.0:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		bot.release_all()
		Input.action_press("move_down", 1.0)
		if elena.velocity.z > 0.5:
			break
	bot.release_all()
	return t


func _speed_towards(target: Vector3, run: bool) -> float:
	var start := elena.global_position
	var t0 := 0.0
	var dir := (target - start)
	dir.y = 0
	dir = dir.normalized()
	var top := 0.0
	while t0 < 1.6:
		await get_tree().physics_frame
		t0 += get_physics_process_delta_time()
		bot.release_all()
		Input.action_press("move_right", maxf(0, dir.x))
		Input.action_press("move_left", maxf(0, -dir.x))
		Input.action_press("move_down", maxf(0, dir.z))
		Input.action_press("move_up", maxf(0, -dir.z))
		if run:
			Input.action_press("run")
		top = maxf(top, Vector2(elena.velocity.x, elena.velocity.z).length())
	bot.release_all()
	return top


## Places Elena, walks her at the obstacle and presses jump; true if a mantle started.
func _mantle_from(start: Vector3, dir: Vector3) -> bool:
	elena.global_position = start
	elena.velocity = Vector3.ZERO
	await bot.wait(0.3)
	var seen := {"mantled": false}  # lambdas capture locals by value: share a dictionary instead
	var cb := func(_h): seen["mantled"] = true
	elena.mantled.connect(cb)
	for i in 30:
		await get_tree().physics_frame
		bot.release_all()
		Input.action_press("move_up", maxf(0, -dir.z))
		Input.action_press("move_down", maxf(0, dir.z))
		if i == 12:
			Input.action_press("jump")
	bot.release_all()
	await bot.wait(0.8)
	elena.mantled.disconnect(cb)
	return bool(seen["mantled"])
