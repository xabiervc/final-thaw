extends Node
## Navigation check for the Phase 1 room complex: inside every room, with the dressing colliders in place, every doorway
## and stair mouth and the spawn point are mutually reachable on a 0.25 m grid with Elena's clearance, and every clue
## or control position has a reachable floor cell within interaction reach. Plan view only; it does not replace play.
## Run: godot --headless --path . res://tests/test_phase1_navigation.tscn

const Layout = preload("res://scripts/prototypes/phase1_layout.gd")
const Dressing = preload("res://scripts/prototypes/phase1_dressing.gd")
const Materials = preload("res://scripts/levels/test_room_art/facility_materials.gd")
const RESOLUTION := 0.25
const CLEARANCE := 0.4
const REACH := 1.6
var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(15.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Navigation tests did not reach completion (possible script error).")
		get_tree().quit(1)


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var dressing = Dressing.new()
	add_child(dressing)
	dressing.build(Materials.new())
	for id in Layout.ROOMS:
		_check_room(id, dressing.solids)
	completed = true
	print("Phase 1 navigation: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _check_room(id: String, solids: Array) -> void:
	var room: Dictionary = Layout.ROOMS[id]
	var rect: Rect2 = Layout.room_rect(room)
	var nx: int = int(rect.size.x / RESOLUTION)
	var nz: int = int(rect.size.y / RESOLUTION)
	var blocked: Array = []
	blocked.resize(nx * nz)
	blocked.fill(false)
	for footprint in solids:
		var grown: Rect2 = (footprint as Rect2).grow(CLEARANCE)
		if not rect.encloses(footprint as Rect2):
			continue
		for i in nx:
			for j in nz:
				var centre := Vector2(rect.position.x + (float(i) + 0.5) * RESOLUTION, rect.position.y + (float(j) + 0.5) * RESOLUTION)
				if grown.has_point(centre):
					blocked[i * nz + j] = true
	# Points that must be mutually reachable: spawn and every opening of the room, inset 0.6 m from its wall.
	var points: Array = []
	var spawn: Vector3 = room["spawn"]
	points.append([id + " spawn", Vector2(spawn.x, spawn.z)])
	var gaps: Dictionary = Layout.openings(id)
	for side in gaps:
		for gap in gaps[side]:
			var c: float = (float(gap[0]) + float(gap[1])) * 0.5
			var p := Vector2.ZERO
			if side == "north":
				p = Vector2(c, rect.position.y + 0.6)
			elif side == "south":
				p = Vector2(c, rect.end.y - 0.6)
			elif side == "west":
				p = Vector2(rect.position.x + 0.6, c)
			else:
				p = Vector2(rect.end.x - 0.6, c)
			points.append(["%s %s opening" % [id, side], p])
	var start := _cell(rect, points[0][1], nx, nz)
	_expect(not blocked[start.x * nz + start.y], "%s: the spawn point is on free floor" % id)
	var seen := _flood(blocked, start, nx, nz)
	for entry in points:
		var cell := _cell(rect, entry[1], nx, nz)
		_expect(seen.has(cell), "%s is reachable from the spawn point" % entry[0])
	for key in Layout.POSITIONS:
		var at: Vector3 = Layout.POSITIONS[key]["at"]
		if Layout.room_at(at) != id:
			continue
		var target := Vector2(at.x, at.z)
		var near := false
		for cell in seen:
			var centre := Vector2(rect.position.x + (float((cell as Vector2i).x) + 0.5) * RESOLUTION, rect.position.y + (float((cell as Vector2i).y) + 0.5) * RESOLUTION)
			if centre.distance_to(target) <= REACH:
				near = true
				break
		_expect(near, "position '%s' has reachable floor within %.1f m" % [key, REACH])


func _cell(rect: Rect2, point: Vector2, nx: int, nz: int) -> Vector2i:
	return Vector2i(clampi(int((point.x - rect.position.x) / RESOLUTION), 0, nx - 1), clampi(int((point.y - rect.position.y) / RESOLUTION), 0, nz - 1))


func _flood(blocked: Array, start: Vector2i, nx: int, nz: int) -> Dictionary:
	var seen := {}
	if blocked[start.x * nz + start.y]:
		return seen
	seen[start] = true
	var queue: Array = [start]
	var index := 0
	while index < queue.size():
		var current: Vector2i = queue[index]
		index += 1
		for step in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = current + (step as Vector2i)
			if next.x < 0 or next.y < 0 or next.x >= nx or next.y >= nz:
				continue
			if blocked[next.x * nz + next.y] or seen.has(next):
				continue
			seen[next] = true
			queue.append(next)
	return seen


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
