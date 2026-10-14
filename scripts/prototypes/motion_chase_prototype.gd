extends Node3D
## Prototipo del hito A: movimiento 3D, obstaculos y persecucion.
## Escena aislada para validar la direccion de infiltracion y huida.
## No modifica el laboratorio, el arte, el guardado ni los contratos de Fase 0.
## Ejecutar: godot --path . res://scenes/prototypes/motion_chase_prototype.tscn
##
## Controles: raton para girar la camara (clic para capturar), WASD mover,
## Shift correr, Ctrl agacharse, Espacio saltar, E trepar, Q mantener el escaner.

const WallColor := Color(0.16, 0.19, 0.23)
const FloorColor := Color(0.11, 0.13, 0.16)
const SafeColor := Color(0.3, 0.95, 0.9)
const DangerColor := Color(0.95, 0.35, 0.2)

const WalkSpeed := 4.2
const RunSpeed := 6.8
const CrouchSpeed := 2.2
const Acceleration := 18.0
const Gravity := 22.0
const JumpVelocity := 6.2
const CameraDistance := 7.5
const CameraHeight := 4.2
const MouseSensitivity := 0.0022

const EnemyWalkSpeed := 2.2
const EnemyChaseSpeed := 5.4
const DetectRadius := 9.0
const DetectHalfAngle := 55.0
const LoseSightTime := 2.0
const SearchTime := 3.0
const CatchDistance := 1.3

const ScanChargeTime := 0.9
const ScanRevealTime := 3.0
const ScanCooldown := 4.0

var player: CharacterBody3D
var player_visual: Node3D
var player_camera: Camera3D
var enemy: CharacterBody3D
var enemy_visual: Node3D
var climb_points: Array = []
var scan_markers: Array = []
var hud: Label
var message: Label

var cam_yaw: float = 0.0
var mouse_captured: bool = false
var crouching: bool = false
var scan_charge: float = 0.0
var scan_reveal_left: float = 0.0
var scan_cooldown_left: float = 0.0

var enemy_state: String = "patrol"
var enemy_target: int = 0
var lose_sight_left: float = 0.0
var search_left: float = 0.0
var patrol_points: Array = [Vector3(50.0, 0.0, -3.0), Vector3(64.0, 0.0, 3.0)]

var checkpoint := Vector3(1.0, 0.2, 0.0)
var catches: int = 0


func _ready() -> void:
	_build_level()
	_build_player()
	_build_enemy()
	_build_scan_markers()
	_build_ui()
	InputMap_add_crouch()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not mouse_captured:
		mouse_captured = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and mouse_captured:
		cam_yaw = wrapf(cam_yaw - event.relative.x * MouseSensitivity, -PI, PI)


func _physics_process(delta: float) -> void:
	_move_player(delta)
	_update_enemy(delta)
	_update_scan(delta)
	_update_camera(delta)
	_update_hud()


func _move_player(delta: float) -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var cam_basis := player_camera.global_transform.basis
	var forward := -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := cam_basis.x
	right.y = 0.0
	right = right.normalized()
	var wish := (right * input_vec.x + forward * -input_vec.y)
	if wish.length() > 1.0:
		wish = wish.normalized()

	var wants_crouch := Input.is_action_pressed("crouch") and player.is_on_floor()
	if wants_crouch != crouching:
		_set_crouch(wants_crouch)

	var speed := CrouchSpeed if crouching else (RunSpeed if Input.is_action_pressed("dodge") else WalkSpeed)
	var target := wish * speed
	var horizontal := Vector3(player.velocity.x, 0.0, player.velocity.z)
	horizontal = horizontal.move_toward(target, Acceleration * delta)
	player.velocity.x = horizontal.x
	player.velocity.z = horizontal.z

	if player.is_on_floor():
		player.velocity.y = -0.5
		if Input.is_action_just_pressed("jump") and not crouching:
			player.velocity.y = JumpVelocity
	else:
		player.velocity.y -= Gravity * delta

	if wish != Vector3.ZERO:
		var wanted := atan2(wish.x, wish.z)
		player_visual.rotation.y = lerp_angle(player_visual.rotation.y, wanted, clampf(12.0 * delta, 0.0, 1.0))
	player.move_and_slide()

	if player.global_position.y < -8.0:
		_respawn()


