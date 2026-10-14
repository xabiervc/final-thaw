extends Node3D
## Prototipo de movimiento y persecución (hitos A y B, versión 2); su tramo final se ambienta como aparcamiento de servicio.
## Escena aislada para validar la direccion de infiltracion y huida. No modifica el laboratorio,
## el arte, el guardado ni los contratos de Fase 0. Reutiliza el modelo y la capa de pose de Elena
## y el audio sintetizado del equipo de arte, con vuelta a primitivas si el modelo no carga.
##
## Ejecutar: godot --path . res://scenes/prototypes/motion_chase_prototype.tscn
## Controles: raton camara (clic para capturar), WASD mover, Shift correr, Ctrl agacharse,
## Espacio saltar, E trepar, Q mantener para escanear, R reiniciar al terminar, Esc menu.

const SfxSynth = preload("res://scripts/audio/sfx_synth.gd")
const PoseScript = preload("res://scripts/characters/elena_procedural_pose.gd")
const Handoff = preload("res://scripts/phase1/phase1_handoff.gd")

const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const MODEL_PATH := "res://assets/models/lab_ref/ref_elena_mpfb.glb"
const MATERIAL_DIR := "res://assets/materials/lab_ref/"

const WALL_COLOR := Color(0.16, 0.19, 0.23)
const FLOOR_COLOR := Color(0.11, 0.13, 0.16)
const CYAN := Color(0.3, 0.95, 0.9)
const AMBER := Color(0.95, 0.65, 0.2)
const DANGER := Color(0.95, 0.2, 0.15)
const SAFE_GREEN := Color(0.45, 0.9, 0.5)

const STAND_HEIGHT := 1.7
const CROUCH_HEIGHT := 1.0
const WALK_SPEED := 4.2
const RUN_SPEED := 6.8
const CROUCH_SPEED := 2.2
const GROUND_ACCEL := 18.0
const GROUND_DECEL := 22.0
const AIR_ACCEL := 8.0
const GRAVITY := 22.0
const JUMP_VELOCITY := 6.2
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.1
const STEP_LENGTH := 0.75

const CAMERA_DISTANCE := 7.5
const CAMERA_PITCH_DEFAULT := 0.5
const CAMERA_PITCH_MIN := 0.2
const CAMERA_PITCH_MAX := 1.15
const MOUSE_SENSITIVITY := 0.0022
const OCCLUDED_ALPHA := 0.18
const FADE_SPEED := 6.0

const NOISE_STILL := 1.5
const NOISE_CROUCH := 2.5
const NOISE_WALK := 6.0
const NOISE_RUN := 10.0

const ENEMY_HEIGHT := 2.0
const ENEMY_PATROL_SPEED := 2.2
const ENEMY_INVESTIGATE_SPEED := 3.4
const ENEMY_CHASE_SPEED := 5.4
const DETECT_RADIUS := 9.0
const DETECT_HALF_ANGLE := 55.0
const CROUCH_VISION_FACTOR := 0.55
const NEAR_SENSE := 1.6
const DETECT_TIME := 0.9
const AWARENESS_DECAY := 0.6
const ALERT_TIME := 0.55
const SEARCH_TIME := 4.0
const PATROL_WAIT := 0.8
const ARRIVE_DISTANCE := 0.5
const CATCH_DISTANCE := 1.2
const CATCH_HEIGHT := 1.2
const PROBE_LENGTH := 1.5
const AVOID_ANGLES := [0.0, 35.0, -35.0, 70.0, -70.0]

const SCAN_CHARGE_TIME := 0.9
const SCAN_REVEAL_TIME := 3.0
const SCAN_COOLDOWN := 4.0

const HALF_DEPTH := 7.0
const FLOOR_SEGMENTS := [[-1.0, 14.0], [15.8, 30.0], [33.0, 60.0], [61.8, 82.0]]
const TUNNEL_X := [20.0, 25.5]
const DUCT_X := [41.0, 54.0]
const CEILING_BOTTOM := 1.25
const CLIMB_HEIGHT := 2.4
const EXIT_X := 78.0
const CHECKPOINTS := [Vector3(1.0, 0.2, 0.0), Vector3(17.0, 0.2, 0.0), Vector3(34.5, 0.2, 0.0), Vector3(63.0, 0.2, 0.0)]
const PATROL_POINTS := [Vector3(36.0, 0.0, -1.0), Vector3(57.0, 0.0, 1.0)]
const STATE_NAMES := {"patrol": "patrulla", "investigate": "investiga", "alert": "alerta", "chase": "persecución", "search": "búsqueda", "return": "regreso"}

var player: CharacterBody3D
var player_visual: Node3D
var player_camera: Camera3D
var pose = null
var uses_model: bool = false
var enemy: CharacterBody3D
var enemy_visual: Node3D
var enemy_eye_material: StandardMaterial3D
var enemy_light: OmniLight3D
var enemy_icon: Label3D
var enemy_alert_player: AudioStreamPlayer3D
var climb_area: Area3D
var tunnel_ceiling: StaticBody3D
var scan_markers: Array = []
var scan_enemy_marker: MeshInstance3D
var fade_bodies: Dictionary = {}
var hud: Label
var prompt: Label
var message: Label
var step_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var step_streams: Array = []
var land_stream: AudioStream
var scan_stream: AudioStream
var denied_stream: AudioStream
var chime_stream: AudioStream
var material_cache: Dictionary = {}

var cam_yaw: float = 0.0
var cam_pitch: float = CAMERA_PITCH_DEFAULT
var mouse_captured: bool = false
var crouching: bool = false
var running: bool = false
var coyote_left: float = 0.0
var buffer_left: float = 0.0
var was_on_floor: bool = true
var step_distance: float = 0.0
var step_index: int = 0
var climbing: bool = false
var climb_tween: Tween = null
var player_in_climb: bool = false
var scan_charge: float = 0.0
var scan_reveal_left: float = 0.0
var scan_cooldown_left: float = 0.0

