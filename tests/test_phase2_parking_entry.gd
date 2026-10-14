extends Node
## Runtime smoke test for the canonical G→H parking-entry variant.
## Run: godot --headless --path . res://tests/test_phase2_parking_entry.tscn

const ParkingScene = preload("res://scenes/prototypes/phase2_parking_chase.tscn")
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
		_expect(scene.enemy_state == "patrol" and scene.enemy_target == 1, "recovery unit begins in its ordinary patrol state")
		_expect(scene.enemy.global_position.distance_to(scene.player.global_position) > NEAR_SENSE, "spawn does not trigger the proximity detector immediately")
		_expect(scene.enemy.global_position.x > scene.player.global_position.x, "the patrol begins ahead of Elena rather than behind the exit")
	scene.queue_free()

	completed = true
	print("Phase 2 parking entry: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
