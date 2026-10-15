extends CharacterBody3D

const B = preload("res://scripts/components/build_util.gd")
const ConditionScript = preload("res://scripts/components/character_condition.gd")
const PoseScript = preload("res://scripts/characters/elena_procedural_pose.gd")

## Elena's model (v2, 2026-10-15: MPFB body and rig, MakeHuman CC0 skin, eyes, brows, lashes and hair; see
## tools/blender/elena_mpfb/build_elena_v2.py). If it cannot be loaded, the primitive body is used.
const MPFB_MODEL_PATH := "res://assets/models/characters/elena/elena.glb"
## Imported surfaces get the .tres named like their material, looked up in these folders in order.
const MPFB_MATERIAL_DIRS := ["res://assets/materials/characters/elena/", "res://assets/materials/lab_ref/"]

signal fell_off
signal jumped
## Emitted when a ledge mantle starts (height of the ledge above the feet, in metres).
signal mantled(height: float)

## Ground speeds (2026-10-15 tuning, matched to the animation clips' natural speeds, see phase1_spatial_player.gd):
## default pace 4.2 m/s (a light run), sprint 6.8 m/s, crouched 1.4 m/s.
@export var max_speed: float = 4.2
@export var run_multiplier: float = 1.62
@export var crouch_multiplier: float = 0.33
@export var acceleration: float = 22.0
@export var deceleration: float = 28.0
## Turning on the ground keeps momentum: the velocity rotates towards the new direction at this rate (rad/s)
## instead of sliding through zero. A reversal sharper than REVERSE_ANGLE brakes hard and re-accelerates.
@export var ground_turn_rate: float = 11.0
@export var reverse_brake: float = 42.0
const REVERSE_ANGLE := 2.3
## Falling is a little heavier than rising: a firmer, less floaty arc with the same jump height.
@export var fall_gravity_multiplier: float = 1.25
## Lower acceleration in the air: jumps keep their arc instead of steering like on the ground.
@export var air_acceleration: float = 7.0
@export var min_speed: float = 0.1
@export var turn_speed: float = 14.0
@export var gravity: float = 28.0
@export var jump_velocity: float = 5.8
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.14
## Stamina is the single `condition.stamina` gauge (0..100) shown by the HUD: running drains it per second,
## a mantle costs a fixed amount, jumps keep their existing cost, and it recovers walking or standing still.
@export var run_drain: float = 14.0
@export var mantle_cost: float = 10.0
## Ledge mantle ("trepar repisas"): only onto a top surface between these heights above the feet, with room
## to stand on it and real support under the feet. Thin rails, walls and anything too high are never climbable.
@export var mantle_min_height: float = 0.45
@export var mantle_max_height: float = 1.85
@export var mantle_reach: float = 0.75
@export var mantle_up_speed: float = 3.2
## Usa el modelo MPFB texturizado en lugar del cuerpo de primitivas.
@export var use_mpfb_model: bool = true

const STAND_HEIGHT := 1.7
const CROUCH_HEIGHT := 1.05
const WALK_FATIGUE_FLOOR := 0.85
const CAPSULE_RADIUS := 0.32
## Physics layer bit of guard rails (layer 5): Elena collides with them but never mantles onto them.
const NO_MANTLE_LAYER := 16

var facing_vector: Vector2 = Vector2(0.0, 1.0)
var input_enabled: bool = true
var visual: Node3D = null
var condition = null
## True si el modelo MPFB se cargo; false si se usa el cuerpo de primitivas.
var uses_mpfb_model: bool = false
## Procedural pose layer (MPFB model only): lowers the bind-pose arms and animates walk, jump and landing.
var pose = null

## Mirror of condition.stamina, kept for older callers.
var stamina: float = 100.0
var is_crouching: bool = false
var is_running: bool = false
## True during a ledge mantle (the animation layer plays "climb").
var is_climbing: bool = false
## Base usada para transformar el input de movimiento (por defecto, mundo).
var movement_basis: Basis = Basis.IDENTITY
## While input is disabled (cinematics), a scripted stick vector in movement_basis space; zero = stand still.
var scripted_input: Vector2 = Vector2.ZERO
## Scripted running (cinematics): same as holding `run`.
var scripted_run: bool = false

