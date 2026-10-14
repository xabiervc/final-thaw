extends Node
## Runtime smoke test for the canonical G→H parking-entry variant.
## Run: godot --headless --path . res://tests/test_phase2_parking_entry.tscn

const ParkingScene = preload("res://scenes/prototypes/phase2_parking_chase.tscn")
const Handoff = preload("res://scripts/phase1/phase1_handoff.gd")
const NEAR_SENSE := 1.6
var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(30.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Parking entry test did not reach completion (possible script error or stuck scene).")
		get_tree().quit(1)


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var scene = ParkingScene.instantiate()
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame

	var actors_ready: bool = scene.player != null and scene.enemy != null
	_expect(actors_ready, "parking scene creates Elena and the recovery unit")
	if actors_ready:
		_expect(is_equal_approx(scene.player.global_position.x, 34.5), "canonical handoff starts at the parking-entry checkpoint, not the standalone corridor start")
		_expect(scene.player.global_position.x < 38.0, "player starts before the first parked vehicle and can read the space")
		_expect(scene.message.text.contains("Containment") and not scene.message.text.contains("Unidad de recuperación"), "the handoff does not announce the threat before the player can observe it")
		_expect(scene.parking_entry_mode and absf(scene.enemy.global_position.x - 43.0) < 0.2, "parking-specific patrol staging is enabled without changing the standalone prototype")
		_expect(scene.enemy_state == "patrol" and scene.enemy_target == 1, "recovery unit begins in its ordinary patrol state")
		_expect(scene.enemy.global_position.distance_to(scene.player.global_position) > NEAR_SENSE, "spawn does not trigger the proximity detector immediately")
		_expect(scene.enemy.global_position.x > scene.player.global_position.x, "the patrol begins ahead of Elena rather than behind the exit")
	scene.queue_free()
	await get_tree().process_frame
	await _test_handoff()

	completed = true
	print("Phase 2 parking entry: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


## Phase 1 -> Phase 2: the pursuit continues out of the same service mouth, with the mission state, exactly once.
func _test_handoff() -> void:
	Handoff.store({"from": "phase1", "mission": {"SERVICE_OVERRIDE": true, "AUDIT_SENT": true, "CONTAINMENT": true, "RESTRICTED_RECORD_READ": true},
		"velocity": Vector3(6.5, 0.0, 0.0), "facing": PI * 0.5, "unit_state": "chase", "unit_gap": 9.0, "stamina": 70.0})
	var scene = ParkingScene.instantiate()
	add_child(scene)
	await get_tree().physics_frame
	_expect(not Handoff.has_pending(), "the handoff is consumed once (a later standalone run will not inherit it)")
	_expect(bool(scene.mission_flags.get("CONTAINMENT", false)) and bool(scene.mission_flags.get("RESTRICTED_RECORD_READ", false)), "Phase 2 receives the Phase 1 mission flags")
	_expect(is_equal_approx(scene.player.global_position.x, 34.5), "Elena enters at the parking checkpoint, in front of the service mouth")
	_expect(scene.player.velocity.x > 5.0, "Elena keeps her running momentum through the handoff")
	_expect(not scene.enemy.visible and scene.unit_arrival_left > 0.0, "the unit is still behind, inside the gallery")
	var emerged := false
	for i in 300:
		await get_tree().physics_frame
		if scene.enemy.visible:
			emerged = true
			break
	_expect(emerged and scene.enemy.global_position.x < 33.0, "the unit comes out of the same service mouth")
	_expect(scene.enemy_state == "chase", "it comes out already hunting: the pursuit is continuous")
	scene.queue_free()
	await get_tree().process_frame
	var standalone = ParkingScene.instantiate()
	add_child(standalone)
	await get_tree().physics_frame
	_expect(standalone.handoff.is_empty() and standalone.enemy_state == "patrol", "without a handoff the parking scene keeps its standalone start")
	standalone.queue_free()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
