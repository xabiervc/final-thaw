extends Node3D
## Prueba aislada de direccion de arte del laboratorio 3D (paso 0).
##
## Valida paleta, contraste, iluminacion, legibilidad y ambiente con primitivas
## simples y la camara existente (follow_camera.gd, sin modificar). No es un
## nivel: ningun flujo del juego la carga, no usa autoloads, no toca input
## actions (solo consulta teclas fisicas) y no tiene colisiones.
##
## Ejecucion interactiva (desde la raiz del proyecto):
##   godot --path . res://scenes/levels/art_tests/lab_palette_test.tscn
##   Teclas: 1-4 saltar a un encuadre | WASD o flechas mover la Elena de referencia
##           G escala de grises | P guardar captura manual
##           [ ] energia de la luz clave | - = energia del ambiente
##
## Modo captura (guarda PNG a 1280x720 y sale; los argumentos van tras "--"):
##   godot --path . res://scenes/levels/art_tests/lab_palette_test.tscn -- --capture
##   godot --path . res://scenes/levels/art_tests/lab_palette_test.tscn -- --capture --capture-dir=C:/ruta/evidencia
## Sin --capture-dir se escribe en user://lab_palette_test (fuera del repo); la
## ruta absoluta se imprime en la consola. Por cada encuadre se guarda la imagen
## en color y otra en escala de grises (_gray) para revisar el contraste.
##
## Notas de la referencia de Elena: sigue el concept art (abrigo azul petroleo,
## vivos gris-cian, pantalones carbon, botas verde petroleo, mochila, Aster
## cian). Se omite a proposito el piloto ambar de la mochila: el ambar esta
## reservado para interactuables y pantallas de terminal. Es una decision de
## revision pendiente, no una correccion del concept art.

const B = preload("res://scripts/components/build_util.gd")
const CameraScript = preload("res://scripts/components/follow_camera.gd")

# --- Paleta (hex) -----------------------------------------------------------
const COLOR_FLOOR_EPOXY := Color("6B7377")
const COLOR_FLOOR_JOINT := Color("4A5155")
const COLOR_WALL_PANEL := Color("9AA2A5")
const COLOR_TRIM_METAL := Color("3B4347")
const COLOR_PAINTED_METAL := Color("56656C")
const COLOR_RUBBER := Color("1E2124")
const COLOR_SCREEN_AMBER := Color("F2B340")
const COLOR_LIGHT_EMISSIVE := Color("DDE8F0")
const COLOR_WALL_STAIN := Color("858D90") # solo prueba: legibilidad del desgaste

const COLOR_ELENA_COAT := Color("2C474C")
const COLOR_ELENA_PIPING := Color("8DB0B0")
const COLOR_ELENA_TROUSERS := Color("33373A")
const COLOR_ELENA_BOOTS := Color("1F3436")
const COLOR_ELENA_BACKPACK := Color("26403F")
const COLOR_ELENA_SKIN := Color("D9B49A")
const COLOR_ELENA_HAIR := Color("2A211E")
const COLOR_ASTER_CYAN := Color("7FF0E6")

# --- Entorno e iluminacion (valores iniciales a ajustar) --------------------
const BACKGROUND_COLOR := Color(0.02, 0.03, 0.05)
const AMBIENT_COLOR := Color(0.35, 0.42, 0.5)
const FOG_COLOR := Color(0.1, 0.14, 0.18)
const FOG_DENSITY := 0.01
const AMBIENT_ENERGY_DEFAULT := 0.5
const AMBIENT_ENERGY_STEP := 0.1
const KEY_LIGHT_ENERGY_DEFAULT := 1.6
const KEY_LIGHT_ENERGY_STEP := 0.2
const KEY_LIGHT_RANGE := 6.0
const KEY_LIGHT_POSITION := Vector3(0.0, 2.2, -1.55)
const AMBER_LIGHT_COLOR := Color(0.95, 0.7, 0.25)
const AMBER_LIGHT_ENERGY := 0.6
const AMBER_LIGHT_RANGE := 3.0