var _t: float = 0.0
var _coyote_left: float = 0.0
var _buffer_left: float = 0.0
var _sync_left: float = 0.0
var _material_cache: Dictionary = {}
var _collision_shape: CollisionShape3D = null
var _mantle_target: Vector3 = Vector3.ZERO
var _mantle_phase: int = 0  # 0 none, 1 rising, 2 stepping onto the ledge

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1 | NO_MANTLE_LAYER
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
	_add_aster_glow(model)
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
	var material: Material = null
	for dir in MPFB_MATERIAL_DIRS:
		var path: String = dir + material_name + ".tres"
		if ResourceLoader.exists(path):
			material = load(path) as Material
			break
	_material_cache[material_name] = material
	return material

## The Aster scanner's screen (a wrist unit on the left forearm since 2026-10-15): a faint cyan spill that follows the
## screen. Kept weak and short: at 0.7 energy from the hand it lit her face and coat neon cyan (2026-10-15 baseline).
const ASTER_GLOW_ENERGY := 0.18
const ASTER_GLOW_RANGE := 0.9

func _add_aster_glow(model: Node) -> void:
	var glow := OmniLight3D.new()
	glow.name = "AsterGlow"
	glow.light_color = Color(0.5, 0.88, 0.86)
	glow.light_energy = ASTER_GLOW_ENERGY
	glow.omni_range = ASTER_GLOW_RANGE
	glow.shadow_enabled = false
	var screen := model.find_child("emit_aster", true, false)
	if screen != null:
		screen.add_child(glow)
		glow.position = Vector3.ZERO
	else:
		glow.position = Vector3(0.16, 1.05, 0.2)
		visual.add_child(glow)

func _process(delta: float) -> void:
	_t += delta
	visual.scale.y = 1.0 + 0.02 * (0.5 + 0.5 * sin(_t * TAU / 1.5))

func _physics_process(delta: float) -> void:
	if _mantle_phase > 0:
		_step_mantle(delta)
		return
	var on_floor := is_on_floor()
	var input_vec := Vector2.ZERO
	if input_enabled:
		input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	elif scripted_input != Vector2.ZERO:
		input_vec = scripted_input  # cinematics walk Elena with the same physics and animation as play

	var wants_run: bool = ((input_enabled and _action("run")) or (not input_enabled and scripted_run)) and input_vec != Vector2.ZERO
	var wants_crouch: bool = input_enabled and _action("crouch")
	_set_crouching((wants_crouch and on_floor) or (is_crouching and not _can_stand()))

	# Fatigue mostly costs sprinting: running uses the full condition multiplier, but walking never drops below
	# WALK_FATIGUE_FLOOR of normal pace (an exhausted Elena can still walk away and recover; she cannot sprint).
	var tired: float = condition.speed_multiplier()
	var speed: float = max_speed * maxf(tired, WALK_FATIGUE_FLOOR)
	is_running = false
	if is_crouching:
		speed *= crouch_multiplier
	elif wants_run and condition.stamina > 0.0 and on_floor:
		speed = max_speed * tired * run_multiplier
		is_running = true

	var move_dir: Vector3 = movement_basis * Vector3(input_vec.x, 0.0, input_vec.y)
	var target: Vector3 = move_dir * speed
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	horizontal = _ground_velocity(horizontal, target, on_floor, delta)
	if input_vec == Vector2.ZERO and on_floor and horizontal.length() < min_speed:
		horizontal = Vector3.ZERO
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if on_floor:
		velocity.y = -0.5
		_coyote_left = coyote_time
	else:
		velocity.y -= gravity * (fall_gravity_multiplier if velocity.y < 0.0 else 1.0) * delta
		_coyote_left = maxf(0.0, _coyote_left - delta)

	if input_enabled and InputMap.has_action("jump") and Input.is_action_just_pressed("jump"):
		_buffer_left = jump_buffer_time
	else:
		_buffer_left = maxf(0.0, _buffer_left - delta)
	if _buffer_left > 0.0 and input_vec != Vector2.ZERO and _try_mantle(move_dir):
		_buffer_left = 0.0
		return
	if _buffer_left > 0.0 and _coyote_left > 0.0 and not is_crouching:
		velocity.y = jump_velocity * condition.jump_multiplier()
		condition.spend(ConditionScript.JUMP_COST)
		_buffer_left = 0.0
		_coyote_left = 0.0
		jumped.emit()

	if is_running:
		condition.spend(run_drain * delta)
	else:
		condition.tick(delta, input_vec != Vector2.ZERO, on_floor)
	stamina = condition.stamina

	if input_vec != Vector2.ZERO:
		facing_vector = Vector2(move_dir.x, move_dir.z).normalized()
		var wanted := atan2(move_dir.x, move_dir.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, wanted, clampf(turn_speed * delta, 0.0, 1.0))
	move_and_slide()
	_sync_condition(delta)

	if global_position.y < -6.0:
		velocity = Vector3.ZERO
		fell_off.emit()

