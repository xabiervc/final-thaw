class_name ThreatPerceptionComponent
extends Node3D

## Reusable perception component for the Phase 2 threat agent.
## It detects a target through vision, proximity and reported noise.
## After losing sight, it retains only the last known position; it never exposes
## the target's live position to other systems.

signal target_spotted
signal target_lost
signal noise_heard(position: Vector3, loudness: float)
signal awareness_changed(value: float)
signal detection_confirmed

@export var target_path: NodePath
@export var vision_half_angle_degrees: float = 55.0
@export var vision_range: float = 9.0
@export var crouched_vision_range: float = 5.0
@export var proximity_range: float = 1.6
@export var hearing_range_running: float = 10.0
@export var hearing_range_walking: float = 6.0
@export var hearing_range_crouching: float = 2.5
@export var hearing_range_still: float = 1.5
@export var awareness_rate: float = 1.0
@export var awareness_loss_rate: float = 0.5
@export var alert_duration: float = 0.55
@export var collision_mask: int = 1

var target: Node3D
var awareness: float = 0.0
var is_target_visible: bool = false
var last_known_position: Vector3
var has_last_known_position: bool = false
var _alert_timer: float = 0.0
var _detection_confirmed: bool = false
var _ray_cast: RayCast3D

func _ready() -> void:
	_ray_cast = RayCast3D.new()
	_ray_cast.enabled = false
	_ray_cast.collide_with_areas = false
	_ray_cast.collide_with_bodies = true
	_ray_cast.collision_mask = collision_mask
	add_child(_ray_cast)

	if not target_path.is_empty():
		set_target(get_node_or_null(target_path))

func set_target(new_target: Node3D) -> void:
	target = new_target
	reset()

func report_noise(position: Vector3, loudness: float) -> void:
	if loudness <= 0.0:
		return

	var distance := global_position.distance_to(position)
	if distance > loudness:
		return

	last_known_position = position
	has_last_known_position = true
	noise_heard.emit(position, loudness)

func can_see_target() -> bool:
	if target == null or not is_instance_valid(target):
		return false

	var target_position := target.global_position
	var distance := global_position.distance_to(target_position)

	if distance <= proximity_range:
		return true

	var effective_range := vision_range
	if target.has_method("is_crouching") and target.is_crouching():
		effective_range = crouched_vision_range

	if distance > effective_range:
		return false

	var to_target := (target_position - global_position).normalized()
	var forward := -global_transform.basis.z
	var angle := rad_to_deg(forward.angle_to(to_target))

	if angle > vision_half_angle_degrees:
		return false

	return _has_line_of_sight(target_position)

func get_last_known_position() -> Vector3:
	return last_known_position

func has_known_position() -> bool:
	return has_last_known_position

func get_awareness() -> float:
	return awareness

func is_alerted() -> bool:
	return _alert_timer > 0.0

func has_confirmed_target() -> bool:
	return _detection_confirmed

func reset() -> void:
	awareness = 0.0
	is_target_visible = false
	has_last_known_position = false
	last_known_position = Vector3.ZERO
	_alert_timer = 0.0
	_detection_confirmed = false
	awareness_changed.emit(awareness)

func _physics_process(delta: float) -> void:
	var visible_now := can_see_target()

	if visible_now:
		last_known_position = target.global_position
		has_last_known_position = true

		if not is_target_visible:
			target_spotted.emit()

		awareness = minf(1.0, awareness + awareness_rate * delta)
	else:
		if is_target_visible:
			target_lost.emit()

		awareness = maxf(0.0, awareness - awareness_loss_rate * delta)

	if _alert_timer > 0.0:
		_alert_timer = maxf(0.0, _alert_timer - delta)

	if awareness >= 1.0 and not _detection_confirmed:
		_alert_timer = alert_duration
		_detection_confirmed = true
		detection_confirmed.emit()

	if _detection_confirmed and not visible_now and awareness <= 0.0:
		_detection_confirmed = false

	is_target_visible = visible_now
	awareness_changed.emit(awareness)

func _has_line_of_sight(target_position: Vector3) -> bool:
	if _ray_cast == null:
		return false

	_ray_cast.global_position = global_position
	_ray_cast.target_position = _ray_cast.to_local(target_position)
	_ray_cast.force_raycast_update()

	return not _ray_cast.is_colliding()