# --- Geometria del rincon (metros; suelo a y=0, esquina trasera izquierda) --
const FLOOR_SIZE := Vector2(6.0, 4.0)
const WALL_HEIGHT := 3.2
const WALL_THICKNESS := 0.5
const TERMINAL_POSITION := Vector3(0.0, 0.0, -1.6)
const CONTAINER_POSITION := Vector3(2.0, 0.0, -0.6)
const WALL_LIGHT_POSITION := Vector3(0.0, 2.4, -1.875)

# --- Camara existente y encuadres -------------------------------------------
const CAMERA_LIMIT_MIN := Vector2(-1.5, -0.5)
const CAMERA_LIMIT_MAX := Vector2(1.5, 0.5)
const SHOTS := [
	{"id": "terminal", "pos": Vector3(-1.2, 0.0, -0.8), "yaw": -50.0},
	{"id": "container", "pos": Vector3(2.0, 0.0, -1.5), "yaw": 0.0},
	{"id": "corner", "pos": Vector3(-2.4, 0.0, -1.4), "yaw": 45.0},
	{"id": "key_light", "pos": Vector3(0.0, 0.0, -0.6), "yaw": 0.0},
]

# --- Movimiento libre de la referencia (solo modo interactivo) --------------
const MOVE_SPEED := 3.0
const TURN_SPEED := 12.0
const ELENA_MIN := Vector2(-2.65, -1.65)
const ELENA_MAX := Vector2(2.65, 1.65)