## Horizontal velocity response. On the ground, turns keep their speed (the direction rotates at
## ground_turn_rate) and only a near-reversal brakes through zero; speed changes use acceleration/deceleration.
## In the air, the slower air_acceleration keeps the arc committed.
func _ground_velocity(horizontal: Vector3, target: Vector3, on_floor: bool, delta: float) -> Vector3:
	if not on_floor:
		return horizontal.move_toward(target, air_acceleration * delta)
	var cur := horizontal.length()
	var want := target.length()
	if want < 0.01:
		return horizontal.move_toward(Vector3.ZERO, deceleration * delta)
	if cur < 0.3:
		return horizontal.move_toward(target, acceleration * delta)
	var cur_dir := horizontal / cur
	var want_dir := target / want
	var angle := cur_dir.signed_angle_to(want_dir, Vector3.UP)
	if absf(angle) > REVERSE_ANGLE:
		return horizontal.move_toward(target, reverse_brake * delta)
	var step := clampf(angle, -ground_turn_rate * delta, ground_turn_rate * delta)
	var new_dir := cur_dir.rotated(Vector3.UP, step)
	var new_speed := move_toward(cur, want, (acceleration if want > cur else deceleration) * delta)
	return new_dir * new_speed


func _action(action: String) -> bool:
	return InputMap.has_action(action) and Input.is_action_pressed(action)

## Crouching really lowers the collision capsule (1.05 m) so low ducts and gaps can be passed.
func _set_crouching(value: bool) -> void:
	if value == is_crouching or _collision_shape == null:
		return
	is_crouching = value
	var cap := _collision_shape.shape as CapsuleShape3D
	cap.height = CROUCH_HEIGHT if value else STAND_HEIGHT
	_collision_shape.position.y = cap.height * 0.5

## Standing up is refused while something is overhead (no popping through a duct ceiling).
func _can_stand() -> bool:
	return _capsule_fits(global_position + Vector3(0.0, 0.02, 0.0), STAND_HEIGHT)

func _capsule_fits(feet: Vector3, height: float) -> bool:
	if not is_inside_tree():
		return true
	var cap := CapsuleShape3D.new()
	cap.radius = CAPSULE_RADIUS - 0.02
	cap.height = height
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = cap
	q.transform = Transform3D(Basis.IDENTITY, feet + Vector3(0.0, height * 0.5 + 0.01, 0.0))
	q.collision_mask = collision_mask | NO_MANTLE_LAYER
	q.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(q, 1).is_empty()

