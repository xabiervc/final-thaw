extends Node3D
## Mision 1 - El protocolo fantasma: investigacion y puzle de deduccion.
## Escena aislada. No modifica el laboratorio, el arte, el guardado ni los contratos de Fase 0.
## Ejecutar: godot --path . res://scenes/prototypes/mission1_ghost_protocol.tscn
## Controles: raton camara (clic para capturar), WASD mover, Shift correr, Ctrl agacharse,
## Espacio saltar, E interactuar, Q mantener para escanear, R reiniciar al terminar, Esc menu.

const SfxSynth = preload("res://scripts/audio/sfx_synth.gd")
const PoseScript = preload("res://scripts/characters/elena_procedural_pose.gd")

const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const MODEL_PATH := "res://assets/models/lab_ref/ref_elena_mpfb.glb"
const MATERIAL_DIR := "res://assets/materials/lab_ref/"

const WALK_SPEED := 4.2
const RUN_SPEED := 6.8
const CROUCH_SPEED := 2.2
const ACCEL := 18.0
const DECEL := 22.0
const GRAVITY := 22.0
const JUMP_VELOCITY := 6.2
const CAMERA_DISTANCE := 7.5
const CAMERA_PITCH := 0.5
const MOUSE_SENSITIVITY := 0.0022
const SCAN_CHARGE := 0.9
const SCAN_REVEAL := 3.0
const SCAN_COOLDOWN := 4.0
const INTERACT_RANGE := 2.2

var player: CharacterBody3D
var player_visual: Node3D
var player_camera: Camera3D
var pose = null
var uses_model: bool = false
var cam_yaw: float = 0.0
var cam_pitch: float = 0.5
var mouse_captured: bool = false
var crouching: bool = false
var coyote_left: float = 0.0
var buffer_left: float = 0.0
var was_on_floor: bool = true

var panel: Node3D
var cut_cable: Node3D
var terminal: Node3D
var junction: Node3D
var lever: Node3D
var exit_door: Node3D
var scan_highlights: Array = []
var scan_reveal_left: float = 0.0
var scan_cooldown_left: float = 0.0
var scan_charge: float = 0.0
var sfx_player: AudioStreamPlayer
var scan_stream: AudioStream
var denied_stream: AudioStream
var power_stream: AudioStream
var door_stream: AudioStream
var chime_stream: AudioStream
var hud: Label
var prompt: Label
var message: Label

var b_connected: bool = false
var power_on: bool = false
var record_read: bool = false
var finished: bool = false
var elapsed: float = 0.0
var message_left: float = 0.0
var current_target: Node3D = null


func _ready() -> void:
	_ensure_action("crouch", KEY_CTRL)
	_ensure_action("run", KEY_SHIFT)
	_build_level()
	_build_player()
	_build_audio()
	_build_ui()
	_update_camera(100.0)
	_show_message("La energia esta cortada y la salida bloqueada. Algo altero el circuito.", 6.0)


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
		cam_pitch = clampf(cam_pitch + event.relative.y * MOUSE_SENSITIVITY, 0.2, 1.15)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file(MENU_PATH)
	elif finished and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	if not finished:
		elapsed += delta
	_move_player(delta)
	_update_target()
	_update_scan(delta)
	_update_camera(delta)
	_update_hud(delta)


func _move_player(delta: float) -> void:
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
	if wants_crouch != crouching:
		crouching = wants_crouch
		player_visual.scale.y = 0.85 if crouching else 1.0
	var running := Input.is_action_pressed("run") and not crouching and input_vec != Vector2.ZERO
	var speed := CROUCH_SPEED if crouching else (RUN_SPEED if running else WALK_SPEED)
	var horizontal := Vector3(player.velocity.x, 0.0, player.velocity.z)
	var rate := ACCEL if wish != Vector3.ZERO else DECEL
	horizontal = horizontal.move_toward(wish * speed, rate * delta)
	player.velocity.x = horizontal.x
	player.velocity.z = horizontal.z
	coyote_left = 0.1 if on_floor else maxf(0.0, coyote_left - delta)
	if Input.is_action_just_pressed("jump"):
		buffer_left = 0.1
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
	if player.global_position.y < -8.0:
		player.global_position = Vector3(2.0, 0.2, 0.0)
		player.velocity = Vector3.ZERO


func _update_target() -> void:
	current_target = null
	var best := INTERACT_RANGE
	for node in [cut_cable, terminal, junction, lever, exit_door]:
		var distance := player.global_position.distance_to(node.global_position)
		if distance < best:
			best = distance
			current_target = node
	prompt.text = ""
	if current_target == null or finished:
		return
	if current_target == cut_cable:
		prompt.text = "E: examinar cable cortado"
	elif current_target == terminal:
		prompt.text = "E: consultar terminal"
	elif current_target == junction:
		prompt.text = "E: reconectar derivacion" if not b_connected else "E: revisar union"
	elif current_target == lever:
		prompt.text = "E: restaurar energia"
	elif current_target == exit_door:
		prompt.text = "E: abrir compuerta" if power_on and b_connected else ""
	if prompt.text != "" and Input.is_action_just_pressed("interact"):
		_interact(current_target)


