extends Node

## Automated acceptance checks for the Phase 2 threat agent components.
## These tests validate component logic with synthetic targets and geometry.
## They do not validate Godot rendering, camera readability, navigation quality
## or the final Phase 2 level.

const ThreatPerception = preload("res://scripts/entities/threat/threat_perception_component.gd")
const ThreatStateMachine = preload("res://scripts/entities/threat/threat_state_machine.gd")
const ThreatCapture = preload("res://scripts/entities/threat/threat_capture_component.gd")

var failures: Array[String] = []

func _ready() -> void:
	await get_tree().process_frame
	_test_perception_visibility()
	_test_perception_occlusion()
	_test_perception_proximity()
	_test_noise_updates_last_known_position()
	_test_state_machine_chase_uses_last_known_position()
	_test_capture_emits_once_and_cooldowns()
	_report()

func _test_perception_visibility() -> void:
	var root := Node3D.new()
	add_child(root)

	var perception := ThreatPerception.new()
	root.add_child(perception)

	var target := Node3D.new()
	root.add_child(target)

	perception.set_target(target)
	target.global_position = Vector3(0.0, 0.0, -5.0)

	await get_tree().physics_frame
	_check(perception.can_see_target(), "Target in front and within range is visible.")

	target.global_position = Vector3(0.0, 0.0, 5.0)
	await get_tree().physics_frame
	_check(not perception.can_see_target(), "Target behind the threat is not visible.")

	root.queue_free()

func _test_perception_occlusion() -> void:
	var root := Node3D.new()
	add_child(root)

	var perception := ThreatPerception.new()
	root.add_child(perception)

	var target := Node3D.new()
	root.add_child(target)

	var wall := StaticBody3D.new()
	var wall_shape := CollisionShape3D.new()
	var wall_box := BoxShape3D.new()
	wall_box.size = Vector3(4.0, 4.0, 0.5)
	wall_shape.shape = wall_box
	wall.add_child(wall_shape)
	root.add_child(wall)

	perception.set_target(target)
	wall.global_position = Vector3(0.0, 0.0, -2.5)
	target.global_position = Vector3(0.0, 0.0, -5.0)

	await get_tree().physics_frame
	_check(not perception.can_see_target(), "Wall blocks line of sight.")

	root.queue_free()

func _test_perception_proximity() -> void:
	var root := Node3D.new()
	add_child(root)

	var perception := ThreatPerception.new()
	root.add_child(perception)

	var target := Node3D.new()
	root.add_child(target)

	perception.set_target(target)
	target.global_position = Vector3(0.0, 0.0, 1.0)

	await get_tree().physics_frame
	_check(perception.can_see_target(), "Very close target is sensed regardless of facing.")

	root.queue_free()

func _test_noise_updates_last_known_position() -> void:
	var root := Node3D.new()
	add_child(root)

	var perception := ThreatPerception.new()
	root.add_child(perception)

	var noise_position := Vector3(3.0, 0.0, -4.0)
	perception.report_noise(noise_position, 10.0)

	_check(perception.has_known_position(), "Heard noise stores a last known position.")
	_check(perception.get_last_known_position().is_equal_approx(noise_position), "Last known position matches the noise position.")

	root.queue_free()

func _test_state_machine_chase_uses_last_known_position() -> void:
	var root := Node3D.new()
	add_child(root)

	var perception := ThreatPerception.new()
	root.add_child(perception)

	var machine := ThreatStateMachine.new()
	root.add_child(machine)

	var target := Node3D.new()
	root.add_child(target)

	perception.set_target(target)
	machine.perception = perception

	target.global_position = Vector3(0.0, 0.0, -5.0)
	await get_tree().physics_frame

	var last_known := perception.get_last_known_position()
	target.global_position = Vector3(20.0, 0.0, 20.0)

	await get_tree().physics_frame
	_check(machine.current_destination.is_equal_approx(last_known), "Chase destination remains the last known position after losing sight.")

	root.queue_free()

func _test_capture_emits_once_and_cooldowns() -> void:
	var root := Node3D.new()
	add_child(root)

	var capture := ThreatCapture.new()
	root.add_child(capture)

	var target := Node3D.new()
	root.add_child(target)

	capture.set_target(target)
	target.global_position = Vector3.ZERO

	var catch_count := 0
	capture.target_caught.connect(func(_target: Node3D) -> void:
		catch_count += 1
	)

	await get_tree().physics_frame
	_check(catch_count == 1, "Capture emits exactly once on contact.")

	await get_tree().physics_frame
	_check(catch_count == 1, "Capture cooldown prevents repeated emission.")

	root.queue_free()

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: " + message)
	else:
		failures.append(message)
		print("FAIL: " + message)

func _report() -> void:
	if failures.is_empty():
		print("THREAT AGENT TESTS: ALL PASS")
		get_tree().quit(0)
	else:
		print("THREAT AGENT TESTS: %d FAILURE(S)" % failures.size())
		get_tree().quit(1)
