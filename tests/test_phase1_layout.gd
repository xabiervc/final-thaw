extends Node
## Layout checks for the Phase 1 room complex. Pure data, no physics or rendering.
## Run: godot --headless --path . res://tests/test_phase1_layout.tscn

const Layout = preload("res://scripts/prototypes/phase1_layout.gd")
var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(10.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Layout tests did not reach completion (possible script error).")
		get_tree().quit(1)


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var problems := Layout.problems()
	_expect(problems.is_empty(), "layout has no consistency problems %s" % str(problems))
	_expect(Layout.reachable_from("entry").size() == Layout.ROOMS.size(), "all %d rooms are reachable from the entry" % Layout.ROOMS.size())
	_expect(Layout.reachable_from("entry", "S4").has("cabin"), "the cabin is reachable without the locked shortcut")
	var levels := {}
	for id in Layout.ROOMS:
		levels[float(Layout.ROOMS[id]["y"])] = true
	_expect(levels.size() == 4, "the complex spans four levels (%s)" % str(levels.keys()))
	for s in Layout.STAIRS:
		_expect(Layout.stair_slope_deg(s) <= Layout.MAX_STAIR_SLOPE_DEG, "%s slope %.1f deg is walkable" % [s["id"], Layout.stair_slope_deg(s)])
		_expect(float(s["c1"]) - float(s["c0"]) >= Layout.MIN_OPENING, "%s is at least %.1f m wide" % [s["id"], Layout.MIN_OPENING])
	var shortcut: Dictionary = {}
	for s in Layout.STAIRS:
		if s["id"] == "S4":
			shortcut = s
	_expect(shortcut["from"] == "cabin" and shortcut["to"] == "entry" and float(shortcut["y0"]) == 3.0 and float(shortcut["y1"]) == 0.0, "the shortcut joins the cabin (+3 m) with the entry (0 m)")
	_expect(Layout.openings("cabin")["south"].size() == 1 and Layout.openings("entry")["north"].size() == 1, "the shortcut opens one gap in each room wall")
	_expect(Layout.openings("cabin")["east"].size() == 1 and Layout.skipped_sides("catwalk") == ["west"], "the cabin-catwalk wall is built once, by the cabin")
	_expect(Layout.skipped_sides("entry") == ["east"], "the entry-hall wall is built once, by the hall")
	for id in Layout.ROOMS:
		var spawn: Vector3 = Layout.ROOMS[id]["spawn"]
		_expect(Layout.room_at(spawn) == id, "the spawn point of %s lies inside that room" % id)
	for key in Layout.POSITIONS:
		_expect(Layout.room_at(Layout.POSITIONS[key]["at"]) != "", "position '%s' lies inside a room" % key)
	completed = true
	print("Phase 1 layout: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