func _interact(target: Node3D) -> void:
	if target == cut_cable:
		_show_message("El cable B fue cortado y derivado hacia el terminal de registro.", 5.0)
		record_read = true
		_play(denied_stream, -8.0)
	elif target == terminal:
		if power_on and b_connected:
			_finish()
		elif power_on:
			_show_message("El terminal recibe energia de B, pero el circuito es inconsistente.", 5.0)
			_play(denied_stream, -8.0)
		else:
			_show_message("Sin energia. El terminal no responde.", 4.0)
			_play(denied_stream, -10.0)
	elif target == junction:
		if b_connected:
			_show_message("La derivacion ya esta reconectada.", 3.0)
		else:
			b_connected = true
			_show_message("Has reconectado la derivacion. El circuito B vuelve a su ruta.", 5.0)
			_play(scan_stream, -6.0)
	elif target == lever:
		if power_on:
			_show_message("La energia ya esta restaurada.", 3.0)
		elif b_connected:
			power_on = true
			_play(power_stream, -4.0)
			_show_message("Energia restaurada. La compuerta se desbloquea.", 5.0)
			exit_door.set_meta("open", true)
		else:
			power_on = true
			_play(power_stream, -4.0)
			_show_message("Las luces vuelven, pero la compuerta sigue bloqueada: el circuito es inconsistente.", 6.0)
	elif target == exit_door:
		if power_on and b_connected:
			_finish()
		else:
			_show_message("La compuerta esta bloqueada.", 4.0)
			_play(denied_stream, -8.0)


func _finish() -> void:
	if finished:
		return
	finished = true
	_play(chime_stream, -4.0)
	_show_message("REGISTRO COMPLETADO\nPrueba del Aster desviada. Resultado oculto. Recomendacion de despliegue suprimida.\nEl sistema de contencion se activa.\n\nR: reiniciar   |   Esc: menu", 600.0)


func _update_scan(delta: float) -> void:
	scan_cooldown_left = maxf(0.0, scan_cooldown_left - delta)
	if scan_reveal_left > 0.0:
		scan_reveal_left -= delta
		if scan_reveal_left <= 0.0:
			for highlight in scan_highlights:
				highlight.visible = false
		return
	if Input.is_action_pressed("scan") and scan_cooldown_left <= 0.0 and not finished:
		scan_charge += delta
		if scan_charge >= SCAN_CHARGE:
			scan_charge = 0.0
			scan_reveal_left = SCAN_REVEAL
			scan_cooldown_left = SCAN_COOLDOWN
			_play(scan_stream, -6.0)
			for highlight in scan_highlights:
				highlight.visible = true
	else:
		scan_charge = 0.0


func _update_camera(delta: float) -> void:
	var offset := Basis(Vector3.UP, cam_yaw) * (Basis(Vector3.RIGHT, -cam_pitch) * Vector3(0.0, 0.0, 7.5))
	var wanted := player.global_position + offset
	player_camera.global_position = player_camera.global_position.lerp(wanted, 1.0 - exp(-10.0 * delta))
	player_camera.look_at(player.global_position + Vector3(0.0, 1.0, 0.0), Vector3.UP)


func _update_hud(delta: float) -> void:
	if message_left > 0.0:
		message_left -= delta
		if message_left <= 0.0:
			message.text = ""
	var scan_line := "listo"
	if scan_reveal_left > 0.0:
		scan_line = "activo %.1f s" % scan_reveal_left
	elif scan_charge > 0.0:
		scan_line = "escaneando %d%%" % int(scan_charge / SCAN_CHARGE * 100.0)
	elif scan_cooldown_left > 0.0:
		scan_line = "recarga %.1f s" % scan_cooldown_left
	var circuit := "A ok   |   B desviado   |   C ok" if not b_connected else "A ok   |   B ok   |   C ok"
	hud.text = "WASD mover · Ratón cámara · Espacio saltar · Shift correr · Ctrl agacharse · E interactuar · Q escáner\nEnergía: %s   |   Circuito: %s   |   Escáner: %s   |   Tiempo: %s" % ["restaurada" if power_on else "cortada", circuit, scan_line, _time(elapsed)]


func _time(seconds: float) -> String:
	return "%d:%02d" % [floori(seconds / 60.0), int(seconds) % 60]