var patrol_points: Array = PATROL_POINTS.duplicate()
var enemy_state: String = "patrol"
var enemy_target: int = 1
var awareness: float = 0.0
var alert_left: float = 0.0
var search_left: float = 0.0
var search_base_yaw: float = 0.0
var patrol_wait_left: float = 0.0
var last_known: Vector3 = Vector3.ZERO

@export_range(0, 3, 1) var initial_checkpoint_index: int = 0
@export var parking_entry_mode: bool = false
## Phase 1 state received at the east service mouth (empty in a standalone run). Session memory only.
var handoff: Dictionary = {}
var mission_flags: Dictionary = {}
## Seconds until the recovery unit comes out of the same service mouth (continuing the Phase 1 pursuit).
var unit_arrival_left: float = -1.0
const MOUTH_X := 33.0
var checkpoint_index: int = 0
var checkpoint_position: Vector3 = CHECKPOINTS[0]
var catches: int = 0
var times_spotted: int = 0
var elapsed: float = 0.0
var finished: bool = false
var message_left: float = 0.0


func _ready() -> void:
	checkpoint_index = clampi(initial_checkpoint_index, 0, CHECKPOINTS.size() - 1)
	checkpoint_position = CHECKPOINTS[checkpoint_index]
	if parking_entry_mode:
		patrol_points = [Vector3(43.0, 0.0, -1.0), Vector3(57.0, 0.0, 1.0)]
		if Handoff.has_pending():
			handoff = Handoff.consume()
			mission_flags = handoff.get("mission", {})
	_ensure_action("crouch", KEY_CTRL)
	_ensure_action("run", KEY_SHIFT)
	_build_level()
	if not handoff.is_empty():
		_build_service_mouth()
	_build_player()
	_build_enemy()
	if not handoff.is_empty():
		_continue_pursuit()
	_build_scan_markers()
	_build_audio()
	_build_ui()
	_update_camera(100.0)
	if not handoff.is_empty():
		_show_message("Containment sigue activo. Aléjate de la boca de servicio.", 5.0)
	elif parking_entry_mode:
		_show_message("Containment activado. Encuentra una salida.", 7.0)
	else:
		_show_message("Llega a la salida. Una unidad de recuperación patrulla la zona central: usa el escáner, el sigilo y el entorno.", 7.0)


func _ensure_action(action: String, keycode: Key) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not mouse_captured:
		mouse_captured = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and mouse_captured:
		cam_yaw = wrapf(cam_yaw - event.relative.x * MOUSE_SENSITIVITY, -PI, PI)
		cam_pitch = clampf(cam_pitch + event.relative.y * MOUSE_SENSITIVITY, CAMERA_PITCH_MIN, CAMERA_PITCH_MAX)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file(MENU_PATH)
	elif finished and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	if not finished:
		elapsed += delta
	_update_checkpoint()
	_move_player(delta)
	_update_climb_prompt()
	if unit_arrival_left > 0.0:
		unit_arrival_left -= delta
		if unit_arrival_left <= 0.0:
			_unit_emerges()
	else:
		_update_enemy(delta)
	_update_scan(delta)
	_update_camera(delta)
	_update_occluders(delta)
	_update_enemy_visuals()
	_update_hud(delta)
	if not finished and player.global_position.x >= EXIT_X:
		_finish()


# --- Continuity with Phase 1 ----------------------------------------------------------------------------

## The east service mouth Elena has just come out of: the end of the P-1 drainage gallery, now the parking entry.
## Built only when the scene starts from the Phase 1 handoff; the standalone corridor keeps its own layout.
func _build_service_mouth() -> void:
	_add_box(Vector3(0.6, 4.0, HALF_DEPTH - 1.5), Vector3(MOUTH_X - 0.3, 2.0, -(HALF_DEPTH + 1.5) * 0.5), WALL_COLOR, false)
	_add_box(Vector3(0.6, 4.0, HALF_DEPTH - 1.5), Vector3(MOUTH_X - 0.3, 2.0, (HALF_DEPTH + 1.5) * 0.5), WALL_COLOR, false)
	_add_box(Vector3(0.6, 1.6, 3.0), Vector3(MOUTH_X - 0.3, 3.2, 0.0), WALL_COLOR, false)
	_add_box(Vector3(3.4, 0.3, 3.0), Vector3(MOUTH_X - 2.0, -0.15, 0.0), FLOOR_COLOR, false)
	_add_box(Vector3(3.4, 0.3, 3.6), Vector3(MOUTH_X - 2.0, 2.55, 0.0), WALL_COLOR, false)
	_add_box(Vector3(3.4, 2.4, 0.3), Vector3(MOUTH_X - 2.0, 1.2, -1.65), WALL_COLOR, false)
	_add_box(Vector3(3.4, 2.4, 0.3), Vector3(MOUTH_X - 2.0, 1.2, 1.65), WALL_COLOR, false)
	_add_box(Vector3(0.3, 2.4, 3.0), Vector3(MOUTH_X - 3.7, 1.2, 0.0), WALL_COLOR, false)
	_add_sign("GALERÍA DE DESCARGA", Vector3(MOUTH_X + 0.1, 2.75, 0.0))
	# N2-03 (docs/narrative_complete.md): the facility response, readable without sound or a forced stop.
	_add_sign("PROTOCOLO DE CONTENCIÓN: ACTIVO\nSECTOR EXTERIOR", Vector3(MOUTH_X + 0.3, 2.2, -4.5))


## Phase 1 handed over mid-escape: Elena keeps her heading and momentum, and the unit is still behind her.
func _continue_pursuit() -> void:
	var v: Vector3 = handoff.get("velocity", Vector3.ZERO)
	player.velocity = Vector3(maxf(v.x, 0.0), 0.0, v.z)
	player_visual.rotation.y = float(handoff.get("facing", PI * 0.5))
	enemy.visible = false
	enemy.global_position = Vector3(MOUTH_X - 2.6, -20.0, 0.0)
	var gap: float = float(handoff.get("unit_gap", 12.0))
	unit_arrival_left = clampf(gap / ENEMY_CHASE_SPEED, 0.8, 4.0)


