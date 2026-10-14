class_name ThreatCaptureComponent
extends Area3D

## Reusable capture component for the Phase 2 threat agent.
## Detects contact with a configured target and emits a neutral capture signal.
## It does not decide the narrative, respawn or mission consequence.

signal target_caught(target: Node3D)

@export var target_path: NodePath
@export var capture_radius: float = 0.9
@export var capture_cooldown: float = 1.0

var target: Node3D
var can_capture: bool = true
var _cooldown_timer: float = 0.0

func _ready() -> void:
	monitoring = true
	monitorable = false

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = capture_radius
	shape.shape = sphere
	add_child(shape)

	if not target_path.is_empty():
		set_target(get_node_or_null(target_path))

func set_target(new_target: Node3D) -> void:
	target = new_target

func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return

	if not can_capture:
		_cooldown_timer = maxf(0.0, _cooldown_timer - delta)

		if _cooldown_timer <= 0.0:
			can_capture = true

		return

	if global_position.distance_to(target.global_position) <= capture_radius:
		can_capture = false
		_cooldown_timer = capture_cooldown
		target_caught.emit(target)

func reset() -> void:
	can_capture = true
	_cooldown_timer = 0.0