func _show_message(text: String, seconds: float) -> void:
	message.text = text
	message_left = seconds


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
	sun.light_energy = 0.5
	sun.light_color = Color(0.75, 0.85, 1.0)
	sun.shadow_enabled = true
	add_child(sun)
	_add_box(Vector3(24.0, 0.5, 14.0), Vector3(12.0, -0.25, 0.0), Color(0.11, 0.13, 0.16))
	_add_box(Vector3(0.6, 4.0, 14.6), Vector3(-0.3, 2.0, 0.0), Color(0.16, 0.19, 0.23))
	_add_box(Vector3(0.6, 4.0, 14.6), Vector3(24.3, 2.0, 0.0), Color(0.16, 0.19, 0.23))
	_add_box(Vector3(24.6, 4.0, 0.6), Vector3(12.0, 2.0, -7.3), Color(0.16, 0.19, 0.23))
	_add_box(Vector3(24.6, 4.0, 0.6), Vector3(12.0, 2.0, 7.3), Color(0.16, 0.19, 0.23))
	_add_sign("CIRCUITO A: LUCES\nCIRCUITO B: COMPUERTA\nCIRCUITO C: TERMINAL", Vector3(2.0, 2.4, -6.8))
	_add_sign("SALIDA", Vector3(23.5, 3.0, 0.0))
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(12.0, 3.4, 0.0)
	lamp.light_energy = 0.6
	lamp.omni_range = 16.0
	add_child(lamp)
	var panel := Node3D.new()
	panel.position = Vector3(2.0, 1.2, -6.0)
	add_child(panel)
	var cable := Node3D.new()
	cable.position = Vector3(9.0, 0.2, -3.0)
	add_child(cable)
	var terminal := Node3D.new()
	terminal.position = Vector3(15.0, 1.0, -5.5)
	add_child(terminal)
	var junction := Node3D.new()
	junction.position = Vector3(9.0, 0.8, -1.5)
	add_child(junction)
	var lever := Node3D.new()
	lever.position = Vector3(20.0, 1.0, -5.5)
	add_child(lever)
	var door := Node3D.new()
	door.position = Vector3(23.5, 1.5, 0.0)
	add_child(door)
	panel.set_meta("kind", "panel")
	cut_cable = cable
	terminal = terminal
	junction = junction
	lever = lever
	exit_door = door
	_add_scan_highlight(Vector3(2.0, 2.4, -5.8), Color(0.3, 0.95, 0.9))
	_add_scan_highlight(Vector3(9.0, 0.5, -3.0), Color(0.95, 0.65, 0.2))
	_add_scan_highlight(Vector3(15.0, 1.5, -5.2), Color(0.3, 0.95, 0.9))
	_add_scan_highlight(Vector3(20.0, 1.8, -5.2), Color(0.95, 0.65, 0.2))


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


func _add_scan_highlight(pos: Vector3, color: Color) -> void:
	var marker := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.25
	sphere.height = 0.5
	marker.mesh = sphere
	marker.position = pos
	marker.visible = false
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.0
	material.no_depth_test = true
	marker.material_override = material
	add_child(marker)
	scan_highlights.append(marker)


func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Elena"
	player.collision_layer = 2
	player.collision_mask = 1
	player.position = Vector3(2.0, 0.2, 0.0)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.7
	shape.shape = capsule
	shape.position = Vector3(0.0, 0.85, 0.0)
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
	player_camera.global_position = player.global_position + Vector3(0.0, 4.2, 7.5)


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
			var name := imported.resource_name if imported != null else ""
			var path := MATERIAL_DIR + name + ".tres"
			if name != "" and ResourceLoader.exists(path):
				mesh_instance.set_surface_override_material(surface, load(path) as Material)


func _build_primitive_player() -> void:
	var body := CapsuleMesh.new()
	body.radius = 0.27
	body.height = 1.1
	_add_mesh(player_visual, body, Vector3(0.0, 1.05, 0.0), Color(0.05, 0.24, 0.32))
	var head := SphereMesh.new()
	head.radius = 0.17
	head.height = 0.34
	_add_mesh(player_visual, head, Vector3(0.0, 1.72, 0.0), Color(0.8, 0.62, 0.52))


func _add_mesh(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	instance.material_override = material
	instance.position = pos
	parent.add_child(instance)


func _build_audio() -> void:
	scan_stream = SfxSynth.scan_pulse()
	denied_stream = SfxSynth.denied()
	power_stream = SfxSynth.power_up()
	door_stream = SfxSynth.door_open()
	chime_stream = SfxSynth.complete_chime()
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)


func _play(stream: AudioStream, volume_db: float) -> void:
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
	layer.add_child(hud)
	message = Label.new()
	message.custom_minimum_size = Vector2(900.0, 0.0)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 40)
	message.add_theme_font_size_override("font_size", 22)
	layer.add_child(message)
	prompt = Label.new()
	prompt.custom_minimum_size = Vector2(300.0, 0.0)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 110)
	prompt.add_theme_font_size_override("font_size", 24)
	prompt.add_theme_color_override("font_color", Color(0.95, 0.65, 0.2))
	layer.add_child(prompt)
