extends CharacterBody3D
## Lightweight route-following human actor for the conduit sequence. The explicit waypoints are the
## validated escape graph; collision remains authoritative, so a blocked actor never teleports forward.

const PersonVisualScript := preload("res://scripts/characters/person_visual.gd")
const GRAVITY := 18.0
const STUCK_EPSILON := 0.02
const STUCK_TIMEOUT := 1.25

signal route_blocked(actor_id: String)
signal path_finished(actor_id: String)

var actor_id := ""
var person_id := ""
var visual: Node3D
var _capsule: CollisionShape3D
var _standing_shape: CapsuleShape3D
var _down_shape: CapsuleShape3D
var _path: Array[Vector3] = []
var _path_index := 0
var _move_speed := 3.2
var _motion_state := "idle"
var _stuck_time := 0.0
var _last_position := Vector3.ZERO
var _jump_requested := false
var _jump_pending := false


func configure(actor_name: String, model_id: String) -> void:
	actor_id = actor_name
	person_id = model_id
	name = actor_name


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	_standing_shape = CapsuleShape3D.new()
	_standing_shape.radius = 0.32
	_standing_shape.height = 1.72
	_down_shape = CapsuleShape3D.new()
	_down_shape.radius = 0.32
	_down_shape.height = 0.88
	_capsule = CollisionShape3D.new()
	_capsule.name = "BodyCollision"
	_capsule.shape = _standing_shape
	_capsule.position.y = 0.86
	add_child(_capsule)
	var model := PersonVisualScript.new()
	model.name = "PersonVisual"
	model.person = person_id
	visual = model
	add_child(visual)
	_last_position = global_position


func follow_path(points: Array, speed_mps: float = 3.2) -> void:
	_path.clear()
	for point in points:
		if point is Vector3:
			_path.append(point)
	_move_speed = maxf(0.1, speed_mps)
	_path_index = 0
	_stuck_time = 0.0
	_motion_state = "moving" if not _path.is_empty() else "idle"
	_jump_requested = false
	_jump_pending = false
	_play("run", _move_speed)


func stop_at_barrier() -> void:
	_motion_state = "blocked"
	_path.clear()
	velocity.x = 0.0
	velocity.z = 0.0
	_play("alert")


func jump_barrier() -> void:
	if _motion_state != "moving" or _jump_requested:
		return
	_jump_requested = true
	_jump_pending = true


func knock_down() -> void:
	_motion_state = "down"
	_path.clear()
	_capsule.shape = _down_shape
	_capsule.position.y = 0.44
	visual.position.y = 0.18
	visual.rotation.z = -PI * 0.5
	velocity = Vector3.ZERO
	_play("idle")


func recover() -> void:
	_motion_state = "idle"
	_capsule.shape = _standing_shape
	_capsule.position.y = 0.86
	visual.position = Vector3.ZERO
	visual.rotation = Vector3.ZERO
	_play("alert")


func neutralize() -> void:
	_motion_state = "neutralized"
	_path.clear()
	_capsule.shape = _down_shape
	_capsule.position.y = 0.44
	visual.position.y = 0.18
	visual.rotation.z = -PI * 0.5
	velocity = Vector3.ZERO
	_play("idle")


func _physics_process(delta: float) -> void:
	if _jump_pending and is_on_floor():
		velocity.y = 4.5
		_jump_pending = false
	elif not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = minf(velocity.y, 0.0)
	if _motion_state == "moving" and _path_index < _path.size():
		var target := _path[_path_index]
		var to_target := target - global_position
		to_target.y = 0.0
		if to_target.length() <= 0.34:
			_path_index += 1
			if _path_index >= _path.size():
				_motion_state = "idle"
				velocity.x = 0.0
				velocity.z = 0.0
				_play("idle")
				path_finished.emit(actor_id)
			else:
				target = _path[_path_index]
				to_target = target - global_position
				to_target.y = 0.0
		var direction := to_target.normalized()
		velocity.x = direction.x * _move_speed
		velocity.z = direction.z * _move_speed
		if visual != null:
			visual.call("face", direction, delta, 7.0)
		_play("run", _move_speed)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)
	var has_movement_intent := Vector2(velocity.x, velocity.z).length() > 0.5
	move_and_slide()
	if _motion_state == "moving":
		if global_position.distance_to(_last_position) < STUCK_EPSILON and has_movement_intent:
			_stuck_time += delta
			if _stuck_time >= STUCK_TIMEOUT:
				_stuck_time = 0.0
				route_blocked.emit(actor_id)
		else:
			_stuck_time = 0.0
	_last_position = global_position


func _play(clip: String, speed: float = -1.0) -> void:
	if visual != null and visual.has_method("play"):
		visual.call("play", clip, speed)
