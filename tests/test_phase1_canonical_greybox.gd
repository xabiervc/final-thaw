extends Node
## Smoke/integration tests for the canonical Phase 1 scene. Not a substitute for spatial/camera playtest.
## Run: godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn

const CanonicalScene = preload("res://scenes/prototypes/phase1_canonical_greybox.tscn")
var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(30.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Canonical Phase 1 test did not reach completion (possible script error or stuck scene).")
		get_tree().quit(1)


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var scene = CanonicalScene.instantiate()
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame

	_expect(scene.circuit != null, "canonical scene owns a circuit model")
	_expect(scene.lift != null and scene.player != null, "scene creates player and service lift")
	_expect(is_equal_approx(scene.lift.lower_y, 0.0) and is_equal_approx(scene.lift.upper_y, 1.5), "mission lift connects P0 to mezzanine M at +1.5 m")
	_expect(scene.get_node_or_null("MezzanineFloor_00") != null, "intermediate mezzanine floor is present")
	_expect(scene.get_node_or_null("D1RoomLabel") != null and scene.get_node_or_null("D2RoomLabel") != null and scene.get_node_or_null("D1PumpA") != null, "both D1 and D2 are built on the continuous maintenance level")
	_expect(scene.get_node_or_null("PitRailWest") != null and scene.get_node_or_null("PitRailEast") != null, "maintenance pit perimeter is protected")
	var pit_rail := scene.get_node("PitRailWest") as StaticBody3D
	_expect(is_equal_approx(pit_rail.position.y, 0.55), "pit guardrail rises above P0 floor instead of being buried below it")
	_expect(scene.get_node_or_null("NaveWorkshopPierSouth") != null and scene.get_node_or_null("RoofBeam_00") != null, "P0 has room boundaries and industrial roof structure")
	var workshop_bench := scene.get_node("WorkshopBench") as StaticBody3D
	_expect(workshop_bench.position.z < -7.5, "workshop bench stays clear of the doorway to the service nave")
	var service_route_mark := scene.get_node("SouthRouteMark") as Label3D
	_expect(service_route_mark.position.z < 1.0, "service route marking sits on the walkway, not over the open pit")
	_expect(scene.get_node_or_null("PumpSkidA") != null and scene.get_node_or_null("ControlStairsS2CollisionRamp") != null, "pump room and S2 stairs connect mezzanine to control")
	_expect(scene.get_node_or_null("WestShortcutStairsCollisionRamp") == null, "exterior airlock has no stair return to P0")
	_expect(not scene.circuit.maintenance_on and not scene.lift.powered, "maintenance and lift start unpowered")
	_expect(scene._service_lights.size() == 2 and scene._service_lights[0].light_energy < 0.2 and scene._service_lights[1].light_energy < 0.2, "service lights start at safe ambient minimum while maintenance is off")
	var lower_gate_shape := scene.get_node("LiftSafetyGateLower").get_child(0) as CollisionShape3D
	var lower_gate_mesh := scene.get_node("LiftSafetyGateLower").get_child(1) as MeshInstance3D
	var upper_gate_body := scene.get_node("LiftSafetyGateUpper") as StaticBody3D
	_expect(is_equal_approx(upper_gate_body.position.z, -4.49), "upper lift gate aligns with the mezzanine shaft edge")
	var upper_gate_shape := upper_gate_body.get_child(0) as CollisionShape3D
	var upper_gate_mesh := upper_gate_body.get_child(1) as MeshInstance3D
	_expect(lower_gate_shape.disabled and not lower_gate_mesh.visible, "lower landing gate is open only because the lift is docked there")
	_expect(not upper_gate_shape.disabled and upper_gate_mesh.visible, "upper landing gate protects the empty shaft")
	_expect(scene.circuit.destination == "ENSAYO" and not scene.circuit.trial_isolated and scene.circuit.protection_available, "circuit starts in the contract initial state")
	_expect(scene.get_node_or_null("SelectorBody") != null and scene.get_node_or_null("IsolatorBody") != null, "selector and isolator fixtures exist")
	_expect(scene.get_node_or_null("EStatusPanelBoard") != null and scene.get_node_or_null("ArchiveStatusBoard") != null, "E panel and local F indicator fixtures exist")
	_expect(scene.get_node_or_null("SchematicDiagram") != null, "pit schematic states the intended distribution")
	_expect(scene._status_panel_label.text.contains("ARCHIVO NO DISPONIBLE"), "E panel exposes live archive state before the circuit is solved")
	_expect(scene._archive_status_label.text.contains("NO"), "local F indicator shows unavailable supply initially")
	var scan_bridge_label := scene.get_node_or_null("ScanBridgeLabel") as Label3D
	_expect(scan_bridge_label != null and not scan_bridge_label.visible, "scanner trace markers start hidden")
	scene._start_scan_reveal()
	_expect(scan_bridge_label != null and scan_bridge_label.visible, "scanner reveals the bridge continuity marker")
	scene._update_scanner(3.1)
	_expect(scan_bridge_label != null and not scan_bridge_label.visible, "scanner hides trace markers when the reveal window expires")
	_expect(is_equal_approx(scene._scan_cooldown_left, 0.9), "scanner cooldown lasts four seconds from activation")
	scene._consult_archive()
	_expect(not scene._archive_consulted, "archive cannot be consulted before stable supply")
	_expect(not scene._archive_consulted and not scene._audit_events.has("RESTRICTED_RECORD_READ"), "a denied consultation does not grant knowledge or queue a record-read audit")

	# Unsafe order trips protection and rejected rearm is non-destructive.
	scene._toggle_selector()
	_expect(not scene.circuit.protection_available and scene.circuit.last_trip == "DEMANDA_SIMULTANEA", "ARCHIVO with connected trial trips protection")
	var before_rejected_rearm: Dictionary = scene.circuit.snapshot()
	scene._request_rearm()
	_expect(not scene.circuit.protection_available, "rearm is rejected while the fault remains")
	_expect(scene.circuit.snapshot() == before_rejected_rearm, "rejected rearm preserves state and last_trip")

	# Correct the fault, then rearm. The trip history remains.
	scene._toggle_isolator()
	scene._request_rearm()
	_expect(scene.circuit.protection_available and bool(scene.circuit.outputs()["archive"]), "isolation and rearm restore stable archive supply")
	_expect(scene._status_panel_label.text.contains("ARCHIVO ESTABLE"), "E panel updates to stable archive state")
	_expect(scene._archive_status_label.text.contains("ESTABLE"), "local F indicator updates after supply is restored")
	_expect(scene.circuit.last_trip == "DEMANDA_SIMULTANEA", "successful rearm preserves last_trip")
	scene._consult_archive()
	_expect(scene._archive_consulted, "archive consultation is recorded in the current session")
	_expect(scene.circuit.known_clues().size() == 1, "consultation grants session knowledge without save migration")
	_expect(scene._audit_events.has("RESTRICTED_RECORD_READ"), "archive reading queues its optional audit event")

	# Maintenance and platform power are wired independently of the recovery circuit.
	scene._toggle_maintenance()
	_expect(scene.circuit.maintenance_on and scene.lift.powered, "maintenance enables the service lift")
	_expect(scene._service_lights[0].light_energy > 0.7 and scene._service_lights[1].light_energy > 0.7, "maintenance turns on the service lights")
	_expect(scene.circuit.outputs()["diagnostic"], "diagnostics remain available with maintenance on")
	_expect(scene._audit_events.has("SERVICE_OVERRIDE"), "maintenance queues SERVICE_OVERRIDE")
	scene._call_lift("upper")
	await get_tree().physics_frame
	_expect(not lower_gate_shape.disabled and not upper_gate_shape.disabled and lower_gate_mesh.visible and upper_gate_mesh.visible, "both fixed shaft gates close during travel")
	scene.lift.step(3.0)
	await get_tree().physics_frame
	_expect(not lower_gate_shape.disabled and upper_gate_shape.disabled and lower_gate_mesh.visible and not upper_gate_mesh.visible, "upper landing gate opens only when the deck docks upper")

	# The F→G door and exterior hatch are controllable from their intended sides.
	scene.player.global_position = Vector3(4.0, 3.2, -7.5)
	scene._unlock_shortcut()
	_expect(scene._shortcut_unlocked, "inner shortcut unlocks from the cabin side")
	scene.player.global_position = Vector3(2.0, 3.2, -7.5)
	scene._open_outer_hatch()
	_expect(scene._outer_hatch_open, "outer hatch opens from the west vestibule")

	completed = true
	print("Canonical Phase 1 integration: %d passed, %d failed; COMPLETED" % [passed, failed])
	scene.queue_free()
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
