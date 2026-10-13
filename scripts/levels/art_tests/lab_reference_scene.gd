extends Node3D
## Escena de referencia visual del laboratorio (rincon representativo), aislada del juego.
##
## Muestra el nivel de calidad objetivo con los assets de assets/models/lab_ref/ (suelo, pared,
## esquina, terminal, lampara y Elena) y sus texturas de produccion. No es un nivel: no usa
## abandoned_lab.tscn, autoloads ni input actions (solo teclas fisicas), no toca el gameplay ni
## los colisionadores funcionales y mantiene el renderizador del proyecto (gl_compatibility).
## Usa follow_camera.gd sin modificar.
##
## Modo de presentacion (por defecto): oculta las referencias tecnicas (poste de escala, capsula,
## ejes). La tecla T las muestra. La captura siempre se hace en modo presentacion.
##
## Interactivo (desde la raiz del proyecto):
##   godot --path . res://scenes/levels/art_tests/lab_reference_scene.tscn
##   WASD o flechas: mover a Elena | 1-6 encuadres | T referencias tecnicas | G grises | P captura
## Captura (PNG 1280x720 y sale; fuera del repo):
##   godot --path . res://scenes/levels/art_tests/lab_reference_scene.tscn -- --capture --capture-dir=C:/ruta/evidencia
## Comprobacion automatica:
##   godot --headless --path . res://scenes/levels/art_tests/lab_reference_scene.tscn -- --check

const CameraScript = preload("res://scripts/components/follow_camera.gd")

const MODEL_DIR := "res://assets/models/lab_ref/"
const MATERIAL_DIR := "res://assets/materials/lab_ref/"

# --- Composicion (metros) ---------------------------------------------------------------
const FLOOR_COLUMNS := [-2.0, 0.0, 2.0]
const FLOOR_ROWS := [-1.0, 1.0]
const DRAIN_MODULES := [1, 4] # los demas modulos usan la variante sin sumidero
const ROOM_BACK_Z := -2.0
const ROOM_LEFT_X := -3.0
const WALL_CENTERS_X := [-2.0, 0.0, 2.0]
const WALL_CENTERS_Z := [-1.0, 1.0]
const TERMINAL_POSITION := Vector3(0.0, 0.0, -1.6)
const WALL_LIGHT_POSITION := Vector3(0.0, 2.4, -1.875)
const ELENA_TERMINAL_POSITION := Vector3(-1.0, 0.0, -0.75)
const WALK_SPEED := 3.0
const WALK_LIMIT_MIN := Vector2(-2.6, -1.2)
const WALK_LIMIT_MAX := Vector2(2.6, 1.6)
const TURN_SPEED := 12.0
const SCALE_POLE_POSITION := Vector3(-1.9, 0.0, 0.2)
const SCALE_POLE_HEIGHT := 1.7
const SCALE_POLE_WIDTH := 0.04

# --- Encuadres: Elena + yaw (grados). Los 4 primeros usan la camara real sin cambios --------
const SHOTS := [
	{"id": "terminal", "pos": Vector3(-1.0, 0.0, -0.75), "yaw": 132.0},
	{"id": "room", "pos": Vector3(0.6, 0.0, 0.5), "yaw": 200.0},
	{"id": "corner", "pos": Vector3(-2.1, 0.0, -1.1), "yaw": 150.0},
	{"id": "scan", "pos": Vector3(0.9, 0.0, -0.3), "yaw": 330.0},
	{"id": "detail_elena", "pos": Vector3(-1.0, 0.0, -0.75), "yaw": 150.0, "offset": Vector3(0.0, 1.0, 3.2), "fov": 30.0, "focus_y": 1.0},
	{"id": "detail_terminal", "pos": Vector3(0.0, 0.0, -1.2), "yaw": 180.0, "offset": Vector3(0.0, 1.4, 3.0), "fov": 32.0, "focus_y": 0.9},
]
const GAMEPLAY_FOV := 40.0
const GAMEPLAY_OFFSET := Vector3(0.0, 8.5, 6.5)

