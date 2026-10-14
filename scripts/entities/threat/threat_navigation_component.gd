class_name ThreatNavigationComponent
extends Node

## Reusable movement component for the Phase 2 threat agent.
## Consumes movement intents from ThreatStateMachine and moves the owning
## CharacterBody3D using steering probes. It does not use a navigation mesh.

signal arrived_at_destination
signal movement_blocked

@export var body_path: NodePath = ".."
@export var arrival_distance: float = 0.9
@export var steering_probe_distance: float = 1.2
@export var steering_probe_count: int = 5
@export var steering_probe_spread_degrees: float = 65.0
@export var turn_speed: float = 8.0
@export var gravity: float = 18.0
@export var collision_mask: int = 1

var body: CharacterBody3D
var destination: Vector3
var move_speed: float = 0.0
var has_destination: bool = false
var _state_machine: ThreatStateMachine
var _probe: RayCast3D

func _ready() -> void:
	body = get_node_or_null(body_path) as CharacterBody3D

	if body == null:
		push_warning("ThreatNavigationComponent requires a CharacterBody3D owner or body_path.")
		return

	_state_machine = get_node_or_null("../ThreatStateMachine") as ThreatStateMachine

	if _state_machine == null:
		push_warning("ThreatNavigationComponent requires a sibling ThreatStateMachine named ThreatStateMachine.")
		return

	_state_machine.movement_intent_changed.connect(_on_movement_intent_changed)

	_probe = RayCast3D.new()
	_probe.enabled = false
	_probe.collide_with_areas = false
	_probe.collide_with_bodies = true
	_probe.collision_mask = collision_mask
	body.add_child(_probe)

func _physics_process(delta: float) -> void:
	if body == null or not has_destination:
		return

	var to_destination := destination - body.global_position
	to_destination.y = 0.0

	if to_destination.length() <= arrival_distance:
		body.velocity.x = 0.0
		body.velocity.z = 0.0
		has_destination = false
		arrived_at_destination.emit()
		return

	var desired_direction := to_destination.normalized()
	var steering_direction := _get_avoidance_direction(desired_direction)

	if steering_direction == Vector3.ZERO:
		body.velocity.x = 0.0
		body.velocity.z = 0.0
		movement_blocked.emit()
		return

	var target_yaw := atan2(steering_direction.x, steering_direction.z)
	body.rotation.y = lerp_angle(body.rotation.y, target_yaw, turn_speed * delta)

	var horizontal_velocity := steering_direction * move_speed
	body.velocity.x = horizontal_velocity.x
	body.velocity.z = horizontal_velocity.z

	if not body.is_on_floor():
		body.velocity.y -= gravity * delta

	body.move_and_slide()

func _get_avoidance_direction(desired_direction: Vector3) -> Vector3:
	if _is_direction_clear(desired_direction):
		return desired_direction

	var best_direction := Vector3.ZERO
	var best_score := -1.0
	var half_spread := deg_to_rad(steering_probe_spread_degrees) * 0.5

	for index in range(steering_probe_count):
		var offset := 0.0

		if steering_probe_count > 1:
			offset = -half_spread + (2.0 * half_spread * float(index) / float(steering_probe_count - 1))

		var candidate := desired_direction.rotated(Vector3.UP, offset)

		if not _is_direction_clear(candidate):
			continue

		var alignment := desired_direction.dot(candidate)

		if alignment > best_score:
			best_score = alignment
			best_direction = candidate

	return best_direction

func _is_direction_clear(direction: Vector3) -> bool:
	if _probe == null:
		return false

	var origin := body.global_position
	var target := origin + direction * steering_probe_distance

	_probe.global_position = origin
	_probe.target_position = _probe.to_local(target)
	_probe.force_raycast_update()

	return not _probe.is_colliding()

func _on_movement_intent_changed(new_destination: Vector3, new_speed: float) -> void:
	destination = new_destination
	move_speed = new_speed
	has_destination = true
