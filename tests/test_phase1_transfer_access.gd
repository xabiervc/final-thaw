extends Node
## "No bypass through collision gaps": a flood fill of the P-2 floor with Elena's real capsule against the built collision,
## from the foot of the stair. What she can reach must be exactly what the progression allows, in each state of the chain:
##   - the gallery, the battery room, the spares store and the dead workshop are open on foot with the lift dead;
##   - the substation is not reachable until its door is unlocked;
##   - the second building's vestibule is not reachable through the concealed panel, the door leaf or any wall until the
##     transfer door is open, and the bay behind the glass is not reachable until the bay door opens;
##   - no reachable cell has the void under it (the P-2 shell is closed: no gap in a wall leads outside).
## Also the stair itself (solid wedge, no space beneath it) and the P0 well rails.
## Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_transfer_access.tscn

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const Expansion := preload("res://scripts/phase1/phase1_expansion.gd")
const STEP := 0.25
const AREA := Rect2(12.0, 7.0, 30.0, 22.0)
const START := Vector2(15.4, 12.4)  # the stair's foot, in the gallery
const FLOOR_Y := -4.0

var passed := 0
var failed := 0
var completed := false
var scene: Node3D
var space: PhysicsDirectSpaceState3D


func _ready() -> void:
	get_tree().create_timer(120.0).timeout.connect(func():
		if not completed:
			push_error("transfer access test did not complete")
			get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _free(x: float, z: float, capsule: CapsuleShape3D) -> bool:
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = capsule
	q.transform = Transform3D(Basis.IDENTITY, Vector3(x, FLOOR_Y + 0.95, z))
	q.collision_mask = 1 | 16
	return space.intersect_shape(q, 1).is_empty()


func _has_floor(x: float, z: float) -> bool:
	var q := PhysicsRayQueryParameters3D.create(Vector3(x, FLOOR_Y + 0.5, z), Vector3(x, FLOOR_Y - 0.6, z), 1)
	return not space.intersect_ray(q).is_empty()


## Cells (as Vector2i) Elena can reach on foot from START, and the subset of them with no floor beneath.
func _flood() -> Dictionary:
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	var nx := int(AREA.size.x / STEP)
	var nz := int(AREA.size.y / STEP)
	var start := Vector2i(int((START.x - AREA.position.x) / STEP), int((START.y - AREA.position.y) / STEP))
	var seen := {}
	var queue: Array[Vector2i] = [start]
	seen[start] = true
	var void_cells := 0
	while not queue.is_empty():
		var c: Vector2i = queue.pop_back()
		var x := AREA.position.x + (float(c.x) + 0.5) * STEP
		var z := AREA.position.y + (float(c.y) + 0.5) * STEP
		if not _has_floor(x, z):
			void_cells += 1
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if n.x < 0 or n.y < 0 or n.x >= nx or n.y >= nz or seen.has(n):
				continue
			var nxp := AREA.position.x + (float(n.x) + 0.5) * STEP
			var nzp := AREA.position.y + (float(n.y) + 0.5) * STEP
			if _free(nxp, nzp, capsule):
				seen[n] = true
				queue.append(n)
	return {"cells": seen, "void": void_cells}


func _reach(cells: Dictionary, x: float, z: float) -> bool:
	return cells.has(Vector2i(int((x - AREA.position.x) / STEP), int((z - AREA.position.y) / STEP)))


func _inside_any(cells: Dictionary, rects: Array) -> int:
	var outside := 0
	for c in cells:
		var p := Vector2(AREA.position.x + (float(c.x) + 0.5) * STEP, AREA.position.y + (float(c.y) + 0.5) * STEP)
		var ok := false
		for r in rects:
			if (r as Rect2).grow(0.15).has_point(p):
				ok = true
				break
		if not ok:
			outside += 1
	return outside


func _settle() -> void:
	for i in 3:
		await get_tree().physics_frame


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("play_intro", false)
	scene.set("spawn_unit_enabled", false)
	add_child(scene)
	await _settle()
	space = scene.get_world_3d().direct_space_state
	var t = scene.transfer
	var base_rects := [Expansion.GALLERY, Expansion.BATTERY, Expansion.SPARES, Expansion.DEAD_WORKSHOP]
	# 1. The mission's start: everything that must be walkable without power is; nothing locked is.
	var r1 := _flood()
	var c1: Dictionary = r1["cells"]
	_expect(c1.size() > 400, "the flood fill from the stair's foot reaches a real area (%d cells)" % c1.size())
	_expect(_reach(c1, 27.0, 12.4) and _reach(c1, 17.0, 12.4), "the whole cable gallery is walkable on foot, with the lift dead")
	_expect(_reach(c1, 18.1, 10.4) and _reach(c1, 21.0, 10.5), "the battery room is walkable, past the racks to the auxiliary pump")
	_expect(_reach(c1, 17.0, 17.0) and _reach(c1, 17.0, 19.2), "the spares store is walkable, up to the dry cabinet")
	_expect(_reach(c1, 27.0, 16.5) and _reach(c1, 28.9, 17.2), "the dead workshop is walkable, up to the concealed panel")
	_expect(not _reach(c1, 22.0, 17.0) and not _reach(c1, 22.0, 14.5), "the locked substation is not reachable")
	_expect(not _reach(c1, 33.0, 17.2) and not _reach(c1, 31.0, 16.5), "the second building's vestibule is not reachable through the panel, the door or the walls")
	_expect(not _reach(c1, 33.0, 23.0) and not _reach(c1, 34.5, 24.5), "the bay behind the glass is not reachable")
	_expect(r1["void"] == 0, "no reachable cell has the void under it: the P-2 shell is closed (%d)" % r1["void"])
	_expect(_inside_any(c1, base_rects) == 0, "everything reachable lies inside the four open rooms")
	# 2. The anomaly discovered: the panel slides away but the door leaf still holds.
	t.interact("wall_seam")
	await _settle()
	var c2: Dictionary = _flood()["cells"]
	_expect(_reach(c2, 29.0, 17.2) and not _reach(c2, 33.0, 17.2), "with the panel gone the door leaf still blocks the way (discovery is not entry)")
	# 3. The substation's door unlocked: its inside opens, nothing else changes.
	t.call("_on_code", "0437")
	t.interact("drawer")
	t.interact("substation_door")
	await _settle()
	var c3: Dictionary = _flood()["cells"]
	_expect(_reach(c3, 22.0, 17.0) and _reach(c3, 21.5, 19.0) and _reach(c3, 23.4, 17.6), "the unlocked substation is walkable, up to the terminal and the disconnector")
	_expect(not _reach(c3, 33.0, 17.2), "unlocking the substation opens nothing else")
	# 4. The transfer door open: the vestibule is reachable, the bay is not.
	t.interact("terminal")
	t.interact("disconnector")
	t.interact("dry_cabinet")
	scene.circuit.set_isolated(true)
	scene.circuit.select_destination(preload("res://scripts/prototypes/phase1_circuit_model.gd").ARCHIVE)
	scene.call("_consult_archive")
	t.interact("transfer_door")
	await _settle()
	var r4 := _flood()
	var c4: Dictionary = r4["cells"]
	_expect(t.state.transfer_door_open and _reach(c4, 33.0, 17.2) and _reach(c4, 34.7, 18.9), "with the door open the vestibule is reachable, up to the window")
	_expect(not _reach(c4, 33.0, 23.0) and not _reach(c4, 35.0, 25.0) and not _reach(c4, 31.2, 21.5), "the bay behind the glass is still not reachable (window and door shut)")
	_expect(r4["void"] == 0, "the open door leaks nowhere: still no void under any reachable cell (%d)" % r4["void"])
	_expect(_inside_any(c4, base_rects + [Expansion.SUBSTATION, Expansion.VESTIBULE]) == 0, "everything reachable lies inside the intended rooms")
	# 5. The bay door opened (the staff come through): only then the bay joins.
	t.fx.open_bay_door(scene, true)
	await _settle()
	var r5 := _flood()
	var c5: Dictionary = r5["cells"]
	_expect(_reach(c5, 31.2, 21.5) and _reach(c5, 31.5, 24.0), "once the bay door opens the bay is reachable")
	_expect(r5["void"] == 0, "and the bay is closed too (no void under reachable cells: %d)" % r5["void"])
	# 6. The stair and the well: solid below, guarded above.
	var p := Vector3(11.2, -1.0, 12.4)
	var down := PhysicsRayQueryParameters3D.create(p, p + Vector3(0, -3.0, 0), 1)
	var hit := space.intersect_ray(down)
	_expect(not hit.is_empty() and absf((hit["position"] as Vector3).y - (-2.0)) < 0.1, "the stair is a walking surface at the right height (y=%.2f at x=11.2)" % (hit["position"].y if not hit.is_empty() else 99.0))
	# Nothing hollow under the stair: a capsule cannot stand on the floor beneath it.
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	_expect(not _free(11.2, 12.4, capsule), "there is no walkable space under the stair (solid wedge)")
	var rails := ["B2WellRailNorth", "B2WellRailEast"]
	var rails_ok := true
	for r in rails:
		var n := scene.get_node_or_null(r) as CollisionObject3D
		if n == null or n.collision_layer != 16 or not n.is_in_group("guard_rails"):
			rails_ok = false
	_expect(rails_ok, "the P0 well is guarded by rails on the no-mantle layer (stop bodies, never sight or the camera)")
	completed = true
	print("Phase 1 transfer access: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)
