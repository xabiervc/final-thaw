extends CharacterBody3D

const B = preload("res://scripts/components/build_util.gd")
const ConditionScript = preload("res://scripts/components/character_condition.gd")
const PoseScript = preload("res://scripts/characters/elena_procedural_pose.gd")

## Modelo con textura de Elena (MPFB). Si no se puede cargar, se usa el cuerpo procedural.
const MPFB_MODEL_PATH := "res://assets/models/lab_ref/ref_elena_mpfb.glb"
const MPFB_MATERIAL_DIR := "res://assets/materials/lab_ref/"

signal fell_off
signal jumped

@export var max_speed: float = 4.5
@export var run_multiplier: float = 1.7
@export var crouch_multiplier: float = 0.5
@export var acceleration: float = 15.0
@export var deceleration: float = 15.0
@export var min_speed: float = 0.1
@export var turn_speed: float = 14.0
@export var gravity: float = 28.0
@export var jump_velocity: float = 5.8
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.14
@export var climb_speed: float = 2.6
@export var climb_check_distance: float = 0.55
@export var stamina_max: float = 100.0
@export var stamina_run_drain: float = 18.0
@export var stamina_climb_drain: float = 26.0
@export var stamina_regen: float = 22.0
## Usa el modelo MPFB texturizado en lugar del cuerpo de primitivas.
@export var use_mpfb_model: bool = true

var facing_vector: Vector2 = Vector2(0.0, 1.0)
var input_enabled: bool = true
var visual: Node3D = null
var condition = null
## True si el modelo MPFB se cargo; false si se usa el cuerpo de primitivas.
var uses_mpfb_model: bool = false
## Procedural pose layer (MPFB model only): lowers the bind-pose arms and animates walk, jump and landing.
var pose = null

var stamina: float = 100.0
var is_crouching: bool = false
var is_climbing: bool = false
## Base usada para transformar el input de movimiento (por defecto, mundo).
var movement_basis: Basis = Basis.IDENTITY

var _t: float = 0.0
var _coyote_left: float = 0.0
var _buffer_left: float = 0.0
var _sync_left: float = 0.0
var _material_cache: Dictionary = {}
var _collision_shape: CollisionShape3D = null

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
	_collision_shape = cs

	visual = Node3D.new()
	add_child(visual)
	if use_mpfb_model and _build_mpfb_visual():
		return
	_build_primitive_visual()

func _build_primitive_visual() -> void:
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
	hair.radius = 0.18
	hair.height = 0.34
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

func _build_mpfb_visual() -> bool:
	if not ResourceLoader.exists(MPFB_MODEL_PATH):
		return false
	var scene := load(MPFB_MODEL_PATH) as PackedScene
	if scene == null:
		return false
	var model := scene.instantiate() as Node3D
	if model == null:
		return false
	model.name = "ElenaModel"
	visual.add_child(model)
	_dress_model(model)
	_add_aster_glow(Vector3(-0.16, 1.1, 0.4), 0.7, 1.8)
	pose = PoseScript.new()
	pose.name = "ProceduralPose"
	add_child(pose)
	pose.setup(self, model)
	uses_mpfb_model = true
	return true

## Asigna a cada superficie el .tres que se llama como su material importado
## (mismo metodo que lab_reference_scene.gd). Si falta uno, se conserva el importado.
func _dress_model(model: Node) -> void:
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface in mesh_instance.mesh.get_surface_count():
			var imported := mesh_instance.mesh.surface_get_material(surface)
			var material_name := imported.resource_name if imported != null else ""
			var material := _material_for(material_name)
			if material != null:
				mesh_instance.set_surface_override_material(surface, material)

func _material_for(material_name: String) -> Material:
	if material_name == "":
		return null
	if _material_cache.has(material_name):
		return _material_cache[material_name]
	var path := MPFB_MATERIAL_DIR + material_name + ".tres"
	var material: Material = null
	if ResourceLoader.exists(path):
		material = load(path) as Material
	_material_cache[material_name] = material
	return material

func _add_aster_glow(pos: Vector3, energy: float, light_range: float) -> void:
	var glow := OmniLight3D.new()
	glow.light_color = Color(0.3, 0.95, 0.9)
	glow.light_energy = energy
	glow.omni_range = light_range
	glow.position = pos
	visual.add_child(glow)

func _process(delta: float) -> void:
	_t += delta
	visual.scale.y = 1.0 + 0.02 * (0.5 + 0.5 * sin(_t * TAU / 1.5))

func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()
	var input_vec := Vector2.ZERO
	if input_enabled:
		input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var wants_run: bool = input_enabled and Input.is_key_pressed(KEY_SHIFT) and input_vec != Vector2.ZERO
	var wants_crouch: bool = input_enabled and (Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_C))
	var wants_climb: bool = input_enabled and Input.is_key_pressed(KEY_SPACE)

	if is_climbing and (not wants_climb or stamina <= 0.0 or not _wall_ahead()):
		is_climbing = false

	if not is_climbing and wants_climb and _wall_ahead() and stamina > 0.0:
		is_climbing = true

	if is_climbing:
		velocity.x = 0.0
		velocity.z = 0.0
		velocity.y = climb_speed
		stamina = maxf(0.0, stamina - stamina_climb_drain * delta)
		condition.tick(delta, false, false)
		move_and_slide()
		_sync_condition(delta)
		return

	is_crouching = wants_crouch and on_floor

	var speed: float = max_speed * condition.speed_multiplier()
	if is_crouching:
		speed *= crouch_multiplier
	elif wants_run and stamina > 0.0:
		speed *= run_multiplier

	var move_dir: Vector3 = movement_basis * Vector3(input_vec.x, 0.0, input_vec.y)
	var target: Vector3 = move_dir * speed
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

	if wants_run and input_vec != Vector2.ZERO and stamina > 0.0:
		stamina = maxf(0.0, stamina - stamina_run_drain * delta)
	else:
		stamina = minf(stamina_max, stamina + stamina_regen * delta)

	condition.tick(delta, input_vec != Vector2.ZERO, on_floor)

	if input_vec != Vector2.ZERO:
		facing_vector = Vector2(move_dir.x, move_dir.z).normalized()
		var wanted := atan2(move_dir.x, move_dir.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, wanted, clampf(turn_speed * delta, 0.0, 1.0))
	move_and_slide()

	_sync_left -= delta
	if _sync_left <= 0.0:
		_sync_left = 0.25
		GameManager.elena_condition = condition.to_dict()

	if global_position.y < -6.0:
		velocity = Vector3.ZERO
		fell_off.emit()

func _sync_condition(delta: float) -> void:
	_sync_left -= delta
	if _sync_left <= 0.0:
		_sync_left = 0.25
		GameManager.elena_condition = condition.to_dict()

func _wall_ahead() -> bool:
	var space := get_world_3d().direct_space_state
	var from := global_position + Vector3(0.0, 1.1, 0.0)
	var dir := Vector3(facing_vector.x, 0.0, facing_vector.y).normalized()
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * climb_check_distance, collision_mask)
	return not space.intersect_ray(query).is_empty()