## The unit comes out of the same mouth already hunting: it heads for where it last had her (the mouth itself).
func _unit_emerges() -> void:
	enemy.global_position = Vector3(MOUTH_X - 2.6, 0.0, 0.0)
	enemy.velocity = Vector3.ZERO
	enemy.visible = true
	enemy_visual.rotation.y = PI * 0.5
	last_known = Vector3(MOUTH_X + 1.5, 0.0, 0.0)
	enemy_state = "chase"
	awareness = 1.0
	if enemy_alert_player != null:
		enemy_alert_player.play()


# --- Jugador ----------------------------------------------------------------------------------------

func _move_player(delta: float) -> void:
	if climbing or finished:
		player.velocity = Vector3.ZERO
		return
	var on_floor := player.is_on_floor()
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var cam_basis := player_camera.global_transform.basis
	var forward := -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := cam_basis.x
	right.y = 0.0
	right = right.normalized()
	var wish := right * input_vec.x + forward * -input_vec.y
	if wish.length() > 1.0:
		wish = wish.normalized()

	var wants_crouch := Input.is_action_pressed("crouch") and on_floor
	if wants_crouch and not crouching:
		_set_crouch(true)
	elif not wants_crouch and crouching and _can_stand():
		_set_crouch(false)

	running = Input.is_action_pressed("run") and not crouching and input_vec != Vector2.ZERO
	var speed := CROUCH_SPEED if crouching else (RUN_SPEED if running else WALK_SPEED)
	var horizontal := Vector3(player.velocity.x, 0.0, player.velocity.z)
	var rate := AIR_ACCEL if not on_floor else (GROUND_ACCEL if wish != Vector3.ZERO else GROUND_DECEL)
	horizontal = horizontal.move_toward(wish * speed, rate * delta)
	player.velocity.x = horizontal.x
	player.velocity.z = horizontal.z

	coyote_left = COYOTE_TIME if on_floor else maxf(0.0, coyote_left - delta)
	if Input.is_action_just_pressed("jump"):
		buffer_left = JUMP_BUFFER
	else:
		buffer_left = maxf(0.0, buffer_left - delta)
	if buffer_left > 0.0 and coyote_left > 0.0 and not crouching:
		player.velocity.y = JUMP_VELOCITY
		buffer_left = 0.0
		coyote_left = 0.0
	elif on_floor:
		player.velocity.y = -0.5
	else:
		player.velocity.y -= GRAVITY * delta

	if wish != Vector3.ZERO:
		var wanted := atan2(wish.x, wish.z)
		player_visual.rotation.y = lerp_angle(player_visual.rotation.y, wanted, clampf(12.0 * delta, 0.0, 1.0))
	player.move_and_slide()

	on_floor = player.is_on_floor()
	if on_floor and not was_on_floor:
		_play_sfx(land_stream, -6.0)
	was_on_floor = on_floor
	var flat_speed := Vector2(player.velocity.x, player.velocity.z).length()
	if on_floor and flat_speed > 1.0:
		step_distance += flat_speed * delta
		if step_distance >= STEP_LENGTH:
			step_distance = 0.0
			_play_step()
	if player.global_position.y < -8.0:
		_respawn("Has caído al vacío. Vuelves al último punto seguro.")


func _set_crouch(value: bool) -> void:
	crouching = value
	for child in player.get_children():
		var collision := child as CollisionShape3D
		if collision != null and collision.shape is CapsuleShape3D:
			var capsule := collision.shape as CapsuleShape3D
			capsule.height = CROUCH_HEIGHT if value else STAND_HEIGHT
			collision.position.y = capsule.height * 0.5
	player_visual.scale.y = 0.62 if value else 1.0


