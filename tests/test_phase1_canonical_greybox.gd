extends Node
## Structural and contract checks for the canonical Phase 1 scene (geometry v3.0, FASE1_GREYBOX_SPEC.md).
## Walkability is proven by test_phase1_playthrough / test_phase1_edges; this test checks what must be true of the
## built level and of the mission contracts before anyone walks it.
## Run: godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn

const CanonicalScene = preload("res://scenes/prototypes/phase1_canonical_greybox.tscn")
const Building = preload("res://scripts/phase1/phase1_building.gd")
const CLEARANCE_MIN := 2.2

var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(60.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Canonical Phase 1 test did not reach completion (possible script error or stuck scene).")
		get_tree().quit(1)


func _top(scene: Node, name: String) -> float:
	var b := scene.get_node(name) as StaticBody3D
	var box := (b.get_child(0) as CollisionShape3D).shape as BoxShape3D
	return b.position.y + box.size.y * 0.5


func _bottom(scene: Node, name: String) -> float:
	var b := scene.get_node(name) as StaticBody3D
	var box := (b.get_child(0) as CollisionShape3D).shape as BoxShape3D
	return b.position.y - box.size.y * 0.5


## True when a downward ray at (x, z) from `from_y` hits something within `depth`.
func _solid_below(scene: Node3D, x: float, z: float, from_y: float, depth: float) -> bool:
	var q := PhysicsRayQueryParameters3D.create(Vector3(x, from_y, z), Vector3(x, from_y - depth, z), 1 | 16)
	return not scene.get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var scene = CanonicalScene.instantiate()
	scene.set("handoff_override", func(_s): pass)
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame

	# Datums and headroom (the v3.0 decision).
	_expect(is_equal_approx(_top(scene, "PitFloor"), -2.0), "P-1 floor top at -2 m")
	_expect(is_equal_approx(_top(scene, "AccessTunnelFloor"), 0.0), "P0 / entry tunnel floor at 0 m")
	_expect(is_equal_approx(_top(scene, "MezzanineFloor"), 3.0), "M floor at +3 m")
	_expect(is_equal_approx(_top(scene, "ControlRoomFloor"), 6.0) and is_equal_approx(_top(scene, "ObservationWalkway"), 6.0), "P2 floors at +6 m")
	_expect(_bottom(scene, "MezzanineFloor") - 0.0 >= CLEARANCE_MIN, "nave/workshop under M keep >= 2.2 m clear (%.2f)" % _bottom(scene, "MezzanineFloor"))
	_expect(_bottom(scene, "ControlRoomFloor") - 3.0 >= CLEARANCE_MIN, "the pump room under E keeps >= 2.2 m clear")
	_expect(_bottom(scene, "EvacGalleryRoof") - (-2.0) >= CLEARANCE_MIN, "the evacuation gallery keeps >= 2.2 m clear")
	_expect(_bottom(scene, "EastReturnBridgeDeck") - (-2.0) >= CLEARANCE_MIN, "the gallery under the east-return bridge keeps >= 2.2 m clear")
	_expect(_top(scene, "AccessTunnelCeiling") - 0.25 >= CLEARANCE_MIN, "the entry tunnel keeps >= 2.2 m clear")

	# Real voids and real floors.
	_expect(not _solid_below(scene, 15.0, 4.0, 0.5, 1.0) and not _solid_below(scene, 22.0, 4.0, 0.5, 1.0), "P0 has real voids above D1 and D2")
	_expect(_solid_below(scene, 15.0, 4.0, -1.5, 1.0), "D1/D2 have a continuous floor at -2")
	_expect(_solid_below(scene, 25.0, 12.6, 0.5, 0.7), "the S1 top landing is solid floor")
	_expect(_solid_below(scene, 31.0, 6.0, -1.5, 1.0) and _solid_below(scene, 38.0, 6.0, -1.5, 1.0), "the evacuation gallery and the exterior apron have floors at -2")
	_expect(scene.get_node_or_null("S1Stair") != null and scene.get_node_or_null("S2Stair") != null, "S1 and S2 are solid stairs")
	_expect(scene.get_node_or_null("EastReturnBridgeDeck") != null, "the east return bridges the gallery (no jump, no hole)")

	# Protections.
	var rails := get_tree().get_nodes_in_group("guard_rails")
	_expect(rails.size() >= 20, "exposed edges carry guard rails (%d; each edge is walked into by test_phase1_edges)" % rails.size())
	var rails_ok := true
	for r in rails:
		if (r as CollisionObject3D).collision_layer != 16:
			rails_ok = false
	_expect(rails_ok, "rails are on layer 5 only: they stop bodies but not sight lines or the camera")
	_expect(scene.get_node_or_null("LiftSafetyGateLower") != null and scene.get_node_or_null("LiftSafetyGateUpper") != null and scene.get_node_or_null("LiftPitFloor") != null, "the lift shaft has landing gates and a shallow pit")
	_expect(scene.get_node_or_null("BrokenStairRubble") != null and scene.get_node_or_null("BrokenApproachStairVisual") != null, "the direct P0-P2 stair is visibly collapsed and blocked")

	# Vertical circulation contracts.
	_expect(is_equal_approx(scene.lift.lower_y, 0.0) and is_equal_approx(scene.lift.upper_y, 3.0), "the lift links P0 and M only")
	_expect(not scene.lift.powered, "the lift starts unpowered (maintenance OFF)")

	# Spawn and actors.
	_expect(scene.player.global_position.x < 0.0 and absf(scene.player.global_position.z - 6.0) < 0.01, "Elena starts inside the west entry tunnel")
	_expect(scene.unit == null, "no recovery unit exists before Containment")
	_expect(scene.staff != null and scene.staff.global_position.y > 2.5, "STAFF-M1 works in the pump room M")

	# Mission and circuit contracts.
	_expect(not scene.mission.service_override_queued and not scene.mission.containment_active, "mission flags start clear")
	var info: Dictionary = scene.circuit.inspect()
	_expect(str(info["current"]) == "ARCHIVE_UNPOWERED" and str(info["destination"]) == "ENSAYO" and not scene.circuit.trial_isolated, "circuit initial state follows the logic contract")
	scene.call("_open_g_outer")
	_expect(not scene.mission.containment_active and scene.phase == "investigation", "G without a queued audit answers 'locked' and starts nothing")
	scene.call("_toggle_maintenance")
	_expect(scene.mission.service_override_queued and scene.lift.powered, "maintenance ON powers the lift and queues SERVICE_OVERRIDE")
	scene.call("_toggle_maintenance")
	_expect(scene.mission.service_override_queued and not scene.lift.powered, "maintenance OFF keeps the queued audit (no duplicate, no loss)")
	_expect(scene.circuit.outputs()["archive"] == false, "maintenance never powers the archive (independent branch)")

	# Texts never give the answer.
	var forbidden := ["aísla", "aisla", "selecciona", "rearma la", "pulsa el"]
	var clean := true
	for hint in scene.HINTS:
		for word in forbidden:
			if str(hint).to_lower().contains(word):
				clean = false
	_expect(clean, "requested hints explain relationships and never name the control to operate")
	_expect(str(scene.ARCHIVE_RECORD).begins_with("ENSAYO ASTER — RESULTADO RETENIDO."), "the archive record uses the N1-03 working copy")

	scene.queue_free()
	completed = true
	print("Canonical Phase 1: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