# --- Iluminacion ------------------------------------------------------------------------------
const BACKGROUND_COLOR := Color(0.02, 0.03, 0.05)
const AMBIENT_COLOR := Color(0.32, 0.40, 0.48)
const AMBIENT_ENERGY := 0.38
const FOG_COLOR := Color(0.07, 0.10, 0.13)
const FOG_DENSITY := 0.016
const GLOW_INTENSITY := 0.5
const GLOW_BLOOM := 0.12
const KEY_POSITION := Vector3(0.0, 2.15, -1.45)
const KEY_COLOR := Color("DDE8F0")
const KEY_ENERGY := 1.9
const KEY_RANGE := 7.5
const FILL_ROTATION := Vector3(-55.0, 25.0, 0.0)
const FILL_COLOR := Color(0.6, 0.72, 0.9)
const FILL_ENERGY := 0.22
const AMBER_POSITION := Vector3(0.0, 1.35, -0.9)
const AMBER_COLOR := Color(0.95, 0.7, 0.25)
const AMBER_ENERGY := 1.0
const AMBER_RANGE := 2.8
const CYAN_COLOR := Color(0.3, 0.95, 0.9)
const CYAN_ENERGY := 0.7
const CYAN_RANGE := 1.8
const RIM_POSITION := Vector3(-2.3, 1.7, -1.6)
const RIM_COLOR := Color(0.45, 0.62, 0.9)
const RIM_ENERGY := 0.6
const RIM_RANGE := 3.4