func _set_crouch(value: bool) -> void:
	crouching = value
	var shape: CollisionShape3D = null
	for child in player.get_children():
		if child is CollisionShape3D:
			shape = child
	if shape != null and shape.shape is CapsuleShape3D:
		var capsule := shape.shape as CapsuleShape3D
		capsule.height = 1.0 if crouching else 1.7
		shape.position.y = 0.5 if crouching else 0.85
	player_visual.scale.y = 0.62 if crouching else 1.0


func _update_camera(delta: float) -> void:
	var offset := Vector3(0.0, CameraHeight, CameraDistance).rotated(Vector3.UP, cam_yaw)
	var wanted := player.global_position + offset
	player_camera.global_position = player_camera.global_position.lerp(wanted, 1.0 - exp(-10.0 * delta))
	player_camera.look_at(player.global_position + Vector3(0.0, 1.0, 0.0), Vector3.UP)


func _update_enemy(delta: float) -> void:
	var to_player := player.global_position - enemy.global_position
	var distance := Vector3(to_player.x, 0.0, to_player.z).length()
	var can_see := _enemy_sees_player(distance)
	match enemy_state:
		"patrol":
			_patrol(delta)
			if can_see:
				enemy_state = "chase"
				lose_sight_left = LoseSightTime
		"chase":
			_steer_towards(player.global_position, EnemyChaseSpeed, delta)
			if can_see:
				lose_sight_left = LoseSightTime
			else:
				lose_sight_left -= delta
				if lose_sight_left <= 0.0:
					enemy_state = "search"
					search_left = SearchTime
		"search":
			search_left -= delta
			enemy_visual.rotation.y += 2.2 * delta
			if search_left <= 0.0:
				enemy_state = "return"
		"return":
			if _steer_towards(patrol_points[enemy_target], EnemyWalkSpeed, delta):
				enemy_state = "patrol"
	if distance < CatchDistance:
		catches += 1
		_respawn()
		_reset_enemy()


func _patrol(delta: float) -> void:
	if _steer_towards(patrol_points[enemy_target], EnemyWalkSpeed, delta):
		enemy_target = 1 - enemy_target


func _steer_towards(target: Vector3, speed: float, delta: float) -> bool:
	var to_target := target - enemy.global_position
	to_target.y = 0.0
	if to_target.length() < 0.4:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		enemy.move_and_slide()
		return true
	var direction := to_target.normalized()
	enemy.velocity.x = direction.x * speed
	enemy.velocity.z = direction.z * speed
	enemy.velocity.y = -0.5 if enemy.is_on_floor() else enemy.velocity.y - Gravity * delta
	enemy_visual.rotation.y = lerp_angle(enemy_visual.rotation.y, atan2(direction.x, direction.z), clampf(8.0 * delta, 0.0, 1.0))
	enemy.move_and_slide()
	return false


func _enemy_sees_player(distance: float) -> bool:
	if distance > DetectRadius:
		return false
	var forward := -enemy_visual.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var to_player := player.global_position - enemy.global_position
	to_player.y = 0.0
	if to_player.length() < 0.01:
		return true
	to_player = to_player.normalized()
	if rad_to_deg(forward.angle_to(to_player)) > DetectHalfAngle:
		return false
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(enemy.global_position + Vector3(0.0, 1.2, 0.0), player.global_position + Vector3(0.0, 1.0, 0.0))
	query.exclude = [enemy.get_rid(), player.get_rid()]
	var hit := space.intersect_ray(query)
	return hit.is_empty()


func _update_scan(delta: float) -> void:
	scan_cooldown_left = maxf(0.0, scan_cooldown_left - delta)
	if scan_reveal_left > 0.0:
		scan_reveal_left -= delta
		if scan_reveal_left <= 0.0:
			for marker in scan_markers:
				marker.visible = false
			return
	if Input.is_action_pressed("scan") and scan_cooldown_left <= 0.0:
		scan_charge += delta
		if scan_charge >= ScanChargeTime:
			scan_charge = 0.0
			scan_reveal_left = ScanRevealTime
			scan_cooldown_left = ScanCooldown
			for marker in scan_markers:
				marker.visible = true
	else:
		scan_charge = 0.0


func _respawn() -> void:
	player.global_position = checkpoint
	player.velocity = Vector3.ZERO
	message.text = "Te ha alcanzado la unidad de recuperacion. Vuelves al ultimo punto seguro."


