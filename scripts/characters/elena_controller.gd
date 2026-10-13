extends CharacterBody3D

const B = preload("res://scripts/components/build_util.gd")
const ConditionScript = preload("res://scripts/components/character_condition.gd")

signal fell_off
signal jumped

@export var max_speed: float = 4.5
@export var acceleration: float = 15.0
@export var deceleration: float = 15.0
@export var min_speed: float = 0.1
@export var turn_speed: float = 14.0
@export var gravity: float = 28.0
@export var jump_velocity: float = 5.8
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.14

var facing_vector: Vector2 = Vector2(0.0, 1.0)
var input_enabled: bool = true
var visual: Node3D = null
var condition = null

var _t: float = 0.0
var _coyote_left: float = 0.0
var _buffer_left: float = 0.0
var _sync_left: float = 0.0

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	condition = ConditionScript.new()
	GameManager.stats_changed.connect(_on_stats_changed)
	_build_body()

func _on_stats_changed() -> void:
	if not GameManager.elena_condition.is_empty():
		condition.from_dict(GameManager.elena_condition)

func _build_body() -> void:
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.32
	cap.height = 1.7
	cs.shape = cap
	cs.position = Vector3(0.0, 0.85, 0.0)
	add_child(cs)

	visual = Node3D.new()
	add_child(visual)

	var dark := Color(0.07, 0.09, 0.12)
	var coat := Color(0.05, 0.24, 0.32)
	var skin := Color(0.8, 0.62, 0.52)
	var hair := Color(0.16, 0.1, 0.07)

	for side in [-1.0, 1.0]:
		var leg := CapsuleMesh.new()
		leg.radius = 0.11
		leg.height = 0.85
		_add_mesh(leg, Vector3(0.12 * side, 0.43, 0.0), dark)

	var torso := CapsuleMesh.new()
	torso.radius = 0.27
	torso.height = 1.0
	_add_mesh(torso, Vector3(0.0, 1.05, 0.0), coat)

	var head := SphereMesh.new()
	head.radius = 0.17
	head.height = 0.34
	_add_mesh(head, Vector3(0.0, 1.72, 0.0), skin)

	var hair_mesh := SphereMesh.new()
	hair_mesh.radius = 0.18
	hair_mesh.height = 0.34
	_add_mesh(hair_mesh, Vector3(0.0, 1.76, -0.05), hair)

	var pack := BoxMesh.new()
	pack.size = Vector3(0.34, 0.45, 0.18)
	_add_mesh(pack, Vector3(0.0, 1.15, -0.28), Color(0.12, 0.16, 0.18))

	var aster := SphereMesh.new()
	aster.radius = 0.06
	aster.height = 0.12
	_add_mesh(aster, Vector3(0.0, 1.25, 0.27), Color(0.2, 0.9, 1.0), 3.0)

	var glow := OmniLight3D.new()
	glow.light_color = Color(0.2, 0.9, 1.0)
	glow.light_energy = 0.6
	glow.omni_range = 3.5
	glow.position = Vector3(0.0, 1.3, 0.45)
	visual.add_child(glow)

func _add_mesh(mesh: Mesh, pos: Vector3, color: Color, emission: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = B.mat(color, 0.7, emission)
	mi.position = pos
	visual.add_child(mi)
	return mi

func _process(delta: float) -> void:
	_t += delta
	visual.scale.y = 1.0 + 0.02 * (0.5 + 0.5 * sin(_t * TAU / 1.5))

func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()
	var input_vec := Vector2.ZERO
	if input_enabled:
		input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed: float = max_speed * condition.speed_multiplier()
	var target := Vector3(input_vec.x, 0.0, input_vec.y) * speed
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var rate := acceleration if input_vec != Vector2.ZERO else deceleration
	horizontal = horizontal.move_toward(target, rate * delta)
	if input_vec == Vector2.ZERO and horizontal.length() < min_speed:
		horizontal = Vector3.ZERO
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if on_floor:
		velocity.y = -0.5
		_coyote_left = coyote_time
	else:
		velocity.y -= gravity * delta
		_coyote_left = maxf(0.0, _coyote_left - delta)

	if input_enabled and InputMap.has_action("jump") and Input.is_action_just_pressed("jump"):
		_buffer_left = jump_buffer_time
	else:
		_buffer_left = maxf(0.0, _buffer_left - delta)
	if _buffer_left > 0.0 and _coyote_left > 0.0:
		velocity.y = jump_velocity * condition.jump_multiplier()
		condition.spend(ConditionScript.JUMP_COST)
		_buffer_left = 0.0
		_coyote_left = 0.0
		jumped.emit()

	condition.tick(delta, input_vec != Vector2.ZERO, on_floor)

	if input_vec != Vector2.ZERO:
		facing_vector = input_vec.normalized()
		var wanted := atan2(input_vec.x, input_vec.y)
		visual.rotation.y = lerp_angle(visual.rotation.y, wanted, clampf(turn_speed * delta, 0.0, 1.0))
	move_and_slide()

	_sync_left -= delta
	if _sync_left <= 0.0:
		_sync_left = 0.25
		GameManager.elena_condition = condition.to_dict()

	if global_position.y < -6.0:
		velocity = Vector3.ZERO
		fell_off.emit()