# --- Captura ----------------------------------------------------------------
const CAPTURE_SIZE := Vector2i(1280, 720)
const CAPTURE_WARMUP_FRAMES := 20
const CAPTURE_SETTLE_FRAMES := 4
const CAPTURE_DEFAULT_DIR := "user://lab_palette_test"
const GRAYSCALE_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
void fragment() {
	vec3 c = texture(screen_texture, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
	COLOR = vec4(vec3(l), 1.0);
}
"""

var _capture: bool = false
var _capture_dir: String = ""
var _environment: Environment
var _key_light: OmniLight3D
var _elena: Node3D
var _camera: Camera3D
var _gray_layer: CanvasLayer
var _materials: Dictionary = {}


func _ready() -> void:
	_parse_args()
	_build_materials()
	_build_environment()
	_build_lights()
	_build_floor()
	_build_walls()
	_build_terminal()
	_build_container()
	_build_wall_light()
	_build_elena_reference()
	_build_camera()
	_build_grayscale_overlay()
	_apply_shot(0)
	if _capture:
		_capture_sequence()
	else:
		print("[lab_palette_test] 1-4 encuadres | WASD/flechas mover | G grises | P captura | [ ] luz clave | - = ambiente")
		_print_state()


func _parse_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture":
			_capture = true
		elif arg.begins_with("--capture-dir="):
			_capture_dir = arg.substr("--capture-dir=".length())


# --- Materiales (nombres de la especificacion lab_mat_*) --------------------
func _register_material(material_name: String, color: Color, roughness: float, emission: float = 0.0) -> void:
	var material := B.mat(color, roughness, emission)
	material.resource_name = material_name
	_materials[material_name] = material


func _build_materials() -> void:
	_register_material("lab_mat_floor_epoxy", COLOR_FLOOR_EPOXY, 0.65)
	_register_material("lab_mat_floor_joint", COLOR_FLOOR_JOINT, 0.9) # solo prueba
	_register_material("lab_mat_wall_panel", COLOR_WALL_PANEL, 0.8)
	_register_material("lab_mat_wall_stain", COLOR_WALL_STAIN, 0.85) # solo prueba
	_register_material("lab_mat_trim_metal", COLOR_TRIM_METAL, 0.5)
	_register_material("lab_mat_painted_metal", COLOR_PAINTED_METAL, 0.7)
	_register_material("lab_mat_rubber", COLOR_RUBBER, 0.9)
	_register_material("lab_mat_screen_emissive", COLOR_SCREEN_AMBER, 0.4, 2.0)
	_register_material("lab_mat_light_emissive", COLOR_LIGHT_EMISSIVE, 0.4, 2.5)
	_register_material("elena_ref_coat", COLOR_ELENA_COAT, 0.85)
	_register_material("elena_ref_piping", COLOR_ELENA_PIPING, 0.6)
	_register_material("elena_ref_trousers", COLOR_ELENA_TROUSERS, 0.9)
	_register_material("elena_ref_boots", COLOR_ELENA_BOOTS, 0.7)
	_register_material("elena_ref_backpack", COLOR_ELENA_BACKPACK, 0.85)
	_register_material("elena_ref_skin", COLOR_ELENA_SKIN, 0.8)
	_register_material("elena_ref_hair", COLOR_ELENA_HAIR, 0.9)
	_register_material("elena_ref_aster", COLOR_ASTER_CYAN, 0.4, 2.0)


func _material(material_name: String) -> Material:
	return _materials[material_name] as Material


# --- Primitivas -------------------------------------------------------------
func _add_box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
	return instance


func _add_capsule(parent: Node3D, node_name: String, radius: float, height: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.material = material
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
	return instance


func _add_sphere(parent: Node3D, node_name: String, radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.material = material
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
	return instance


func _add_cylinder(parent: Node3D, node_name: String, radius: float, height: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.material = material
	instance.mesh = mesh
	instance.position = pos
	parent.add_child(instance)
	return instance


# --- Entorno e iluminacion --------------------------------------------------
func _build_environment() -> void:
	_environment = Environment.new()
	_environment.background_mode = Environment.BG_COLOR
	_environment.background_color = BACKGROUND_COLOR
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = AMBIENT_COLOR
	_environment.ambient_light_energy = AMBIENT_ENERGY_DEFAULT
	_environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_environment.fog_enabled = true
	_environment.fog_light_color = FOG_COLOR
	_environment.fog_density = FOG_DENSITY
	var world_environment := WorldEnvironment.new()
	world_environment.name = "LabWorldEnvironment"
	world_environment.environment = _environment
	add_child(world_environment)


func _build_lights() -> void:
	# Luz clave: unica con sombras, bajo el aplique de pared.
	_key_light = OmniLight3D.new()
	_key_light.name = "WallLightKey"
	_key_light.position = KEY_LIGHT_POSITION
	_key_light.light_color = COLOR_LIGHT_EMISSIVE
	_key_light.light_energy = KEY_LIGHT_ENERGY_DEFAULT
	_key_light.omni_range = KEY_LIGHT_RANGE
	_key_light.shadow_enabled = true
	add_child(_key_light)
	# Acento ambar de la terminal (mismos valores que terminal.gd).
	var amber := OmniLight3D.new()
	amber.name = "TerminalAmberAccent"
	amber.position = TERMINAL_POSITION + Vector3(0.0, 1.3, 0.8)
	amber.light_color = AMBER_LIGHT_COLOR
	amber.light_energy = AMBER_LIGHT_ENERGY
	amber.omni_range = AMBER_LIGHT_RANGE
	add_child(amber)


# --- Rincon de laboratorio --------------------------------------------------
func _build_floor() -> void:
	var floor_root := Node3D.new()
	floor_root.name = "LabFloor"
	add_child(floor_root)
	# Base oscura: las juntas se ven 2 cm por debajo de las losetas.
	_add_box(floor_root, "FloorJointBase", Vector3(FLOOR_SIZE.x, 0.1, FLOOR_SIZE.y), Vector3(0.0, -0.07, 0.0), _material("lab_mat_floor_joint"))
	var tile := 2.0
	var tile_gap := 0.04
	var columns := int(FLOOR_SIZE.x / tile)
	var rows := int(FLOOR_SIZE.y / tile)
	for column in columns:
		for row in rows:
			var x := -FLOOR_SIZE.x * 0.5 + tile * 0.5 + tile * column
			var z := -FLOOR_SIZE.y * 0.5 + tile * 0.5 + tile * row
			_add_box(floor_root, "FloorTile_%d_%d" % [column, row], Vector3(tile - tile_gap, 0.1, tile - tile_gap), Vector3(x, -0.05, z), _material("lab_mat_floor_epoxy"))


func _build_walls() -> void:
	var wall_root := Node3D.new()
	wall_root.name = "LabWalls"
	add_child(wall_root)
	var half_x := FLOOR_SIZE.x * 0.5
	var half_z := FLOOR_SIZE.y * 0.5
	var panel := _material("lab_mat_wall_panel")
	var trim := _material("lab_mat_trim_metal")
	var wall_y := WALL_HEIGHT * 0.5
	# Paredes: la del fondo (-Z) cubre la esquina; la izquierda (-X) cierra el rincon.
	_add_box(wall_root, "WallBack", Vector3(FLOOR_SIZE.x + WALL_THICKNESS, WALL_HEIGHT, WALL_THICKNESS), Vector3(-WALL_THICKNESS * 0.5, wall_y, -half_z - WALL_THICKNESS * 0.5), panel)
	_add_box(wall_root, "WallLeft", Vector3(WALL_THICKNESS, WALL_HEIGHT, FLOOR_SIZE.y), Vector3(-half_x - WALL_THICKNESS * 0.5, wall_y, 0.0), panel)
	# Zocalo (0,3 m) y barandilla (y=1,0 m) en ambas paredes.
	_add_box(wall_root, "BaseboardBack", Vector3(FLOOR_SIZE.x, 0.3, 0.03), Vector3(0.0, 0.15, -half_z + 0.015), trim)
	_add_box(wall_root, "BaseboardLeft", Vector3(0.03, 0.3, FLOOR_SIZE.y), Vector3(-half_x + 0.015, 0.15, 0.0), trim)
	_add_box(wall_root, "RailBack", Vector3(FLOOR_SIZE.x, 0.06, 0.03), Vector3(0.0, 1.0, -half_z + 0.015), trim)
	_add_box(wall_root, "RailLeft", Vector3(0.03, 0.06, FLOOR_SIZE.y), Vector3(-half_x + 0.015, 1.0, 0.0), trim)
	# Juntas verticales de paneles de 2 m.
	var seam_height := WALL_HEIGHT - 0.3
	var seam_y := 0.3 + seam_height * 0.5
	for seam_x in [-1.0, 1.0]:
		_add_box(wall_root, "SeamBack_%d" % int(seam_x), Vector3(0.015, seam_height, 0.01), Vector3(seam_x, seam_y, -half_z + 0.005), trim)
	_add_box(wall_root, "SeamLeft_0", Vector3(0.01, seam_height, 0.015), Vector3(-half_x + 0.005, seam_y, 0.0), trim)
	# Mancha de humedad (prueba de nivel de desgaste 2/5 a esta distancia).
	_add_box(wall_root, "WallStainTest", Vector3(1.2, 0.5, 0.01), Vector3(-2.2, 0.55, -half_z + 0.005), _material("lab_mat_wall_stain"))


func _build_terminal() -> void:
	# Mismas medidas que scripts/components/terminal.gd.
	var terminal := Node3D.new()
	terminal.name = "LabTerminal"
	terminal.position = TERMINAL_POSITION
	add_child(terminal)
	var metal := _material("lab_mat_painted_metal")
	_add_box(terminal, "TerminalBody", Vector3(1.0, 1.0, 0.7), Vector3(0.0, 0.5, 0.0), metal)
	var tilt := _add_box(terminal, "TerminalScreenBezel", Vector3(0.9, 0.55, 0.08), Vector3(0.0, 1.2, 0.2), metal)
	tilt.rotation_degrees.x = -25.0
	var screen := _add_box(terminal, "TerminalScreen", Vector3(0.78, 0.4, 0.02), Vector3(0.0, 1.22, 0.25), _material("lab_mat_screen_emissive"))
	screen.rotation_degrees.x = -25.0


func _build_container() -> void:
	var container := Node3D.new()
	container.name = "LabContainer"
	container.position = CONTAINER_POSITION
	add_child(container)
	var metal := _material("lab_mat_painted_metal")
	_add_box(container, "ContainerBody", Vector3(1.2, 1.0, 0.8), Vector3(0.0, 0.5, 0.0), metal)
	_add_box(container, "ContainerLidRim", Vector3(1.24, 0.06, 0.84), Vector3(0.0, 0.97, 0.0), _material("lab_mat_trim_metal"))
	var rubber := _material("lab_mat_rubber")
	for handle_x in [-0.35, 0.35]:
		_add_box(container, "ContainerHandle_%d" % int(signf(handle_x)), Vector3(0.3, 0.06, 0.06), Vector3(handle_x, 0.72, 0.43), rubber)


func _build_wall_light() -> void:
	var fixture := Node3D.new()
	fixture.name = "LabWallLight"
	fixture.position = WALL_LIGHT_POSITION
	add_child(fixture)
	_add_box(fixture, "WallLightHousing", Vector3(0.8, 0.2, 0.25), Vector3.ZERO, _material("lab_mat_trim_metal"))
	# Tira emisiva en la cara frontal: es la que ve la camara.
	_add_box(fixture, "WallLightTube", Vector3(0.7, 0.08, 0.02), Vector3(0.0, 0.0, 0.125), _material("lab_mat_light_emissive"))


# --- Referencia de Elena (~1,7 m, concept art) ------------------------------
func _build_elena_reference() -> void:
	_elena = Node3D.new()
	_elena.name = "ElenaReference"
	add_child(_elena)
	var boots := _material("elena_ref_boots")
	var trousers := _material("elena_ref_trousers")
	var coat := _material("elena_ref_coat")
	# Hacia delante es -Z local; la mochila queda en +Z.
	for side in [-1.0, 1.0]:
		var tag := "Left" if side < 0.0 else "Right"
		_add_cylinder(_elena, "Boot" + tag, 0.105, 0.35, Vector3(side * 0.11, 0.175, 0.0), boots)
		_add_capsule(_elena, "Leg" + tag, 0.1, 0.55, Vector3(side * 0.11, 0.6, 0.0), trousers)
	_add_capsule(_elena, "Coat", 0.26, 0.85, Vector3(0.0, 1.05, 0.0), coat)
	_add_box(_elena, "CoatShoulders", Vector3(0.58, 0.16, 0.28), Vector3(0.0, 1.38, 0.0), coat)
	_add_box(_elena, "CoatPiping", Vector3(0.03, 0.7, 0.02), Vector3(0.0, 1.05, -0.255), _material("elena_ref_piping"))
	_add_box(_elena, "Backpack", Vector3(0.34, 0.42, 0.18), Vector3(0.0, 1.12, 0.26), _material("elena_ref_backpack"))
	_add_sphere(_elena, "Head", 0.115, Vector3(0.0, 1.57, 0.0), _material("elena_ref_skin"))
	_add_sphere(_elena, "Hair", 0.125, Vector3(0.0, 1.585, 0.025), _material("elena_ref_hair"))
	# Aster en la mano derecha (+X): cian reservado para Elena y el escaneo.
	var aster := _add_box(_elena, "Aster", Vector3(0.07, 0.13, 0.015), Vector3(0.27, 1.05, -0.2), _material("elena_ref_aster"))
	aster.rotation_degrees.x = -20.0
	var aster_light := OmniLight3D.new()
	aster_light.name = "AsterLight"
	aster_light.position = Vector3(0.27, 1.1, -0.3)
	aster_light.light_color = COLOR_ASTER_CYAN
	aster_light.light_energy = 0.5
	aster_light.omni_range = 2.5
	_elena.add_child(aster_light)


# --- Camara existente -------------------------------------------------------
func _build_camera() -> void:
	# follow_camera.gd se usa tal cual: FOV 40, desplazamiento (0, 8.5, 6.5).
	var camera: Camera3D = CameraScript.new()
	camera.name = "FollowCamera"
	camera.set("target", _elena)
	camera.set("limit_min", CAMERA_LIMIT_MIN)
	camera.set("limit_max", CAMERA_LIMIT_MAX)
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


# --- Encuadres --------------------------------------------------------------
func _apply_shot(index: int) -> void:
	if index < 0 or index >= SHOTS.size():
		return
	var shot: Dictionary = SHOTS[index]
	var pos: Vector3 = shot["pos"]
	var yaw: float = shot["yaw"]
	_elena.position = pos
	_elena.rotation_degrees.y = yaw
	# Se coloca la camara sin suavizado para que el encuadre sea reproducible.
	_camera.global_position = _camera.call("_desired")
	if not _capture:
		print("[lab_palette_test] encuadre %d: %s" % [index + 1, shot["id"]])


# --- Modo interactivo -------------------------------------------------------
func _process(delta: float) -> void:
	if _capture:
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
	var next_position := _elena.position + Vector3(direction.x, 0.0, direction.y) * MOVE_SPEED * delta
	next_position.x = clampf(next_position.x, ELENA_MIN.x, ELENA_MAX.x)
	next_position.z = clampf(next_position.z, ELENA_MIN.y, ELENA_MAX.y)
	_elena.position = next_position
	var wanted_yaw := atan2(-direction.x, -direction.y)
	_elena.rotation.y = lerp_angle(_elena.rotation.y, wanted_yaw, clampf(TURN_SPEED * delta, 0.0, 1.0))


func _unhandled_input(event: InputEvent) -> void:
	if _capture or not (event is InputEventKey):
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	var code := int(key.keycode)
	var first := int(KEY_1)
	if code >= first and code < first + SHOTS.size():
		_apply_shot(code - first)
		return
	match key.keycode:
		KEY_G:
			_gray_layer.visible = not _gray_layer.visible
			_print_state()
		KEY_P:
			_save_manual_screenshot()
		KEY_BRACKETLEFT:
			_key_light.light_energy = maxf(_key_light.light_energy - KEY_LIGHT_ENERGY_STEP, 0.0)
			_print_state()
		KEY_BRACKETRIGHT:
			_key_light.light_energy += KEY_LIGHT_ENERGY_STEP
			_print_state()
		KEY_MINUS:
			_environment.ambient_light_energy = maxf(_environment.ambient_light_energy - AMBIENT_ENERGY_STEP, 0.0)
			_print_state()
		KEY_EQUAL:
			_environment.ambient_light_energy += AMBIENT_ENERGY_STEP
			_print_state()


func _print_state() -> void:
	print("[lab_palette_test] luz clave=%.2f ambiente=%.2f grises=%s" % [_key_light.light_energy, _environment.ambient_light_energy, str(_gray_layer.visible)])


# --- Captura ----------------------------------------------------------------
func _resolve_capture_dir() -> String:
	var base := _capture_dir if _capture_dir != "" else CAPTURE_DEFAULT_DIR
	return ProjectSettings.globalize_path(base)


func _save_manual_screenshot() -> void:
	var dir_path := _resolve_capture_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	var image := get_viewport().get_texture().get_image()
	var path := dir_path.path_join("lab_palette_test_manual_%d.png" % Time.get_ticks_msec())
	var err := image.save_png(path)
	if err == OK:
		print("[lab_palette_test] captura manual guardada: ", path, " (", image.get_size(), ")")
	else:
		push_error("[lab_palette_test] no se pudo guardar la captura manual (error %d): %s" % [err, path])


func _capture_sequence() -> void:
	var dir_path := _resolve_capture_dir()
	var dir_err := DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_err != OK:
		push_error("[lab_palette_test] no se pudo crear el directorio de captura (error %d): %s" % [dir_err, dir_path])
		get_tree().quit(1)
		return
	print("[lab_palette_test] modo captura -> ", dir_path)
	var window := get_window()
	window.mode = Window.MODE_WINDOWED
	window.size = CAPTURE_SIZE
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
				push_warning("[lab_palette_test] tamano de captura %s distinto de %s; ejecuta en ventana propia, no embebida en el editor." % [image.get_size(), CAPTURE_SIZE])
			var suffix := "_gray" if gray else ""
			var file_name := "lab_palette_test_%02d_%s%s.png" % [index + 1, SHOTS[index]["id"], suffix]
			var path := dir_path.path_join(file_name)
			var save_err := image.save_png(path)
			if save_err == OK:
				print("[lab_palette_test] guardado: ", path)
			else:
				failures += 1
				push_error("[lab_palette_test] error %d al guardar %s" % [save_err, path])
	_gray_layer.visible = false
	print("[lab_palette_test] captura terminada, fallos: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)