## Ledge detection: a wall face ahead within reach, a top surface 0.45-1.85 m above the feet, real support
## under the landing (four probes, so thin rails do not count) and standing room on top.
func _try_mantle(move_dir: Vector3) -> bool:
	if is_crouching or condition.stamina < mantle_cost * 0.5:
		return false
	var dir := Vector3(move_dir.x, 0.0, move_dir.z).normalized()
	if dir == Vector3.ZERO:
		return false
	var space := get_world_3d().direct_space_state
	var mask := collision_mask | NO_MANTLE_LAYER
	var feet := global_position
	var wall_hit := {}
	for h in [0.35, 0.8, 1.3]:
		var from: Vector3 = feet + Vector3(0.0, h, 0.0)
		var q := PhysicsRayQueryParameters3D.create(from, from + dir * (CAPSULE_RADIUS + mantle_reach), mask, [get_rid()])
		wall_hit = space.intersect_ray(q)
		if not wall_hit.is_empty():
			break
	if wall_hit.is_empty() or _is_no_mantle(wall_hit["collider"]):
		return false
	var landing: Vector3 = (wall_hit["position"] as Vector3) + dir * (CAPSULE_RADIUS + 0.12)
	var side := dir.cross(Vector3.UP).normalized()
	var top_y := -INF
	for offset in [Vector3.ZERO, dir * 0.22 + side * 0.2, dir * 0.22 - side * 0.2, dir * 0.4]:
		var probe: Vector3 = landing + offset
		var down := PhysicsRayQueryParameters3D.create(Vector3(probe.x, feet.y + mantle_max_height + 0.4, probe.z), Vector3(probe.x, feet.y + mantle_min_height - 0.2, probe.z), mask, [get_rid()])
		var hit := space.intersect_ray(down)
		if hit.is_empty() or (hit["normal"] as Vector3).y < 0.85 or _is_no_mantle(hit["collider"]):
			return false
		var y: float = (hit["position"] as Vector3).y
		if top_y > -INF and absf(y - top_y) > 0.12:
			return false
		top_y = maxf(top_y, y)
	var height := top_y - feet.y
	if height < mantle_min_height or height > mantle_max_height:
		return false
	var target := Vector3(landing.x, top_y + 0.02, landing.z)
	if not _capsule_fits(target, STAND_HEIGHT):
		return false
	# The body must also be able to rise in place to the ledge height without hitting a ceiling...
	if not _capsule_fits(Vector3(feet.x, top_y + 0.02, feet.z), STAND_HEIGHT):
		return false
	# ...and then step across at that height without passing through anything (a rail at the edge, a wall).
	for h in [0.3, 0.9, 1.5]:
		var across := PhysicsRayQueryParameters3D.create(Vector3(feet.x, top_y + h, feet.z), target + Vector3(0.0, h, 0.0) + dir * CAPSULE_RADIUS, mask, [get_rid()])
		if not space.intersect_ray(across).is_empty():
			return false
	_mantle_target = target
	_mantle_phase = 1
	is_climbing = true
	velocity = Vector3.ZERO
	condition.spend(mantle_cost)
	stamina = condition.stamina
	visual.rotation.y = atan2(dir.x, dir.z)
	facing_vector = Vector2(dir.x, dir.z)
	mantled.emit(height)
	return true

func _is_no_mantle(collider: Object) -> bool:
	var body := collider as CollisionObject3D
	return body != null and (body.collision_layer & NO_MANTLE_LAYER) != 0

func _step_mantle(delta: float) -> void:
	var p := global_position
	if _mantle_phase == 1:
		p.y = move_toward(p.y, _mantle_target.y, mantle_up_speed * delta)
		if is_equal_approx(p.y, _mantle_target.y):
			_mantle_phase = 2
	else:
		var flat := Vector2(_mantle_target.x - p.x, _mantle_target.z - p.z)
		var step := 2.4 * delta
		if flat.length() <= step:
			p.x = _mantle_target.x
			p.z = _mantle_target.z
			_mantle_phase = 0
			is_climbing = false
		else:
			var d := flat.normalized() * step
			p.x += d.x
			p.z += d.y
	global_position = p
	velocity = Vector3.ZERO

func _sync_condition(delta: float) -> void:
	_sync_left -= delta
	if _sync_left <= 0.0:
		_sync_left = 0.25
		GameManager.elena_condition = condition.to_dict()