func _can_stand() -> bool:
	var from := player.global_position + Vector3(0.0, CROUCH_HEIGHT, 0.0)
	var to := player.global_position + Vector3(0.0, STAND_HEIGHT + 0.05, 0.0)
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.exclude = [player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func player_noise_radius() -> float:
	if not player.is_on_floor():
		return NOISE_WALK * 0.7
	var flat_speed := Vector2(player.velocity.x, player.velocity.z).length()
	if flat_speed < 0.5:
		return NOISE_STILL
	if crouching:
		return NOISE_CROUCH
	return NOISE_RUN if running else NOISE_WALK


func _respawn(text: String) -> void:
	if climb_tween != null:
		climb_tween.kill()
	climbing = false
	player.global_position = checkpoint_position
	player.velocity = Vector3.ZERO
	_show_message(text, 4.0)


func _update_checkpoint() -> void:
	if not player.is_on_floor():
		return
	for i in range(CHECKPOINTS.size() - 1, checkpoint_index, -1):
		var point: Vector3 = CHECKPOINTS[i]
		if player.global_position.x >= point.x - 0.5:
			checkpoint_index = i
			checkpoint_position = point
			_show_message("Punto seguro alcanzado.", 2.0)
			break


# --- Trepa ------------------------------------------------------------------------------------------

func _on_climb_entered(body: Node3D) -> void:
	if body == player:
		player_in_climb = true


func _on_climb_exited(body: Node3D) -> void:
	if body == player:
		player_in_climb = false


func _update_climb_prompt() -> void:
	prompt.text = "E: trepar" if player_in_climb and not climbing and not finished else ""
	if player_in_climb and Input.is_action_just_pressed("interact"):
		try_climb()


func try_climb() -> bool:
	if climbing or finished or not player_in_climb:
		return false
	climbing = true
	var start := player.global_position
	var up := Vector3(start.x, CLIMB_HEIGHT + 0.15, start.z)
	var top := Vector3(44.0, CLIMB_HEIGHT + 0.05, clampf(start.z, 4.0, 6.6))
	climb_tween = create_tween()
	climb_tween.tween_property(player, "global_position", up, 0.3)
	climb_tween.tween_property(player, "global_position", top, 0.25)
	climb_tween.tween_callback(_end_climb)
	return true


func _end_climb() -> void:
	climbing = false


# --- Camara y oclusion --------------------------------------------------------------------------------

func _camera_offset() -> Vector3:
	var local := Basis(Vector3.RIGHT, -cam_pitch) * Vector3(0.0, 0.0, CAMERA_DISTANCE)
	return Basis(Vector3.UP, cam_yaw) * local


func _update_camera(delta: float) -> void:
	var wanted := player.global_position + _camera_offset()
	player_camera.global_position = player_camera.global_position.lerp(wanted, 1.0 - exp(-10.0 * delta))
	player_camera.look_at(player.global_position + Vector3(0.0, 1.0, 0.0), Vector3.UP)


## Atenua los muros, techos y columnas que se interponen entre la camara y Elena.
func _update_occluders(delta: float) -> void:
	var hidden := {}
	var excluded: Array[RID] = [player.get_rid(), enemy.get_rid()]
	var from := player_camera.global_position
	var to := player.global_position + Vector3(0.0, 0.9, 0.0)
	var space := get_world_3d().direct_space_state
	for i in 3:
		var query := PhysicsRayQueryParameters3D.create(from, to, 1)
		query.exclude = excluded
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			break
		var collider = hit["collider"]
		if collider is CollisionObject3D:
			excluded.append((collider as CollisionObject3D).get_rid())
		if fade_bodies.has(collider):
			hidden[collider] = true
	for body in fade_bodies:
		var entry: Dictionary = fade_bodies[body]
		var target := OCCLUDED_ALPHA if hidden.has(body) else 1.0
		entry["alpha"] = move_toward(float(entry["alpha"]), target, FADE_SPEED * delta)
		var material: StandardMaterial3D = entry["material"]
		var color := material.albedo_color
		color.a = float(entry["alpha"])
		material.albedo_color = color


# --- Enemigo -----------------------------------------------------------------------------------------

func enemy_cone_contains(point: Vector3) -> bool:
	var forward := enemy_visual.global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.001:
		return false
	var to_point := point - enemy.global_position
	to_point.y = 0.0
	if to_point.length() < 0.001:
		return true
	return rad_to_deg(forward.normalized().angle_to(to_point.normalized())) <= DETECT_HALF_ANGLE


func _flat_distance_to_player() -> float:
	var to_player := player.global_position - enemy.global_position
	return Vector2(to_player.x, to_player.z).length()


func _vision_radius() -> float:
	return DETECT_RADIUS * (CROUCH_VISION_FACTOR if crouching else 1.0)


func _line_clear(from: Vector3, to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.exclude = [enemy.get_rid(), player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func can_enemy_see_player() -> bool:
	var distance := _flat_distance_to_player()
	if distance > _vision_radius():
		return false
	if absf(player.global_position.y - enemy.global_position.y) > 3.0:
		return false
	if distance > NEAR_SENSE and not enemy_cone_contains(player.global_position):
		return false
	var chest := 0.5 if crouching else 0.9
	return _line_clear(enemy.global_position + Vector3(0.0, 1.5, 0.0), player.global_position + Vector3(0.0, chest, 0.0))


func _enemy_hears_player() -> bool:
	return _flat_distance_to_player() < player_noise_radius()


func step_enemy(delta: float) -> void:
	_update_enemy(delta)


func _update_enemy(delta: float) -> void:
	var sees := can_enemy_see_player() if not finished else false
	var hears := _enemy_hears_player() if not finished else false
	match enemy_state:
		"patrol":
			_patrol(delta)
			_accumulate_awareness(delta, sees, hears)
		"return":
			if _steer_towards(patrol_points[enemy_target], ENEMY_PATROL_SPEED, delta):
				enemy_state = "patrol"
			_accumulate_awareness(delta, sees, hears)
		"investigate":
			if _steer_towards(last_known, ENEMY_INVESTIGATE_SPEED, delta):
				_begin_search()
			_accumulate_awareness(delta, sees, hears)
		"alert":
			_face_point(player.global_position, delta)
			_stop_enemy(delta)
			if sees:
				last_known = player.global_position
			alert_left -= delta
			if alert_left <= 0.0:
				enemy_state = "chase"
		"chase":
			if sees:
				last_known = player.global_position
			if _steer_towards(last_known, ENEMY_CHASE_SPEED, delta) and not sees:
				_begin_search()
		"search":
			_stop_enemy(delta)
			search_left -= delta
			enemy_visual.rotation.y = search_base_yaw + sin((SEARCH_TIME - search_left) * 1.8) * 1.3
			_accumulate_awareness(delta, sees, hears)
			if search_left <= 0.0 and enemy_state == "search":
				enemy_target = _nearest_patrol_index()
				enemy_state = "return"
	_check_catch()


func _accumulate_awareness(delta: float, sees: bool, hears: bool) -> void:
	if sees:
		var exposure := clampf(1.6 - _flat_distance_to_player() / _vision_radius(), 0.4, 1.6)
		awareness += delta * exposure / DETECT_TIME
		last_known = player.global_position
	elif hears:
		awareness += delta * 0.6 / DETECT_TIME
		last_known = player.global_position
	else:
		awareness = maxf(0.0, awareness - AWARENESS_DECAY * delta)
	if awareness >= 1.0:
		if sees:
			_begin_alert()
		else:
			awareness = 0.6
			enemy_state = "investigate"


func _begin_alert() -> void:
	enemy_state = "alert"
	alert_left = ALERT_TIME
	awareness = 1.0
	times_spotted += 1
	last_known = player.global_position
	enemy_alert_player.play()


func _begin_search() -> void:
	enemy_state = "search"
	search_left = SEARCH_TIME
	search_base_yaw = enemy_visual.rotation.y
	awareness = 0.0


func _nearest_patrol_index() -> int:
	var best := 0
	var best_distance := INF
	for i in patrol_points.size():
		var point: Vector3 = patrol_points[i]
		var distance := enemy.global_position.distance_to(point)
		if distance < best_distance:
			best_distance = distance
			best = i
	return best


func _patrol(delta: float) -> void:
	if patrol_wait_left > 0.0:
		patrol_wait_left -= delta
		_stop_enemy(delta)
		return
	if _steer_towards(patrol_points[enemy_target], ENEMY_PATROL_SPEED, delta):
		enemy_target = (enemy_target + 1) % patrol_points.size()
		patrol_wait_left = PATROL_WAIT


func _stop_enemy(delta: float) -> void:
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0
	_apply_enemy_gravity(delta)
	enemy.move_and_slide()


func _apply_enemy_gravity(delta: float) -> void:
	enemy.velocity.y = -0.5 if enemy.is_on_floor() else enemy.velocity.y - GRAVITY * delta


## Avanza hacia el objetivo esquivando columnas y sin caer a los huecos. Devuelve true al llegar o si no puede avanzar.
func _steer_towards(target: Vector3, speed: float, delta: float) -> bool:
	var to_target := target - enemy.global_position
	to_target.y = 0.0
	var distance := to_target.length()
	if distance < ARRIVE_DISTANCE:
		_stop_enemy(delta)
		return true
	var direction := _free_direction(to_target / distance)
	if direction == Vector3.ZERO or not _ground_ahead(direction):
		_stop_enemy(delta)
		return true
	enemy.velocity.x = direction.x * speed
	enemy.velocity.z = direction.z * speed
	_apply_enemy_gravity(delta)
	_face_direction(direction, delta)
	enemy.move_and_slide()
	return false


func _free_direction(direction: Vector3) -> Vector3:
	for angle in AVOID_ANGLES:
		var candidate := direction.rotated(Vector3.UP, deg_to_rad(float(angle)))
		if _probe_free(candidate):
			return candidate
	return Vector3.ZERO


func _probe_free(direction: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	for height in [0.9, 1.8]:
		var from := enemy.global_position + Vector3(0.0, float(height), 0.0)
		var query := PhysicsRayQueryParameters3D.create(from, from + direction * PROBE_LENGTH, 1)
		query.exclude = [enemy.get_rid()]
		if not space.intersect_ray(query).is_empty():
			return false
	return true


func _ground_ahead(direction: Vector3) -> bool:
	var from := enemy.global_position + direction * 0.9 + Vector3(0.0, 0.5, 0.0)
	var query := PhysicsRayQueryParameters3D.create(from, from + Vector3(0.0, -1.5, 0.0), 1)
	query.exclude = [enemy.get_rid()]
	return not get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _face_direction(direction: Vector3, delta: float) -> void:
	enemy_visual.rotation.y = lerp_angle(enemy_visual.rotation.y, atan2(direction.x, direction.z), clampf(8.0 * delta, 0.0, 1.0))


func _face_point(point: Vector3, delta: float) -> void:
	var direction := point - enemy.global_position
	direction.y = 0.0
	if direction.length() > 0.01:
		_face_direction(direction.normalized(), delta)


func _check_catch() -> void:
	if finished:
		return
	var to_player := player.global_position - enemy.global_position
	if Vector2(to_player.x, to_player.z).length() < CATCH_DISTANCE and absf(to_player.y) < CATCH_HEIGHT:
		catches += 1
		_play_sfx(denied_stream, -4.0)
		_respawn("La unidad de recuperación te ha alcanzado. Vuelves al último punto seguro.")
		_reset_enemy()


func _reset_enemy() -> void:
	enemy.global_position = patrol_points[0]
	enemy.velocity = Vector3.ZERO
	enemy_visual.rotation.y = 0.0
	enemy_state = "patrol"
	enemy_target = 1
	awareness = 0.0
	patrol_wait_left = 0.0


func _update_enemy_visuals() -> void:
	var color := AMBER
	var energy := 1.2
	var icon := ""
	match enemy_state:
		"patrol", "return":
			color = AMBER.lerp(DANGER, clampf(awareness, 0.0, 1.0))
			energy = 1.2 + awareness * 1.5
			icon = "?" if awareness > 0.15 else ""
		"investigate":
			color = AMBER.lerp(DANGER, 0.4)
			energy = 1.8
			icon = "?"
		"alert":
			color = DANGER
			energy = 4.0
			icon = "!"
		"chase":
			color = DANGER
			energy = 3.2
			icon = "!!"
		"search":
			var blink := 0.5 + 0.5 * sin(elapsed * 9.0)
			color = AMBER.lerp(DANGER, 0.3)
			energy = 1.0 + blink * 1.4
			icon = "?"
	enemy_eye_material.albedo_color = color
	enemy_eye_material.emission = color
	enemy_eye_material.emission_energy_multiplier = energy
	enemy_light.light_color = color
	enemy_light.light_energy = 0.4 + energy * 0.25
	enemy_icon.text = icon
	enemy_icon.modulate = color


# --- Escaner ------------------------------------------------------------------------------------------

func trigger_scan_reveal() -> void:
	scan_charge = 0.0
	scan_reveal_left = SCAN_REVEAL_TIME
	scan_cooldown_left = SCAN_COOLDOWN
	_play_sfx(scan_stream, -4.0)
	for marker in scan_markers:
		marker.visible = true


func _update_scan(delta: float) -> void:
	scan_cooldown_left = maxf(0.0, scan_cooldown_left - delta)
	if scan_reveal_left > 0.0:
		scan_reveal_left -= delta
		scan_enemy_marker.global_position = enemy.global_position + Vector3(0.0, 1.0, 0.0)
		if scan_reveal_left <= 0.0:
			for marker in scan_markers:
				marker.visible = false
		return
	if Input.is_action_pressed("scan") and scan_cooldown_left <= 0.0 and not finished:
		scan_charge += delta
		if scan_charge >= SCAN_CHARGE_TIME:
			trigger_scan_reveal()
	else:
		scan_charge = 0.0


# --- Final ---------------------------------------------------------------------------------------------

func _finish() -> void:
	finished = true
	_play_sfx(chime_stream, -4.0)
	_show_message("SALIDA ALCANZADA\nTiempo %s   |   Capturas: %d   |   Veces detectada: %d\nR: reiniciar   |   Esc: menú" % [_format_time(elapsed), catches, times_spotted], 600.0)


func _format_time(seconds: float) -> String:
	return "%d:%02d" % [floori(seconds / 60.0), int(seconds) % 60]


# --- Construccion --------------------------------------------------------------------------------------

func _build_level() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.36, 0.44)
	env.ambient_light_energy = 0.4
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	sun.light_energy = 0.6
	sun.light_color = Color(0.75, 0.85, 1.0)
	sun.shadow_enabled = true
	add_child(sun)

	for segment in FLOOR_SEGMENTS:
		var x0: float = segment[0]
		var x1: float = segment[1]
		_add_box(Vector3(x1 - x0, 0.5, HALF_DEPTH * 2.0), Vector3((x0 + x1) * 0.5, -0.25, 0.0), FLOOR_COLOR, false)

	_add_box(Vector3(84.0, 4.0, 0.6), Vector3(40.0, 2.0, -HALF_DEPTH - 0.3), WALL_COLOR, true)
	_add_box(Vector3(84.0, 4.0, 0.6), Vector3(40.0, 2.0, HALF_DEPTH + 0.3), WALL_COLOR, true)
	_add_box(Vector3(0.6, 4.0, HALF_DEPTH * 2.0 + 1.2), Vector3(-1.3, 2.0, 0.0), WALL_COLOR, true)
	_add_box(Vector3(0.6, 4.0, HALF_DEPTH * 2.0 + 1.2), Vector3(82.3, 2.0, 0.0), WALL_COLOR, true)

	var tunnel_width: float = float(TUNNEL_X[1]) - float(TUNNEL_X[0])
	tunnel_ceiling = _add_box(Vector3(tunnel_width, 0.35, HALF_DEPTH * 2.0), Vector3((float(TUNNEL_X[0]) + float(TUNNEL_X[1])) * 0.5, CEILING_BOTTOM + 0.175, 0.0), WALL_COLOR, true)

	var duct_width: float = float(DUCT_X[1]) - float(DUCT_X[0])
	var duct_center: float = (float(DUCT_X[0]) + float(DUCT_X[1])) * 0.5
	_add_box(Vector3(duct_width, CEILING_BOTTOM, 0.3), Vector3(duct_center, CEILING_BOTTOM * 0.5, -3.8), WALL_COLOR, true)
	_add_box(Vector3(duct_width, 0.35, 3.2), Vector3(duct_center, CEILING_BOTTOM + 0.175, -5.4), WALL_COLOR, true)

	# The second half reads as a service parking garage: marked bays, parked vehicles and concrete columns.
	for pillar in [Vector3(40.0, 1.5, 2.5), Vector3(46.0, 1.5, -2.5), Vector3(52.0, 1.5, 2.5), Vector3(57.0, 1.5, -2.5), Vector3(64.0, 1.5, 2.5), Vector3(72.0, 1.5, -2.5)]:
		_add_box(Vector3(1.2, 3.0, 1.2), pillar, WALL_COLOR, true)

	# Parked cars are solid cover, but their placement leaves a readable central escape lane.
	var car_paint := [Color(0.16, 0.21, 0.25), Color(0.31, 0.19, 0.15), Color(0.38, 0.39, 0.36), Color(0.12, 0.16, 0.19)]
	var bay_x := [38.0, 47.0, 56.0, 65.0, 74.0]
	for car_index in range(bay_x.size()):
		var car_x: float = float(bay_x[car_index])
		var car_z: float = -4.55 if car_index % 2 == 0 else 4.55
		var paint: Color = car_paint[car_index % car_paint.size()]
		_add_box(Vector3(3.8, 1.15, 1.65), Vector3(car_x, 0.72, car_z), paint, true)
		_add_box(Vector3(2.0, 0.48, 1.42), Vector3(car_x - 0.25, 1.45, car_z), paint.lightened(0.12), true)
		var tail_light := BoxMesh.new()
		tail_light.size = Vector3(0.65, 0.16, 0.05)
		_add_visual_mesh(self, tail_light, Vector3(car_x + 1.82, 0.72, car_z - 0.42), Color(0.72, 0.18, 0.12), 0.2)
		_add_visual_mesh(self, tail_light, Vector3(car_x + 1.82, 0.72, car_z + 0.42), Color(0.72, 0.18, 0.12), 0.2)
		# Parking-bay lane marks are visual-only meshes: they must not create collision lips.
		var bay_line := BoxMesh.new()
		bay_line.size = Vector3(0.08, 0.025, 3.2)
		_add_visual_mesh(self, bay_line, Vector3(car_x - 2.1, 0.015, car_z), Color(0.72, 0.68, 0.48), 0.0)
		_add_visual_mesh(self, bay_line, Vector3(car_x + 2.1, 0.015, car_z), Color(0.72, 0.68, 0.48), 0.0)

	_add_box(Vector3(6.0, 0.3, 3.4), Vector3(46.0, CLIMB_HEIGHT - 0.15, 5.3), FLOOR_COLOR, true)
	_add_box(Vector3(0.4, CLIMB_HEIGHT - 0.3, 0.4), Vector3(48.6, (CLIMB_HEIGHT - 0.3) * 0.5, 6.6), WALL_COLOR, true)
	climb_area = Area3D.new()
	climb_area.position = Vector3(42.2, 1.2, 5.3)
	climb_area.collision_layer = 0
	climb_area.collision_mask = 2
	var climb_shape := CollisionShape3D.new()
	var climb_box := BoxShape3D.new()
	climb_box.size = Vector3(2.0, 2.4, 3.0)
	climb_shape.shape = climb_box
	climb_area.add_child(climb_shape)
	climb_area.body_entered.connect(_on_climb_entered)
	climb_area.body_exited.connect(_on_climb_exited)
	add_child(climb_area)

	var exit_mesh := MeshInstance3D.new()
	var exit_box := BoxMesh.new()
	exit_box.size = Vector3(0.2, 3.0, HALF_DEPTH * 2.0)
	exit_mesh.mesh = exit_box
	exit_mesh.position = Vector3(80.0, 1.5, 0.0)
	exit_mesh.material_override = _emissive_material(SAFE_GREEN, 1.5)
	add_child(exit_mesh)

	for x in [8.0, 24.0, 46.0, 70.0]:
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(x, 3.4, 0.0)
		lamp.light_color = Color(0.75, 0.85, 1.0) if int(x) % 16 == 8 else Color(1.0, 0.85, 0.6)
		lamp.light_energy = 0.7
		lamp.omni_range = 14.0
		add_child(lamp)

	_add_sign("WASD mover  ·  Shift correr  ·  Espacio saltar", Vector3(4.0, 2.4, -2.0))
	_add_sign("Espacio: salta el hueco", Vector3(12.0, 2.4, 0.0))
	_add_sign("Ctrl: agáchate bajo el conducto", Vector3(18.0, 2.4, 0.0))
	_add_sign("Hueco largo: Shift + Espacio", Vector3(27.5, 2.4, 0.0))
	if parking_entry_mode:
		_add_sign("APARCAMIENTO · SERVICIO", Vector3(36.5, 2.6, 0.0))
	else:
		_add_sign("Unidad de recuperación. Q: escanear", Vector3(35.0, 3.0, 0.0))
	_add_sign("SALIDA", Vector3(80.0, 3.4, 0.0))


func _add_box(size: Vector3, pos: Vector3, color: Color, fade: bool) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = pos
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	if fade:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fade_bodies[body] = {"material": material, "alpha": 1.0}
	mesh.material_override = material
	body.add_child(mesh)
	add_child(body)
	return body


func _emissive_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func _add_sign(text: String, pos: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 40
	label.pixel_size = 0.008
	label.outline_size = 10
	label.modulate = Color(0.85, 0.92, 1.0)
	add_child(label)


func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Elena"
	player.collision_layer = 2
	player.collision_mask = 1
	player.position = checkpoint_position
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = STAND_HEIGHT
	shape.shape = capsule
	shape.position = Vector3(0.0, STAND_HEIGHT * 0.5, 0.0)
	player.add_child(shape)
	player_visual = Node3D.new()
	player.add_child(player_visual)
	add_child(player)
	if not _try_build_model():
		_build_primitive_player()
	player_camera = Camera3D.new()
	player_camera.fov = 55.0
	player_camera.current = true
	add_child(player_camera)
	player_camera.global_position = player.global_position + _camera_offset()


func _try_build_model() -> bool:
	if not ResourceLoader.exists(MODEL_PATH):
		return false
	var scene := load(MODEL_PATH) as PackedScene
	if scene == null:
		return false
	var model := scene.instantiate() as Node3D
	if model == null:
		return false
	model.name = "ElenaModel"
	player_visual.add_child(model)
	_dress_model(model)
	var glow := OmniLight3D.new()
	glow.light_color = CYAN
	glow.light_energy = 0.7
	glow.omni_range = 1.8
	glow.position = Vector3(-0.16, 1.1, 0.4)
	player_visual.add_child(glow)
	pose = PoseScript.new()
	pose.name = "ProceduralPose"
	player.add_child(pose)
	pose.setup(player, model)
	uses_model = true
	return true


func _dress_model(model: Node) -> void:
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface in mesh_instance.mesh.get_surface_count():
			var imported := mesh_instance.mesh.surface_get_material(surface)
			var material := _material_for(imported.resource_name if imported != null else "")
			if material != null:
				mesh_instance.set_surface_override_material(surface, material)


func _material_for(material_name: String) -> Material:
	if material_name == "":
		return null
	if material_cache.has(material_name):
		return material_cache[material_name]
	var path := MATERIAL_DIR + material_name + ".tres"
	var material: Material = null
	if ResourceLoader.exists(path):
		material = load(path) as Material
	material_cache[material_name] = material
	return material


func _build_primitive_player() -> void:
	var body := CapsuleMesh.new()
	body.radius = 0.27
	body.height = 1.1
	_add_visual_mesh(player_visual, body, Vector3(0.0, 1.05, 0.0), Color(0.05, 0.24, 0.32), 0.0)
	var head := SphereMesh.new()
	head.radius = 0.17
	head.height = 0.34
	_add_visual_mesh(player_visual, head, Vector3(0.0, 1.72, 0.0), Color(0.8, 0.62, 0.52), 0.0)
	var aster := SphereMesh.new()
	aster.radius = 0.06
	aster.height = 0.12
	_add_visual_mesh(player_visual, aster, Vector3(0.0, 1.25, 0.27), CYAN, 2.5)


func _add_visual_mesh(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, emission: float) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _emissive_material(color, emission) if emission > 0.0 else _plain_material(color)
	instance.position = pos
	parent.add_child(instance)
	return instance


func _plain_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	return material


func _build_enemy() -> void:
	enemy = CharacterBody3D.new()
	enemy.name = "RecoveryUnit"
	enemy.collision_layer = 4
	enemy.collision_mask = 1
	enemy.position = patrol_points[0]
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = ENEMY_HEIGHT
	shape.shape = capsule
	shape.position = Vector3(0.0, ENEMY_HEIGHT * 0.5, 0.0)
	enemy.add_child(shape)
	enemy_visual = Node3D.new()
	enemy.add_child(enemy_visual)
	var body := CapsuleMesh.new()
	body.radius = 0.4
	body.height = 1.6
	_add_visual_mesh(enemy_visual, body, Vector3(0.0, 1.1, 0.0), Color(0.3, 0.12, 0.1), 0.0)
	var eye := SphereMesh.new()
	eye.radius = 0.12
	eye.height = 0.24
	var eye_instance := _add_visual_mesh(enemy_visual, eye, Vector3(0.0, 1.5, 0.35), AMBER, 1.2)
	enemy_eye_material = eye_instance.material_override as StandardMaterial3D
	enemy_light = OmniLight3D.new()
	enemy_light.light_color = AMBER
	enemy_light.omni_range = 5.0
	enemy_light.position = Vector3(0.0, 1.5, 0.4)
	enemy_visual.add_child(enemy_light)
	enemy_icon = Label3D.new()
	enemy_icon.position = Vector3(0.0, 2.6, 0.0)
	enemy_icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	enemy_icon.no_depth_test = true
	enemy_icon.font_size = 96
	enemy_icon.pixel_size = 0.01
	enemy_icon.outline_size = 14
	enemy.add_child(enemy_icon)
	add_child(enemy)


func _build_scan_markers() -> void:
	for point in patrol_points:
		scan_markers.append(_make_marker(Vector3(point.x, 0.35, point.z), CYAN, 0.16))
	scan_enemy_marker = _make_marker(Vector3.ZERO, DANGER, 0.28)
	scan_markers.append(scan_enemy_marker)
	var cone := _make_cone()
	enemy_visual.add_child(cone)
	scan_markers.append(cone)
	scan_markers.append(_make_scan_label("Trepa: la unidad no sube", Vector3(42.2, 2.9, 5.3)))
	scan_markers.append(_make_scan_label("Conducto bajo: la unidad no cabe", Vector3(41.0, 1.9, -5.4)))
	scan_markers.append(_make_scan_label("Salto largo: la unidad no cruza", Vector3(61.0, 1.9, 0.0)))


func _make_marker(pos: Vector3, color: Color, radius: float) -> MeshInstance3D:
	var marker := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	marker.mesh = sphere
	marker.position = pos
	marker.visible = false
	var material := _emissive_material(color, 2.0)
	material.no_depth_test = true
	marker.material_override = material
	add_child(marker)
	return marker


func _make_scan_label(text: String, pos: Vector3) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 40
	label.pixel_size = 0.008
	label.outline_size = 10
	label.modulate = CYAN
	label.visible = false
	add_child(label)
	return label


func _make_cone() -> MeshInstance3D:
	var vertices := PackedVector3Array()
	var steps := 14
	var half := deg_to_rad(DETECT_HALF_ANGLE)
	var previous := Vector3(sin(-half), 0.0, cos(-half)) * DETECT_RADIUS
	for i in range(1, steps + 1):
		var angle := -half + (2.0 * half) * float(i) / float(steps)
		var current := Vector3(sin(angle), 0.0, cos(angle)) * DETECT_RADIUS
		vertices.append(Vector3.ZERO)
		vertices.append(previous)
		vertices.append(current)
		previous = current
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(DANGER.r, DANGER.g, DANGER.b, 0.22)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = true
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = Vector3(0.0, 0.08, 0.0)
	instance.visible = false
	return instance


func _build_audio() -> void:
	for variant in 3:
		step_streams.append(SfxSynth.footstep(variant))
	land_stream = SfxSynth.land()
	scan_stream = SfxSynth.scan_pulse()
	denied_stream = SfxSynth.denied()
	chime_stream = SfxSynth.complete_chime()
	step_player = AudioStreamPlayer.new()
	add_child(step_player)
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	var alert_stream := SfxSynth.alarm_pip()
	alert_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	enemy_alert_player = AudioStreamPlayer3D.new()
	enemy_alert_player.stream = alert_stream
	enemy_alert_player.unit_size = 8.0
	enemy.add_child(enemy_alert_player)


func _play_step() -> void:
	step_player.stream = step_streams[step_index % step_streams.size()]
	step_player.volume_db = -14.0 if crouching else (-3.0 if running else -8.0)
	step_player.play()
	step_index += 1


func _play_sfx(stream: AudioStream, volume_db: float) -> void:
	if stream == null:
		return
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	hud = Label.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 16)
	hud.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hud.add_theme_font_size_override("font_size", 15)
	hud.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	hud.add_theme_constant_override("outline_size", 6)
	layer.add_child(hud)
	message = Label.new()
	message.custom_minimum_size = Vector2(900.0, 0.0)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 40)
	message.add_theme_font_size_override("font_size", 22)
	message.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	message.add_theme_constant_override("outline_size", 8)
	layer.add_child(message)
	prompt = Label.new()
	prompt.custom_minimum_size = Vector2(300.0, 0.0)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 110)
	prompt.add_theme_font_size_override("font_size", 24)
	prompt.add_theme_color_override("font_color", AMBER)
	prompt.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	prompt.add_theme_constant_override("outline_size", 8)
	layer.add_child(prompt)


func _show_message(text: String, seconds: float) -> void:
	message.text = text
	message_left = seconds


func _update_hud(delta: float) -> void:
	if message_left > 0.0:
		message_left -= delta
		if message_left <= 0.0:
			message.text = ""
	var scan_line := "listo"
	if scan_reveal_left > 0.0:
		scan_line = "activo %.1f s" % scan_reveal_left
	elif scan_charge > 0.0:
		scan_line = "escaneando %d%%" % int(scan_charge / SCAN_CHARGE_TIME * 100.0)
	elif scan_cooldown_left > 0.0:
		scan_line = "recarga %.1f s" % scan_cooldown_left
	var noise := player_noise_radius()
	var noise_line := "bajo" if noise < 3.0 else ("medio" if noise < 7.0 else "alto")
	hud.text = "WASD mover · Ratón cámara · Espacio saltar · Shift correr · Ctrl agacharse · E trepar · Q escáner\nEscáner: %s   |   Ruido: %s   |   Unidad: %s   |   Capturas: %d   |   Tiempo: %s" % [scan_line, noise_line, STATE_NAMES.get(enemy_state, enemy_state), catches, _format_time(elapsed)]