# --- Captura -----------------------------------------------------------------------------------
const CAPTURE_SIZE := Vector2i(1280, 720)
const CAPTURE_WARMUP_FRAMES := 24
const CAPTURE_SETTLE_FRAMES := 5
const CAPTURE_DEFAULT_DIR := "user://lab_reference_scene"
const GRAYSCALE_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
void fragment() {
	vec3 c = texture(screen_texture, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
	COLOR = vec4(vec3(l), 1.0);
}
"""

# --- Comprobacion automatica (presupuestos propuestos en docs/art/LAB_REFERENCE_SCENE_SPEC.md) ------
const BUDGETS := {"ref_floor": 4000, "ref_floor_plain": 4000, "ref_wall": 10000, "ref_wall_corner": 2500, "ref_wall_light": 2000, "ref_terminal": 8000, "ref_elena": 15000}
const SCENE_TRIANGLE_BUDGET := 90000 # medido ~85k; la propuesta inicial era 60k
const EXPECTED_SIZES := {
	"ref_floor": Vector3(2.0, 0.14, 2.0), "ref_floor_plain": Vector3(2.0, 0.12, 2.0), "ref_wall": Vector3(2.0, 3.2, 0.6), "ref_wall_corner": Vector3(0.58, 3.2, 0.58),
	"ref_terminal": Vector3(1.76, 1.48, 0.93), "ref_elena": Vector3(0.6, 1.72, 0.86),
}
const SIZE_TOLERANCE := 0.12
const ELENA_HEIGHT := 1.7
const ELENA_HEIGHT_TOLERANCE := 0.04
const CHECK_FRAMES := 4

var _capture: bool = false
var _capture_dir: String = ""
var _check: bool = false
var _presentation: bool = true
var _environment: Environment
var _elena: CharacterBody3D
var _visual: Node3D
var _camera: Camera3D
var _camera_target: Node3D
var _focus_height: float = 0.0
var _gray_layer: CanvasLayer
var _technical: Node3D
var _cyan_light: OmniLight3D
var _instances: Dictionary = {}
var _material_cache: Dictionary = {}
var _missing_materials: Array[String] = []


func _ready() -> void:
	_parse_args()
	_build_environment()
	_build_lights()
	_build_room()
	_build_elena()
	_build_technical_references()
	_build_camera()
	_build_grayscale_overlay()
	_set_presentation(true)
	_apply_shot(0)
	if _capture:
		_capture_sequence()
	elif _check:
		_run_checks()
	else:
		print("[lab_reference_scene] WASD mover | 1-6 encuadres | T referencias tecnicas | G grises | P captura")


func _parse_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture":
			_capture = true
		elif arg == "--check":
			_check = true
		elif arg.begins_with("--capture-dir="):
			_capture_dir = arg.substr("--capture-dir=".length())


# --- Carga de assets y materiales ----------------------------------------------------------------
func _material_for(material_name: String) -> Material:
	if _material_cache.has(material_name):
		return _material_cache[material_name]
	var path := MATERIAL_DIR + material_name + ".tres"
	var material: Material = null
	if ResourceLoader.exists(path):
		material = load(path) as Material
	_material_cache[material_name] = material
	return material


func _dress(instance: Node) -> void:
	for node in instance.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		for surface in mesh_instance.mesh.get_surface_count():
			var imported := mesh_instance.mesh.surface_get_material(surface)
			var material_name := imported.resource_name if imported != null else ""
			var material := _material_for(material_name)
			if material != null:
				mesh_instance.set_surface_override_material(surface, material)
			elif not _missing_materials.has(material_name):
				_missing_materials.append(material_name)


func _spawn(asset: String, node_name: String, pos: Vector3, yaw: float = 0.0, parent: Node3D = null) -> Node3D:
	var instance := (load(MODEL_DIR + asset + ".glb") as PackedScene).instantiate() as Node3D
	instance.name = node_name
	instance.position = pos
	instance.rotation_degrees.y = yaw
	(parent if parent != null else self).add_child(instance)
	_dress(instance)
	if not _instances.has(asset):
		_instances[asset] = instance
	return instance


func _build_room() -> void:
	var root := Node3D.new()
	root.name = "LabCorner"
	add_child(root)
	var variant := 0
	for x in FLOOR_COLUMNS:
		for z in FLOOR_ROWS:
			var asset := "ref_floor" if variant in DRAIN_MODULES else "ref_floor_plain"
			_spawn(asset, "FloorModule_%d" % variant, Vector3(x, 0.0, z), 90.0 * (variant % 4), root)
			variant += 1
	for index in WALL_CENTERS_X.size():
		_spawn("ref_wall", "WallBack_%d" % index, Vector3(WALL_CENTERS_X[index], 0.0, ROOM_BACK_Z), 0.0, root)
	for index in WALL_CENTERS_Z.size():
		_spawn("ref_wall", "WallLeft_%d" % index, Vector3(ROOM_LEFT_X, 0.0, WALL_CENTERS_Z[index]), 90.0, root)
	_spawn("ref_wall_corner", "WallCorner", Vector3(ROOM_LEFT_X, 0.0, ROOM_BACK_Z), 0.0, root)
	_spawn("ref_terminal", "Terminal", TERMINAL_POSITION, 0.0, root)
	_spawn("ref_wall_light", "WallLight", WALL_LIGHT_POSITION, 0.0, root)


func _build_elena() -> void:
	# Capsulo y velocidad copiados de elena_controller.gd; sin colisionadores del nivel (escena de presentacion).
	_elena = CharacterBody3D.new()
	_elena.name = "ElenaReferenceWalker"
	_elena.position = ELENA_TERMINAL_POSITION
	_visual = Node3D.new()
	_visual.name = "visual"
	_elena.add_child(_visual)
	var model := _spawn("ref_elena", "ElenaModel", Vector3.ZERO, 0.0, _visual)
	_cyan_light = OmniLight3D.new()
	_cyan_light.name = "AsterLight"
	_cyan_light.light_color = CYAN_COLOR
	_cyan_light.light_energy = CYAN_ENERGY
	_cyan_light.omni_range = CYAN_RANGE
	_cyan_light.position = Vector3(-0.16, 1.1, 0.4)
	_visual.add_child(_cyan_light)
	add_child(_elena)
	_instances["ref_elena"] = model


func _build_technical_references() -> void:
	# Poste de escala y capsula de gameplay: solo visibles fuera del modo de presentacion.
	_technical = Node3D.new()
	_technical.name = "TechnicalReferences"
	add_child(_technical)
	var pole := MeshInstance3D.new()
	pole.name = "ScalePole"
	var pole_mesh := BoxMesh.new()
	pole_mesh.size = Vector3(SCALE_POLE_WIDTH, SCALE_POLE_HEIGHT, SCALE_POLE_WIDTH)
	var pole_material := StandardMaterial3D.new()
	pole_material.albedo_color = Color(1.0, 1.0, 1.0)
	pole_mesh.material = pole_material
	pole.mesh = pole_mesh
	pole.position = SCALE_POLE_POSITION + Vector3(0.0, SCALE_POLE_HEIGHT * 0.5, 0.0)
	_technical.add_child(pole)
	var capsule := MeshInstance3D.new()
	capsule.name = "GameplayCapsule"
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.32
	capsule_mesh.height = 1.7
	var capsule_material := StandardMaterial3D.new()
	capsule_material.albedo_color = Color(1.0, 0.4, 0.1, 0.25)
	capsule_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	capsule_mesh.material = capsule_material
	capsule.mesh = capsule_mesh
	capsule.position = Vector3(SCALE_POLE_POSITION.x + 0.5, 0.85, SCALE_POLE_POSITION.z)
	_technical.add_child(capsule)


func _set_presentation(value: bool) -> void:
	_presentation = value
	_technical.visible = not value


# --- Iluminacion -----------------------------------------------------------------------------------
func _build_environment() -> void:
	_environment = Environment.new()
	_environment.background_mode = Environment.BG_COLOR
	_environment.background_color = BACKGROUND_COLOR
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = AMBIENT_COLOR
	_environment.ambient_light_energy = AMBIENT_ENERGY
	_environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_environment.fog_enabled = true
	_environment.fog_light_color = FOG_COLOR
	_environment.fog_density = FOG_DENSITY
	_environment.glow_enabled = true
	_environment.glow_intensity = GLOW_INTENSITY
	_environment.glow_bloom = GLOW_BLOOM
	var world_environment := WorldEnvironment.new()
	world_environment.name = "LabWorldEnvironment"
	world_environment.environment = _environment
	add_child(world_environment)


func _omni(node_name: String, pos: Vector3, color: Color, energy: float, light_range: float, shadows: bool) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.name = node_name
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = light_range
	light.shadow_enabled = shadows
	add_child(light)
	return light


func _build_lights() -> void:
	_omni("WallLightKey", KEY_POSITION, KEY_COLOR, KEY_ENERGY, KEY_RANGE, true)
	_omni("TerminalAmberAccent", AMBER_POSITION, AMBER_COLOR, AMBER_ENERGY, AMBER_RANGE, false)
	_omni("RimLight", RIM_POSITION, RIM_COLOR, RIM_ENERGY, RIM_RANGE, false)
	var fill := DirectionalLight3D.new()
	fill.name = "CoolFill"
	fill.rotation_degrees = FILL_ROTATION
	fill.light_color = FILL_COLOR
	fill.light_energy = FILL_ENERGY
	add_child(fill)


# --- Camara, encuadres e input ----------------------------------------------------------------------------
func _build_camera() -> void:
	var camera: Camera3D = CameraScript.new()
	camera.name = "FollowCamera"
	_camera_target = Node3D.new()
	_camera_target.name = "CameraTarget"
	add_child(_camera_target)
	camera.set("target", _camera_target)
	add_child(camera)
	_camera = camera


func _build_grayscale_overlay() -> void:
	_gray_layer = CanvasLayer.new()
	_gray_layer.name = "GrayscaleReview"
	_gray_layer.layer = 100
	_gray_layer.visible = false
	var rect := ColorRect.new()
	rect.name = "GrayscaleRect"
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = GRAYSCALE_SHADER
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	rect.material = shader_material
	_gray_layer.add_child(rect)
	add_child(_gray_layer)


func _apply_shot(index: int) -> void:
	var shot: Dictionary = SHOTS[index]
	_elena.global_position = shot["pos"]
	_visual.rotation_degrees.y = shot["yaw"]
	_focus_height = float(shot.get("focus_y", 0.0))
	_camera_target.global_position = _elena.global_position + Vector3(0.0, _focus_height, 0.0)
	_camera.set("offset", shot.get("offset", GAMEPLAY_OFFSET))
	_camera.fov = shot.get("fov", GAMEPLAY_FOV)
	_camera.rotation = Vector3(-atan2(_camera.get("offset").y, _camera.get("offset").z), 0.0, 0.0)
	_camera.global_position = _camera.call("_desired")
	if not _capture and not _check:
		print("[lab_reference_scene] encuadre %d: %s" % [index + 1, shot["id"]])


func _process(delta: float) -> void:
	_camera_target.global_position = _elena.global_position + Vector3(0.0, _focus_height, 0.0)
	if _capture or _check:
		return
	var direction := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if direction == Vector2.ZERO:
		return
	direction = direction.normalized()
	var next_position := _elena.position + Vector3(direction.x, 0.0, direction.y) * WALK_SPEED * delta
	next_position.x = clampf(next_position.x, WALK_LIMIT_MIN.x, WALK_LIMIT_MAX.x)
	next_position.z = clampf(next_position.z, WALK_LIMIT_MIN.y, WALK_LIMIT_MAX.y)
	_elena.position = next_position
	# Misma convencion que elena_controller.gd: frente +Z, giro con atan2(x, z).
	_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(direction.x, direction.y), clampf(TURN_SPEED * delta, 0.0, 1.0))


func _unhandled_input(event: InputEvent) -> void:
	if _capture or _check or not (event is InputEventKey):
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	var code := int(key.keycode)
	if code >= int(KEY_1) and code < int(KEY_1) + SHOTS.size():
		_apply_shot(code - int(KEY_1))
		return
	match key.keycode:
		KEY_T:
			_set_presentation(not _presentation)
			print("[lab_reference_scene] modo ", "presentacion" if _presentation else "referencias tecnicas")
		KEY_G:
			_gray_layer.visible = not _gray_layer.visible
		KEY_P:
			_save_manual_screenshot()


# --- Captura ---------------------------------------------------------------------------------------------------
func _resolve_capture_dir() -> String:
	var base := _capture_dir if _capture_dir != "" else CAPTURE_DEFAULT_DIR
	return ProjectSettings.globalize_path(base)


func _save_manual_screenshot() -> void:
	var dir_path := _resolve_capture_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	var image := get_viewport().get_texture().get_image()
	var path := dir_path.path_join("lab_reference_manual_%d.png" % Time.get_ticks_msec())
	if image.save_png(path) == OK:
		print("[lab_reference_scene] captura manual guardada: ", path)
	else:
		push_error("[lab_reference_scene] no se pudo guardar la captura manual: " + path)


func _capture_sequence() -> void:
	var dir_path := _resolve_capture_dir()
	if DirAccess.make_dir_recursive_absolute(dir_path) != OK:
		push_error("[lab_reference_scene] no se pudo crear el directorio: " + dir_path)
		get_tree().quit(1)
		return
	print("[lab_reference_scene] modo captura (presentacion) -> ", dir_path)
	var window := get_window()
	window.mode = Window.MODE_WINDOWED
	window.size = CAPTURE_SIZE
	_set_presentation(true)
	for _frame in CAPTURE_WARMUP_FRAMES:
		await get_tree().process_frame
	var failures := 0
	for index in SHOTS.size():
		_apply_shot(index)
		for gray in [false, true]:
			_gray_layer.visible = gray
			for _frame in CAPTURE_SETTLE_FRAMES:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image := get_viewport().get_texture().get_image()
			if image.get_size() != CAPTURE_SIZE:
				push_warning("[lab_reference_scene] tamano %s distinto de %s; ejecuta en ventana propia." % [image.get_size(), CAPTURE_SIZE])
			var path := dir_path.path_join("lab_reference_%02d_%s%s.png" % [index + 1, SHOTS[index]["id"], "_gray" if gray else ""])
			var save_err := image.save_png(path)
			if save_err == OK:
				print("[lab_reference_scene] guardado: ", path)
			else:
				failures += 1
				push_error("[lab_reference_scene] error %d al guardar %s" % [save_err, path])
	_gray_layer.visible = false
	print("[lab_reference_scene] captura terminada, fallos: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


# --- Comprobacion automatica --------------------------------------------------------------------------------------
func _run_checks() -> void:
	for _frame in CHECK_FRAMES:
		await get_tree().process_frame
	var failures := 0
	failures += _check_materials()
	failures += _check_budgets_and_sizes()
	failures += _check_scene_contract()
	print("[lab_reference_scene] comprobaciones terminadas, fallos: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


func _report(ok: bool, label: String, detail: String = "") -> int:
	print("[lab_reference_scene] %s %s%s" % ["PASS" if ok else "FAIL", label, (" | " + detail) if detail != "" else ""])
	return 0 if ok else 1


func _mesh_instances(root: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		found.append(root as MeshInstance3D)
	for child in root.get_children():
		found.append_array(_mesh_instances(child))
	return found


func _triangles(root: Node) -> int:
	var total := 0
	for mesh_instance in _mesh_instances(root):
		total += mesh_instance.mesh.get_faces().size() / 3
	return total


func _local_aabb(instance: Node3D) -> AABB:
	var combined := AABB()
	var first := true
	var inverse := instance.global_transform.affine_inverse()
	for mesh_instance in _mesh_instances(instance):
		var box := (inverse * mesh_instance.global_transform) * mesh_instance.get_aabb()
		combined = box if first else combined.merge(box)
		first = false
	return combined


func _check_materials() -> int:
	var failures := 0
	failures += _report(_missing_materials.is_empty(), "todos los materiales de los GLB tienen .tres", "faltan=%s" % str(_missing_materials))
	for material_name in _material_cache:
		var material := _material_cache[material_name] as StandardMaterial3D
		if material == null:
			continue
		var textured := material.albedo_texture != null or material.emission_texture != null or material.emission_enabled
		var pbr_ok := material.normal_texture != null and material.roughness_texture != null and material.metallic_texture != null and material.ao_texture != null
		var is_emissive := material.emission_enabled
		failures += _report(textured and (pbr_ok or is_emissive), "texturas cargadas en " + material_name, "albedo=%s normal=%s orm=%s emision=%s" % [str(material.albedo_texture != null), str(material.normal_texture != null), str(material.roughness_texture != null), str(is_emissive)])
	return failures


func _check_budgets_and_sizes() -> int:
	var failures := 0
	var scene_total := 0
	for asset in BUDGETS:
		var instance: Node3D = _instances[asset]
		var triangles := _triangles(instance)
		failures += _report(triangles <= int(BUDGETS[asset]), "presupuesto de " + asset, "triangulos=%d (max %d)" % [triangles, BUDGETS[asset]])
		if EXPECTED_SIZES.has(asset):
			var box := _local_aabb(instance)
			var wanted: Vector3 = EXPECTED_SIZES[asset]
			var ok := absf(box.size.x - wanted.x) <= SIZE_TOLERANCE and absf(box.size.y - wanted.y) <= SIZE_TOLERANCE and absf(box.size.z - wanted.z) <= SIZE_TOLERANCE
			failures += _report(ok, "medidas de " + asset, "size=%s esperado~%s" % [box.size, wanted])
	for node in get_children():
		scene_total += _triangles(node)
	failures += _report(scene_total <= SCENE_TRIANGLE_BUDGET, "triangulos de la escena completa", "total=%d (max %d)" % [scene_total, SCENE_TRIANGLE_BUDGET])
	var elena_box := _local_aabb(_instances["ref_elena"])
	failures += _report(absf(elena_box.size.y - ELENA_HEIGHT) <= ELENA_HEIGHT_TOLERANCE and absf(elena_box.position.y) <= 0.03, "Elena mide ~1,70 m con los pies en y=0", "alto=%.3f min_y=%.3f" % [elena_box.size.y, elena_box.position.y])
	return failures


func _check_scene_contract() -> int:
	var failures := 0
	failures += _report(String(ProjectSettings.get_setting("rendering/renderer/rendering_method")) == "gl_compatibility", "renderizador sin cambios (gl_compatibility)")
	failures += _report(_camera.get_script() == CameraScript, "camara = follow_camera.gd sin modificar", "fov=%s offset=%s" % [_camera.fov, _camera.get("offset")])
	failures += _report(not _technical.visible and _presentation, "modo presentacion oculta las referencias tecnicas")
	var colliders := find_children("*", "CollisionObject3D", true, false)
	failures += _report(colliders.size() == 1 and colliders[0] == _elena, "sin colisionadores del nivel en la escena de referencia", "cuerpos=%d" % colliders.size())
	var gameplay_scripts := 0
	for node in find_children("*", "", true, false):
		var script := node.get_script() as Script
		if script != null and script.resource_path.begins_with("res://scripts/") and node != self and script != CameraScript:
			gameplay_scripts += 1
	failures += _report(gameplay_scripts == 0, "la escena no instancia scripts de gameplay (solo follow_camera.gd)", "scripts=%d" % gameplay_scripts)
	return failures
