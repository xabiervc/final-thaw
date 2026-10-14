extends Node
## Dressing checks for the Phase 1 room complex: the dynamic parts exist and no collider added by the dressing blocks a
## staircase, a doorway or the landing in front of them. Geometry only, no play.
## Run: godot --headless --path . res://tests/test_phase1_dressing.tscn

const Layout = preload("res://scripts/prototypes/phase1_layout.gd")
const Dressing = preload("res://scripts/prototypes/phase1_dressing.gd")
const Materials = preload("res://scripts/levels/test_room_art/facility_materials.gd")
var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(10.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Dressing tests did not reach completion (possible script error).")
		get_tree().quit(1)


func _clear_zones() -> Array:
	var zones: Array = []
	for s in Layout.STAIRS:
		zones.append(Layout.stair_rect(s).grow(1.0))
	for d in Layout.DOORS:
		var at: float = float(d["at"])
		var c0: float = float(d["c0"])
		var c1: float = float(d["c1"])
		if d["axis"] == "x":
			zones.append(Rect2(at - 1.0, c0, 2.0, c1 - c0))
		else:
			zones.append(Rect2(c0, at - 1.0, c1 - c0, 2.0))
	return zones


func _inside_a_room(footprint: Rect2) -> bool:
	for id in Layout.ROOMS:
		if Layout.room_rect(Layout.ROOMS[id]).encloses(footprint):
			return true
	return false


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var dressing = Dressing.new()
	add_child(dressing)
	dressing.build(Materials.new())
	_expect(dressing.column_rings.size() == 5, "the Column has five light rings")
	_expect(dressing.indicators.has("archive") and dressing.indicators.has("trial") and dressing.indicators.has("protection"), "the catwalk has the three indicator strips")
	_expect(dressing.archive_screen != null, "the cabin has an archive screen")
	_expect(dressing.solids.size() > 0, "the dressing adds colliders in dead space")
	var zones := _clear_zones()
	var blocking: Array = []
	var outside: Array = []
	for footprint in dressing.solids:
		for zone in zones:
			if (footprint as Rect2).intersects(zone as Rect2):
				blocking.append(str(footprint))
		if not _inside_a_room(footprint as Rect2):
			outside.append(str(footprint))
	_expect(blocking.is_empty(), "no dressing collider blocks a stair, doorway or landing %s" % str(blocking))
	_expect(outside.is_empty(), "every dressing collider stands inside a room %s" % str(outside))
	var lights := 0
	for child in dressing.get_children():
		if child is OmniLight3D:
			lights += 1
	_expect(lights <= 6, "the dressing adds at most six lights (%d), to keep the Compatibility renderer cheap" % lights)
	completed = true
	print("Phase 1 dressing: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