func _reset_enemy() -> void:
	enemy.global_position = patrol_points[0]
	enemy.velocity = Vector3.ZERO
	enemy_state = "patrol"
	enemy_target = 0


func _update_hud() -> void:
	var scan_line := "Escaner listo" if scan_cooldown_left <= 0.0 else "Escaner: %.1f s" % scan_cooldown_left
	if scan_reveal_left > 0.0:
		scan_line = "Escaner activo: %.1f s" % scan_reveal_left
	elif scan_charge > 0.0:
		scan_line = "Escaneando... %.0f%%" % (scan_charge / ScanChargeTime * 100.0)
	var state_line := "Unidad: %s" % enemy_state
	message.text = "" if catches == 0 else message.text
	hud.text = "Mover: WASD | Correr: Shift | Agacharse: Ctrl | Saltar: Espacio | Trepar: E | Escaner: Q\n%s   |   %s   |   Capturas: %d" % [scan_line, state_line, catches]


func _build_level() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.36, 0.44)
	env.ambient_light_energy = 0.35
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	sun.light_energy = 0.7
	sun.light_color = Color(0.75, 0.85, 1.0)
	sun.shadow_enabled = true
	add_child(sun)

	_add_box(Vector3(16.0, 0.5, 14.0), Vector3(7.0, -0.25, 0.0), FloorColor)
	_add_box(Vector3(17.0, 0.5, 14.0), Vector3(23.5, -0.25, 0.0), FloorColor)
	_add_box(Vector3(22.0, 0.5, 14.0), Vector3(47.0, -0.25, 0.0), FloorColor)
	_add_box(Vector3(26.0, 0.5, 14.0), Vector3(73.0, -0.25, 0.0), FloorColor)

	_add_box(Vector3(0.6, 4.0, 78.0), Vector3(39.0, 2.0, -7.0), WallColor)
	_add_box(Vector3(0.6, 4.0, 78.0), Vector3(39.0, 2.0, 7.0), WallColor)
	_add_box(Vector3(78.0, 4.0, 0.6), Vector3(39.0, 2.0, -7.0), WallColor)
	_add_box(Vector3(78.0, 4.0, 0.6), Vector3(39.0, 2.0, 7.0), WallColor)

	_add_box(Vector3(6.0, 1.1, 14.0), Vector3(33.0, 2.15, 0.0), WallColor)
	_add_box(Vector3(6.0, 1.1, 14.0), Vector3(33.0, 2.15, 0.0), WallColor)

	_add_box(Vector3(2.0, 2.4, 6.0), Vector3(41.0, 1.2, -4.0), WallColor)
	_add_climb_point(Vector3(42.0, 1.4, -4.0), Vector3(42.0, 2.5, -4.0))
	_add_box(Vector3(8.0, 0.4, 6.0), Vector3(46.0, 2.3, -4.0), FloorColor)
	_add_box(Vector3(2.0, 2.4, 6.0), Vector3(51.0, 1.2, -4.0), WallColor)

	for pillar_x in [54.0, 60.0, 66.0]:
		_add_box(Vector3(1.2, 3.0, 1.2), Vector3(pillar_x, 1.5, -2.0), WallColor)
		_add_box(Vector3(1.2, 3.0, 1.2), Vector3(pillar_x, 1.5, 2.0), WallColor)

	_add_box(Vector3(0.6, 4.0, 14.0), Vector3(72.0, 2.0, 0.0), Color(0.4, 0.55, 0.65))
	_add_box(Vector3(0.2, 3.0, 3.0), Vector3(71.5, 1.5, 0.0), SafeColor)


func _add_box(size: Vector3, pos: Vector3, color: Color) -> void:
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
	mesh.material_override = material
	body.add_child(mesh)
	add_child(body)


func _add_climb_point(pos: Vector3, top: Vector3) -> void:
	var area := Area3D.new()
	area.position = pos
	area.set_meta("climb_target", top)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.0, 2.4, 2.0)
	shape.shape = box
	area.add_child(shape)
	area.body_entered.connect(_on_climb_area_entered)
	add_child(area)
	climb_points.append(area)


func _on_climb_area_entered(body: Node3D) -> void:
	if body != player:
		return
	if not Input.is_action_pressed("interact"):
		return
	var target: Vector3 = area_target(body)
	if target != Vector3.ZERO:
		player.global_position = target + Vector3(0.0, 0.2, 0.0)
		player.velocity = Vector3.ZERO


