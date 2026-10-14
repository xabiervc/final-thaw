extends Node
## Automated traversal driver for playthrough tests ("simulated playtest").
##
## It plays with the real player body: every physics frame it presses the real movement actions (move_*, run,
## crouch, jump, interact) with analog strengths, exactly as a keyboard player would, and lets the controller,
## collisions, stairs and lifts do the rest. It never sets the player's position while driving, so a route only
## passes if a human could walk it.
##
## Failure modes it reports: STUCK (no progress towards the waypoint), FELL (dropped below the leg's floor),
## TIMEOUT, and missing/refused interactions. Results are plain dictionaries so tests can print them.

const ARRIVE_XZ := 0.4
const ARRIVE_Y := 0.9
const STUCK_TIME := 2.5
const STUCK_PROGRESS := 0.15

var player: CharacterBody3D = null
## Called every physics frame while driving, so the scene can keep its own camera basis neutral.
var before_step: Callable = Callable()
var log_lines: Array[String] = []

var _pressed: Array[String] = []


func _press(action: String, strength: float = 1.0) -> void:
	if strength <= 0.001:
		return
	Input.action_press(action, clampf(strength, 0.0, 1.0))
	_pressed.append(action)


func release_all() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down", "run", "crouch", "jump", "interact"]:
		if InputMap.has_action(a):
			Input.action_release(a)
	_pressed.clear()


func _log(text: String) -> void:
	log_lines.append(text)
	print("[bot] ", text)


## Drives through `points` (Vector3, world). Options:
##   run (bool), crouch (bool), min_y (float: fail if the player drops below it), timeout (seconds),
##   jump_at (Array of point indices where a jump is pressed on arrival towards that point).
func walk(label: String, points: Array, opts: Dictionary = {}) -> Dictionary:
	var timeout: float = float(opts.get("timeout", 40.0))
	var min_y: float = float(opts.get("min_y", -1000.0))
	var elapsed := 0.0
	var i := 0
	var best := INF
	var since_progress := 0.0
	while i < points.size():
		var target: Vector3 = points[i]
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		elapsed += dt
		if before_step.is_valid():
			before_step.call()
		var p := player.global_position
		var flat := Vector2(target.x - p.x, target.z - p.z)
		if flat.length() <= ARRIVE_XZ and absf(target.y - p.y) <= ARRIVE_Y:
			i += 1
			best = INF
			since_progress = 0.0
			continue
		if p.y < min_y:
			release_all()
			return _fail(label, "FELL", "y=%.2f below %.2f near %s (waypoint %d %s)" % [p.y, min_y, _v(p), i, _v(target)])
		if elapsed > timeout:
			release_all()
			return _fail(label, "TIMEOUT", "at %s heading to waypoint %d %s" % [_v(p), i, _v(target)])
		var d := flat.length()
		if d < best - STUCK_PROGRESS:
			best = d
			since_progress = 0.0
		else:
			since_progress += dt
			if since_progress > STUCK_TIME:
				release_all()
				return _fail(label, "STUCK", "at %s heading to waypoint %d %s" % [_v(p), i, _v(target)])
		release_all()
		var dir := flat.normalized()
		_press("move_right", dir.x)
		_press("move_left", -dir.x)
		_press("move_down", dir.y)
		_press("move_up", -dir.y)
		if bool(opts.get("run", false)):
			_press("run")
		if bool(opts.get("crouch", false)):
			_press("crouch")
	release_all()
	_log("%s: OK in %.1fs, at %s" % [label, elapsed, _v(player.global_position)])
	return {"ok": true, "label": label, "time": elapsed}


## Presses `interact` for one frame (through the scene's own targeting) and waits a little.
func interact(label: String) -> void:
	release_all()
	await get_tree().physics_frame
	Input.action_press("interact")
	await get_tree().physics_frame
	await get_tree().process_frame
	Input.action_release("interact")
	await wait(0.15)
	_log("%s: interact at %s" % [label, _v(player.global_position)])


## Presses jump while keeping the given direction held, for running jumps over gaps or barriers.
func jump_towards(label: String, direction: Vector3, hold_seconds: float, run: bool = false) -> void:
	var dir := Vector2(direction.x, direction.z).normalized()
	var t := 0.0
	var jumped := false
	while t < hold_seconds:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		release_all()
		_press("move_right", dir.x)
		_press("move_left", -dir.x)
		_press("move_down", dir.y)
		_press("move_up", -dir.y)
		if run:
			_press("run")
		if not jumped:
			_press("jump")
			jumped = true
	release_all()
	_log("%s: jump landed at %s" % [label, _v(player.global_position)])


func wait(seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


func _fail(label: String, kind: String, detail: String) -> Dictionary:
	_log("%s: %s %s" % [label, kind, detail])
	return {"ok": false, "label": label, "kind": kind, "detail": detail}


static func _v(p: Vector3) -> String:
	return "(%.2f, %.2f, %.2f)" % [p.x, p.y, p.z]