func area_target(area: Area3D) -> Vector3:
	return area.get_meta("climb_target", Vector3.ZERO)


func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Elena"
	player.collision_layer = 2
	player.collision_mask = 1
	player.position = checkpoint
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.7
	shape.shape = capsule
	shape.position = Vector3(0.0, 0.85, 0.0)
	player.add_child(shape)
	player_visual = Node3D.new()
	player.add_child(player_visual)
	var body := CapsuleMesh.new()
	body.radius = 0.27
	body.height = 1.1
	_add_player_mesh(body, Vector3(0.0, 1.05, 0.0), Color(0.05, 0.24, 0.32))
	var head := SphereMesh.new()
	head.radius = 0.17
	head.height = 0.34
	_add_player_mesh(head, Vector3(0.0, 1.72, 0.0), Color(0.8, 0.62, 0.52))
	var aster := SphereMesh.new()
	aster.radius = 0.06
	aster.height = 0.12
	_add_player_mesh(aster, Vector3(0.0, 1.25, 0.27), SafeColor, 2.5)
	add_child(player)
	player_camera = Camera3D.new()
	player_camera.fov = 55.0
	player_camera.current = true
	add_child(player_camera)
	player_camera.global_position = player.global_position + Vector3(0.0, CameraHeight, CameraDistance)


func _add_player_mesh(mesh: Mesh, pos: Vector3, color: Color, emission: float = 0.0) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	if emission > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission
	instance.material_override = material
	instance.position = pos
	player_visual.add_child(instance)


func _build_enemy() -> void:
	enemy = CharacterBody3D.new()
	enemy.name = "RecoveryUnit"
	enemy.collision_layer = 4
	enemy.collision_mask = 1
	enemy.position = patrol_points[0]
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 2.0
	shape.shape = capsule
	shape.position = Vector3(0.0, 1.0, 0.0)
	enemy.add_child(shape)
	enemy_visual = Node3D.new()
	enemy.add_child(enemy_visual)
	var body := CapsuleMesh.new()
	body.radius = 0.4
	body.height = 1.6
	_add_enemy_mesh(body, Vector3(0.0, 1.1, 0.0), Color(0.35, 0.12, 0.1))
	var eye := SphereMesh.new()
	eye.radius = 0.12
	eye.height = 0.24
	_add_enemy_mesh(eye, Vector3(0.0, 1.5, 0.35), DangerColor, 2.0)
	var light := OmniLight3D.new()
	light.light_color = DangerColor
	light.light_energy = 0.8
	light.omni_range = 5.0
	light.position = Vector3(0.0, 1.5, 0.4)
	enemy_visual.add_child(light)
	add_child(enemy)


func _add_enemy_mesh(mesh: Mesh, pos: Vector3, color: Color, emission: float = 0.0) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if emission > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission
	instance.material_override = material
	instance.position = pos
	enemy_visual.add_child(instance)


func _build_scan_markers() -> void:
	var route := [Vector3(50.0, 0.3, -3.0), Vector3(57.0, 0.3, 0.0), Vector3(64.0, 0.3, 3.0), Vector3(68.0, 0.3, 0.0)]
	for pos in route:
		var marker := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.18
		sphere.height = 0.36
		marker.mesh = sphere
		marker.position = pos
		marker.visible = false
		var material := StandardMaterial3D.new()
		material.albedo_color = SafeColor
		material.emission_enabled = true
		material.emission = SafeColor
		material.emission_energy_multiplier = 2.0
		marker.material_override = material
		add_child(marker)
		scan_markers.append(marker)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	hud = Label.new()
	hud.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hud.position = Vector2(16.0, -80.0)
	hud.add_theme_font_size_override("font_size", 16)
	layer.add_child(hud)
	message = Label.new()
	message.set_anchors_preset(Control.PRESET_CENTER)
	message.add_theme_font_size_override("font_size", 22)
	layer.add_child(message)


func InputMap_add_crouch() -> void:
	if not InputMap.has_action("crouch"):
		InputMap.add_action("crouch")
	var event := InputEventKey.new()
	event.physical_keycode = KEY_CTRL
	InputMap.action_add_event("crouch", event)
