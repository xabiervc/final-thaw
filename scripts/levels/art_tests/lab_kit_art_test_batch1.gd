extends Node3D
## Prueba aislada del lote 1 del kit de entorno y de la Elena de bloqueo.
##
## Corte del laboratorio con el layout real de abandoned_lab.gd (suelo de 12 m de fondo,
## muro del fondo de 3,2 m con cara interior en z=-6, muro bajo de 0,9 m del lado de la
## camara en z=+6, divisor en x=16 con marco de puerta y un foso al final). No es un nivel:
## no usa abandoned_lab.tscn, autoloads ni input actions (solo consulta teclas fisicas).
## Usa follow_camera.gd sin modificar. El gameplay no se toca.
##
## Interactivo (desde la raiz del proyecto):
##   godot --path . res://scenes/levels/art_tests/lab_kit_art_test_batch1.tscn
##   WASD o flechas: mover la Elena de bloqueo (fisica real contra los colisionadores simples)
##   1-5 encuadres | O puerta abierta/cerrada | L iluminacion (juego / prueba de paleta)
##   G escala de grises | P captura manual
## Captura (PNG a 1280x720 y sale; 5 encuadres x 2 iluminaciones x color/gris):
##   godot --path . res://scenes/levels/art_tests/lab_kit_art_test_batch1.tscn -- --capture --capture-dir=C:/ruta/evidencia
## Comprobacion automatica (medidas, materiales, ajuste del marco, Elena, colisiones):
##   godot --headless --path . res://scenes/levels/art_tests/lab_kit_art_test_batch1.tscn -- --check

const CameraScript = preload("res://scripts/components/follow_camera.gd")

const LAB_DIR := "res://assets/models/lab/"
const CHARACTER_DIR := "res://assets/models/characters/"

# --- Layout (metros; mismos valores que abandoned_lab.gd) -----------------------
const SLICE_X_MIN := 10.0
const SLICE_X_MAX := 24.0
const FLOOR_X_END := 22.0 # a partir de aqui hay un foso
const ROOM_HALF_DEPTH := 6.0
const MODULE := 2.0
const DIVIDER_X := 16.0
const WALL_HEIGHT := 3.2
const LOW_WALL_HEIGHT := 0.9
const WALL_THICKNESS := 0.5
const DIVIDER_THICKNESS := 0.6
const DIVIDER_ARM_LENGTH := 4.6
const DOOR_SIZE := Vector3(0.4, 3.0, 2.8) # door.gd: door_size
const FLOOR_COLLIDER_THICKNESS := 0.5
const WALL_LIGHT_POSITION := Vector3(14.0, 2.4, -5.875)
const EDGE_LIP_X := 21.925
const BOUNDARY_THICKNESS := 0.5

# --- Fisica del caminante (valores del capsulo de elena_controller.gd) ------------
const CAPSULE_RADIUS := 0.32
const CAPSULE_HEIGHT := 1.7
const WALK_SPEED := 5.0
const GRAVITY := 20.0
const TURN_SPEED := 12.0
const FALL_RESET_Y := -6.0
const WALKER_START := Vector3(12.0, 0.1, 0.0)
const COLLISION_WORLD := 1
const COLLISION_PLAYER := 2

# --- Camara y encuadres ---------------------------------------------------------
const CAMERA_LIMIT_MIN := Vector2(12.0, -1.5)
const CAMERA_LIMIT_MAX := Vector2(22.0, 4.6) # el juego limita z a 1,5; aqui se amplia para poder ver el muro bajo (z=6)
const SHOTS := [
	{"id": "divider", "pos": Vector3(13.6, 0.0, 0.0), "yaw": 90.0},
	{"id": "low_wall", "pos": Vector3(12.5, 0.0, 4.6), "yaw": 180.0},
	{"id": "pit_edge", "pos": Vector3(20.3, 0.0, 0.0), "yaw": 90.0},
	{"id": "elena_scale", "pos": Vector3(12.4, 0.0, 0.0), "yaw": 0.0},
	{"id": "wall_variants", "pos": Vector3(14.0, 0.0, -4.2), "yaw": 180.0},
]
const SCALE_REFERENCE_CAPSULE_POS := Vector3(13.2, 0.0, 0.0)
const SCALE_REFERENCE_POLE_POS := Vector3(13.8, 0.0, 0.0)
const SCALE_POLE_WIDTH := 0.04

# --- Iluminacion ----------------------------------------------------------------
const BACKGROUND_COLOR := Color(0.02, 0.03, 0.05)
const AMBIENT_COLOR := Color(0.35, 0.42, 0.5)
const PRESETS := [
	{"id": "game", "ambient": 0.3, "fog_color": Color(0.08, 0.11, 0.15), "fog_density": 0.012, "sun": 0.35, "key": 0.0},
	{"id": "palette", "ambient": 0.5, "fog_color": Color(0.1, 0.14, 0.18), "fog_density": 0.01, "sun": 0.0, "key": 1.6},
]
const SUN_ROTATION := Vector3(-60.0, -30.0, 0.0)
const SUN_COLOR := Color(0.7, 0.8, 1.0)
const LAMP_RANGE := 10.0
const LAMP_POSITIONS := [Vector3(11.0, 3.0, 0.0), Vector3(20.0, 3.0, 0.0)]
const LAMP_COLORS := [Color(0.8, 0.9, 1.0), Color(0.7, 0.85, 1.0)]
const KEY_LIGHT_POSITION := Vector3(14.0, 2.2, -5.55)
const KEY_LIGHT_COLOR := Color("DDE8F0")
const KEY_LIGHT_RANGE := 6.0

# --- Captura --------------------------------------------------------------------
const CAPTURE_SIZE := Vector2i(1280, 720)
const CAPTURE_WARMUP_FRAMES := 20
const CAPTURE_SETTLE_FRAMES := 4
const CAPTURE_DEFAULT_DIR := "user://lab_kit_art_test_batch1"
const GRAYSCALE_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
void fragment() {
	vec3 c = texture(screen_texture, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
	COLOR = vec4(vec3(l), 1.0);
}
"""

# --- Comprobacion automatica ------------------------------------------------------
const CHECK_TOLERANCE := 0.01
const CHECK_COLOR_TOLERANCE := 0.01
const CHECK_RADIANCE_TOLERANCE := 0.02
const CHECK_PHYSICS_FRAMES := 3
const ELENA_HEIGHT := 1.7
const ELENA_HEIGHT_TOLERANCE := 0.02
const ELENA_MAX_TRIANGLES := 3500
const ELENA_MAX_MESHES := 10
const OPENING_HALF_WIDTH := 1.4
const OPENING_HEIGHT := 3.0
const OPENING_PROBE_MARGIN := 0.01
const EXPECTED_ASSETS := {
	"lab_wall_low_2m_a": {"size": Vector3(2.0, 0.9, 0.53), "min": Vector3(-1.0, 0.0, -0.5)},
	"lab_wall_2m_b": {"size": Vector3(2.0, 3.2, 0.56), "min": Vector3(-1.0, 0.0, -0.5)},
	"lab_floor_2x2_b": {"size": Vector3(2.0, 0.103, 2.0), "min": Vector3(-1.0, -0.1, -1.0)},
	"lab_floor_edge_2m_a": {"size": Vector3(2.0, 0.07, 0.15), "min": Vector3(-1.0, 0.0, -0.075)},
	"lab_divider_wall_2m_a": {"size": Vector3(2.0, 3.2, 0.66), "min": Vector3(-1.0, 0.0, -0.33)},
	"lab_door_frame_a": {"size": Vector3(4.0, 3.2, 0.66), "min": Vector3(-2.0, 0.0, -0.33)},
	"elena_blockout_a": {"size": Vector3(0.689, 1.7, 0.805), "min": Vector3(-0.34, 0.0, -0.38)},
}
const EXPECTED_COLORS := {
	"lab_mat_floor_epoxy": "6B7377", "lab_mat_floor_joint": "4A5155", "lab_mat_wall_panel": "9AA2A5",
	"lab_mat_trim_metal": "3B4347", "lab_mat_painted_metal": "56656C", "lab_mat_rubber": "1E2124",
	"elena_blk_coat": "2C474C", "elena_blk_piping": "8DB0B0", "elena_blk_turtleneck": "26292C",
	"elena_blk_trousers": "33373A", "elena_blk_boots": "1F3436", "elena_blk_backpack": "26403F",
	"elena_blk_skin": "D9B49A", "elena_blk_hair": "2A211E", "elena_blk_aster": "7FF0E6",
}
const EXPECTED_EMISSION := {"elena_blk_aster": 2.0}
const ELENA_PARTS := ["Hips", "Torso", "Head", "ArmL", "ArmR", "Aster", "Backpack", "LegL", "LegR"]

var _capture: bool = false
var _capture_dir: String = ""
var _check: bool = false
var _environment: Environment
var _sun: DirectionalLight3D
var _key_light: OmniLight3D
var _lamps: Array[OmniLight3D] = []
var _walker: CharacterBody3D
var _visual: Node3D
var _camera: Camera3D
var _gray_layer: CanvasLayer
var _door_slab: StaticBody3D
var _door_open: bool = true
var _preset_index: int = 0
var _instances: Dictionary = {}
var _frame_node: Node3D
var _elena_node: Node3D
var _divider_nodes: Array[Node3D] = []
var _triangle_meshes: Dictionary = {}


func _ready() -> void:
	_parse_args()
	_build_environment()
	_build_floor()
	_build_walls()
	_build_dividers()
	_build_door_slab()
	_build_boundaries()
	_build_wall_light()
	_build_scale_references()
	_build_walker()
	_build_camera()
	_build_grayscale_overlay()
	_apply_preset(0)
	_set_door_open(true)
	_apply_shot(0)
	if _capture:
		_capture_sequence()
	elif _check:
		_run_checks()
	else:
		print("[lab_kit_art_test_batch1] WASD mover | 1-5 encuadres | O puerta | L luz | G grises | P captura")


func _parse_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture":
			_capture = true
		elif arg == "--check":
			_check = true
		elif arg.begins_with("--capture-dir="):
			_capture_dir = arg.substr("--capture-dir=".length())


# --- Montaje --------------------------------------------------------------------
func _instance_asset(parent: Node3D, directory: String, asset_name: String, node_name: String, pos: Vector3, yaw_degrees: float = 0.0) -> Node3D:
	var packed := load(directory + asset_name + ".glb") as PackedScene
	var instance := packed.instantiate() as Node3D
	instance.name = node_name
	instance.position = pos
	instance.rotation_degrees.y = yaw_degrees
	parent.add_child(instance)
	if not _instances.has(asset_name):
		_instances[asset_name] = instance
	return instance


func _add_collider(parent: Node3D, node_name: String, size: Vector3, pos: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	body.collision_layer = COLLISION_WORLD
	body.collision_mask = 0
	var shape_node := CollisionShape3D.new()
	shape_node.name = "CollisionShape"
	var shape := BoxShape3D.new()
	shape.size = size
	shape_node.shape = shape
	body.add_child(shape_node)
	parent.add_child(body)
	return body


func _build_floor() -> void:
	var root := Node3D.new()
	root.name = "LabFloor"
	add_child(root)
	var columns := int((FLOOR_X_END - SLICE_X_MIN) / MODULE)
	var rows := int(ROOM_HALF_DEPTH * 2.0 / MODULE)
	for column in columns:
		for row in rows:
			var x := SLICE_X_MIN + MODULE * 0.5 + MODULE * column
			var z := -ROOM_HALF_DEPTH + MODULE * 0.5 + MODULE * row
			var variant := "lab_floor_2x2_b" if (column + row) % 2 == 0 else "lab_floor_2x2_a"
			_instance_asset(root, LAB_DIR, variant, "FloorTile_%d_%d" % [column, row], Vector3(x, 0.0, z))
	for row in rows:
		var z := -ROOM_HALF_DEPTH + MODULE * 0.5 + MODULE * row
		_instance_asset(root, LAB_DIR, "lab_floor_edge_2m_a", "PitEdge_%d" % row, Vector3(EDGE_LIP_X, 0.0, z), 90.0)
	var floor_length := FLOOR_X_END - SLICE_X_MIN
	_add_collider(root, "FloorCollider", Vector3(floor_length, FLOOR_COLLIDER_THICKNESS, ROOM_HALF_DEPTH * 2.0), Vector3(SLICE_X_MIN + floor_length * 0.5, -FLOOR_COLLIDER_THICKNESS * 0.5, 0.0))


func _build_walls() -> void:
	var root := Node3D.new()
	root.name = "LabWalls"
	add_child(root)
	var count := int((SLICE_X_MAX - SLICE_X_MIN) / MODULE)
	for index in count:
		var x := SLICE_X_MIN + MODULE * 0.5 + MODULE * index
		var variant := "lab_wall_2m_b" if index % 2 == 0 else "lab_wall_2m_a"
		_instance_asset(root, LAB_DIR, variant, "WallBack_%d" % index, Vector3(x, 0.0, -ROOM_HALF_DEPTH))
		_instance_asset(root, LAB_DIR, "lab_wall_low_2m_a", "WallLow_%d" % index, Vector3(x, 0.0, ROOM_HALF_DEPTH), 180.0)
	var length := SLICE_X_MAX - SLICE_X_MIN
	var center_x := SLICE_X_MIN + length * 0.5
	_add_collider(root, "WallBackCollider", Vector3(length, WALL_HEIGHT, WALL_THICKNESS), Vector3(center_x, WALL_HEIGHT * 0.5, -ROOM_HALF_DEPTH - WALL_THICKNESS * 0.5))
	_add_collider(root, "WallLowCollider", Vector3(length, LOW_WALL_HEIGHT, WALL_THICKNESS), Vector3(center_x, LOW_WALL_HEIGHT * 0.5, ROOM_HALF_DEPTH + WALL_THICKNESS * 0.5))


func _build_dividers() -> void:
	var root := Node3D.new()
	root.name = "LabDivider"
	root.position = Vector3(DIVIDER_X, 0.0, 0.0)
	add_child(root)
	_frame_node = _instance_asset(root, LAB_DIR, "lab_door_frame_a", "DoorFrame", Vector3.ZERO, 90.0)
	_divider_nodes.append(_frame_node)
	var offsets := [-5.0, -3.0, 3.0, 5.0]
	for index in offsets.size():
		var node := _instance_asset(root, LAB_DIR, "lab_divider_wall_2m_a", "DividerModule_%d" % index, Vector3(0.0, 0.0, offsets[index]), 90.0)
		_divider_nodes.append(node)
	for side in [-1.0, 1.0]:
		var z: float = side * (ROOM_HALF_DEPTH - DIVIDER_ARM_LENGTH * 0.5)
		_add_collider(root, "DividerArmCollider_%d" % int(side), Vector3(DIVIDER_THICKNESS, WALL_HEIGHT, DIVIDER_ARM_LENGTH), Vector3(0.0, WALL_HEIGHT * 0.5, z))


func _build_door_slab() -> void:
	# Sustituto de la puerta (door.gd: losa de 0,4 x 3,0 x 2,8 m). Abierta se desplaza +2,8 m en z.
	var parent := get_node("LabDivider") as Node3D
	_door_slab = _add_collider(parent, "DoorSlab", DOOR_SIZE, Vector3(0.0, DOOR_SIZE.y * 0.5, 0.0))
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "DoorSlabMesh"
	var mesh := BoxMesh.new()
	mesh.size = DOOR_SIZE
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("56656C")
	material.roughness = 0.7
	mesh.material = material
	mesh_instance.mesh = mesh
	_door_slab.add_child(mesh_instance)


func _set_door_open(open: bool) -> void:
	_door_open = open
	_door_slab.collision_layer = 0 if open else COLLISION_WORLD
	_door_slab.position.z = DOOR_SIZE.z if open else 0.0


func _build_boundaries() -> void:
	# Topes invisibles para no salir del corte (no forman parte del arte).
	var root := Node3D.new()
	root.name = "SliceBoundaries"
	add_child(root)
	var tall := WALL_HEIGHT + 1.0
	_add_collider(root, "BoundaryWest", Vector3(BOUNDARY_THICKNESS, tall, ROOM_HALF_DEPTH * 2.0), Vector3(SLICE_X_MIN - BOUNDARY_THICKNESS * 0.5, tall * 0.5, 0.0))
	_add_collider(root, "BoundaryEast", Vector3(BOUNDARY_THICKNESS, tall, ROOM_HALF_DEPTH * 2.0), Vector3(SLICE_X_MAX + BOUNDARY_THICKNESS * 0.5, tall * 0.5, 0.0))


func _build_wall_light() -> void:
	var holder := Node3D.new()
	holder.name = "LabWallLight"
	holder.position = WALL_LIGHT_POSITION
	add_child(holder)
	_instance_asset(holder, LAB_DIR, "lab_wall_light_a", "LabWallLightAsset", Vector3.ZERO)


func _build_scale_references() -> void:
	var capsule := MeshInstance3D.new()
	capsule.name = "ScaleCapsule"
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = CAPSULE_RADIUS
	capsule_mesh.height = CAPSULE_HEIGHT
	var capsule_material := StandardMaterial3D.new()
	capsule_material.albedo_color = Color(0.9, 0.9, 0.9, 0.35)
	capsule_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	capsule_mesh.material = capsule_material
	capsule.mesh = capsule_mesh
	capsule.position = SCALE_REFERENCE_CAPSULE_POS + Vector3(0.0, CAPSULE_HEIGHT * 0.5, 0.0)
	add_child(capsule)
	var pole := MeshInstance3D.new()
	pole.name = "ScalePole"
	var pole_mesh := BoxMesh.new()
	pole_mesh.size = Vector3(SCALE_POLE_WIDTH, ELENA_HEIGHT, SCALE_POLE_WIDTH)
	var pole_material := StandardMaterial3D.new()
	pole_material.albedo_color = Color(0.95, 0.95, 0.95)
	pole_mesh.material = pole_material
	pole.mesh = pole_mesh
	pole.position = SCALE_REFERENCE_POLE_POS + Vector3(0.0, ELENA_HEIGHT * 0.5, 0.0)
	add_child(pole)


func _build_walker() -> void:
	_walker = CharacterBody3D.new()
	_walker.name = "ElenaBlockoutWalker"
	_walker.collision_layer = COLLISION_PLAYER
	_walker.collision_mask = COLLISION_WORLD
	_walker.position = WALKER_START
	var shape_node := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = CAPSULE_RADIUS
	capsule.height = CAPSULE_HEIGHT
	shape_node.shape = capsule
	shape_node.position = Vector3(0.0, CAPSULE_HEIGHT * 0.5, 0.0)
	_walker.add_child(shape_node)
	_visual = Node3D.new()
	_visual.name = "visual"
	_walker.add_child(_visual)
	_elena_node = _instance_asset(_visual, CHARACTER_DIR, "elena_blockout_a", "ElenaBlockout", Vector3.ZERO)
	add_child(_walker)


func _build_camera() -> void:
	var camera: Camera3D = CameraScript.new()
	camera.name = "FollowCamera"
	camera.set("target", _walker)
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


# --- Iluminacion ------------------------------------------------------------------
func _build_environment() -> void:
	_environment = Environment.new()
	_environment.background_mode = Environment.BG_COLOR
	_environment.background_color = BACKGROUND_COLOR
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = AMBIENT_COLOR
	_environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_environment.fog_enabled = true
	var world_environment := WorldEnvironment.new()
	world_environment.name = "LabWorldEnvironment"
	world_environment.environment = _environment
	add_child(world_environment)
	_sun = DirectionalLight3D.new()
	_sun.name = "Sun"
	_sun.rotation_degrees = SUN_ROTATION
	_sun.light_color = SUN_COLOR
	_sun.shadow_enabled = true
	add_child(_sun)
	for index in LAMP_POSITIONS.size():
		var lamp := OmniLight3D.new()
		lamp.name = "Lamp_%d" % index
		lamp.position = LAMP_POSITIONS[index]
		lamp.light_color = LAMP_COLORS[index]
		lamp.omni_range = LAMP_RANGE
		add_child(lamp)
		_lamps.append(lamp)
	_key_light = OmniLight3D.new()
	_key_light.name = "WallLightKey"
	_key_light.position = KEY_LIGHT_POSITION
	_key_light.light_color = KEY_LIGHT_COLOR
	_key_light.omni_range = KEY_LIGHT_RANGE
	_key_light.shadow_enabled = true
	add_child(_key_light)


func _apply_preset(index: int) -> void:
	_preset_index = index
	var preset: Dictionary = PRESETS[index]
	_environment.ambient_light_energy = preset["ambient"]
	_environment.fog_light_color = preset["fog_color"]
	_environment.fog_density = preset["fog_density"]
	_sun.light_energy = preset["sun"]
	_key_light.light_energy = preset["key"]
	var lamp_energy := 1.0 if preset["id"] == "game" else 0.0
	for lamp in _lamps:
		lamp.light_energy = lamp_energy
	if not _capture and not _check:
		print("[lab_kit_art_test_batch1] iluminacion: ", preset["id"])


# --- Encuadres y entrada -----------------------------------------------------------
func _apply_shot(index: int) -> void:
	var shot: Dictionary = SHOTS[index]
	_walker.global_position = shot["pos"]
	_walker.velocity = Vector3.ZERO
	_visual.rotation_degrees.y = shot["yaw"]
	_camera.global_position = _camera.call("_desired")
	if not _capture and not _check:
		print("[lab_kit_art_test_batch1] encuadre %d: %s" % [index + 1, shot["id"]])


func _physics_process(delta: float) -> void:
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
	direction = direction.normalized()
	_walker.velocity.x = direction.x * WALK_SPEED
	_walker.velocity.z = direction.y * WALK_SPEED
	_walker.velocity.y -= GRAVITY * delta
	_walker.move_and_slide()
	if direction != Vector2.ZERO:
		# Misma convencion que elena_controller.gd: frente +Z, giro con atan2(x, z).
		_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(direction.x, direction.y), clampf(TURN_SPEED * delta, 0.0, 1.0))
	if _walker.global_position.y < FALL_RESET_Y:
		_walker.global_position = WALKER_START
		_walker.velocity = Vector3.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if _capture or _check or not (event is InputEventKey):
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
		KEY_O:
			_set_door_open(not _door_open)
			print("[lab_kit_art_test_batch1] puerta ", "abierta" if _door_open else "cerrada")
		KEY_L:
			_apply_preset((_preset_index + 1) % PRESETS.size())
		KEY_G:
			_gray_layer.visible = not _gray_layer.visible
		KEY_P:
			_save_manual_screenshot()


# --- Captura ------------------------------------------------------------------------
func _resolve_capture_dir() -> String:
	var base := _capture_dir if _capture_dir != "" else CAPTURE_DEFAULT_DIR
	return ProjectSettings.globalize_path(base)


func _save_manual_screenshot() -> void:
	var dir_path := _resolve_capture_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	var image := get_viewport().get_texture().get_image()
	var path := dir_path.path_join("lab_kit_batch1_manual_%d.png" % Time.get_ticks_msec())
	if image.save_png(path) == OK:
		print("[lab_kit_art_test_batch1] captura manual guardada: ", path)
	else:
		push_error("[lab_kit_art_test_batch1] no se pudo guardar la captura manual: " + path)


func _capture_sequence() -> void:
	var dir_path := _resolve_capture_dir()
	var dir_err := DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_err != OK:
		push_error("[lab_kit_art_test_batch1] no se pudo crear el directorio (error %d): %s" % [dir_err, dir_path])
		get_tree().quit(1)
		return
	print("[lab_kit_art_test_batch1] modo captura -> ", dir_path)
	var window := get_window()
	window.mode = Window.MODE_WINDOWED
	window.size = CAPTURE_SIZE
	for _frame in CAPTURE_WARMUP_FRAMES:
		await get_tree().process_frame
	var failures := 0
	for preset_index in PRESETS.size():
		_apply_preset(preset_index)
		for shot_index in SHOTS.size():
			_apply_shot(shot_index)
			for gray in [false, true]:
				_gray_layer.visible = gray
				for _frame in CAPTURE_SETTLE_FRAMES:
					await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var image := get_viewport().get_texture().get_image()
				if image.get_size() != CAPTURE_SIZE:
					push_warning("[lab_kit_art_test_batch1] tamano %s distinto de %s; ejecuta en ventana propia." % [image.get_size(), CAPTURE_SIZE])
				var file_name := "lab_kit_batch1_%s_%02d_%s%s.png" % [PRESETS[preset_index]["id"], shot_index + 1, SHOTS[shot_index]["id"], "_gray" if gray else ""]
				var path := dir_path.path_join(file_name)
				var save_err := image.save_png(path)
				if save_err == OK:
					print("[lab_kit_art_test_batch1] guardado: ", path)
				else:
					failures += 1
					push_error("[lab_kit_art_test_batch1] error %d al guardar %s" % [save_err, path])
	_gray_layer.visible = false
	print("[lab_kit_art_test_batch1] captura terminada, fallos: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


# --- Comprobacion automatica -----------------------------------------------------------
func _run_checks() -> void:
	for _frame in CHECK_PHYSICS_FRAMES:
		await get_tree().physics_frame
	var failures := 0
	failures += _check_assets()
	failures += _check_materials()
	failures += _check_fit()
	failures += _check_elena()
	failures += await _check_collisions()
	print("[lab_kit_art_test_batch1] comprobaciones terminadas, fallos: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


func _report(ok: bool, label: String, detail: String = "") -> int:
	print("[lab_kit_art_test_batch1] %s %s%s" % ["PASS" if ok else "FAIL", label, (" | " + detail) if detail != "" else ""])
	return 0 if ok else 1


func _max_abs(v: Vector3) -> float:
	return maxf(maxf(absf(v.x), absf(v.y)), absf(v.z))


func _mesh_instances(root: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		found.append(root as MeshInstance3D)
	for child in root.get_children():
		found.append_array(_mesh_instances(child))
	return found


func _local_aabb(instance: Node3D, within: Node3D) -> AABB:
	var combined := AABB()
	var first := true
	var inverse := within.global_transform.affine_inverse()
	for mesh_instance in _mesh_instances(instance):
		var box := (inverse * mesh_instance.global_transform) * mesh_instance.get_aabb()
		combined = box if first else combined.merge(box)
		first = false
	return combined


func _check_assets() -> int:
	var failures := 0
	for asset_name in EXPECTED_ASSETS:
		if not _instances.has(asset_name):
			failures += _report(false, "medidas y pivote de " + asset_name, "no esta instanciado en la escena")
			continue
		var instance: Node3D = _instances[asset_name]
		var expected: Dictionary = EXPECTED_ASSETS[asset_name]
		var box := _local_aabb(instance, instance)
		var size_ok := _max_abs(box.size - (expected["size"] as Vector3)) <= CHECK_TOLERANCE
		var min_ok := _max_abs(box.position - (expected["min"] as Vector3)) <= CHECK_TOLERANCE
		failures += _report(size_ok and min_ok, "medidas y pivote de " + asset_name, "size=%s esperado=%s min=%s esperado=%s" % [box.size, expected["size"], box.position, expected["min"]])
	return failures


func _check_materials() -> int:
	var failures := 0
	var found: Dictionary = {}
	for asset_name in EXPECTED_ASSETS:
		if not _instances.has(asset_name):
			continue
		for mesh_instance in _mesh_instances(_instances[asset_name]):
			for surface in mesh_instance.mesh.get_surface_count():
				var material := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
				if material != null:
					found[material.resource_name] = material
	for material_name in EXPECTED_COLORS:
		if not found.has(material_name):
			failures += _report(false, "material " + material_name, "no aparece en ningun asset del lote")
			continue
		var material: StandardMaterial3D = found[material_name]
		var wanted := Color(EXPECTED_COLORS[material_name])
		var ok := absf(material.albedo_color.r - wanted.r) <= CHECK_COLOR_TOLERANCE and absf(material.albedo_color.g - wanted.g) <= CHECK_COLOR_TOLERANCE and absf(material.albedo_color.b - wanted.b) <= CHECK_COLOR_TOLERANCE
		var detail := "albedo=%s esperado=%s" % [material.albedo_color.to_html(false), wanted.to_html(false)]
		if EXPECTED_EMISSION.has(material_name):
			var radiance := material.emission.srgb_to_linear() * material.emission_energy_multiplier
			var wanted_radiance := wanted.srgb_to_linear() * float(EXPECTED_EMISSION[material_name])
			var radiance_ok := material.emission_enabled and absf(radiance.r - wanted_radiance.r) <= CHECK_RADIANCE_TOLERANCE and absf(radiance.g - wanted_radiance.g) <= CHECK_RADIANCE_TOLERANCE and absf(radiance.b - wanted_radiance.b) <= CHECK_RADIANCE_TOLERANCE
			ok = ok and radiance_ok
			detail += " radiancia=(%.3f, %.3f, %.3f) esperada=(%.3f, %.3f, %.3f)" % [radiance.r, radiance.g, radiance.b, wanted_radiance.r, wanted_radiance.g, wanted_radiance.b]
		failures += _report(ok, "material " + material_name, detail)
	return failures


func _segment_hits(root: Node3D, from_local: Vector3, to_local: Vector3) -> bool:
	# Rayo contra la geometria visible (TriangleMesh) en el espacio local de `root`.
	var from_world := root.global_transform * from_local
	var to_world := root.global_transform * to_local
	for mesh_instance in _mesh_instances(root):
		if not _triangle_meshes.has(mesh_instance.mesh):
			_triangle_meshes[mesh_instance.mesh] = mesh_instance.mesh.generate_triangle_mesh()
		var triangle_mesh: TriangleMesh = _triangle_meshes[mesh_instance.mesh]
		var inverse := mesh_instance.global_transform.affine_inverse()
		if not triangle_mesh.intersect_segment(inverse * from_world, inverse * to_world).is_empty():
			return true
	return false


func _check_fit() -> int:
	var failures := 0
	# Cobertura del divisor: marco + 2 modulos por lado = 12 m exactos en z.
	var z_min := 1e9
	var z_max := -1e9
	for node in _divider_nodes:
		var box := _local_aabb(node, self)
		z_min = minf(z_min, box.position.z)
		z_max = maxf(z_max, box.end.z)
	failures += _report(absf(z_min + ROOM_HALF_DEPTH) <= CHECK_TOLERANCE and absf(z_max - ROOM_HALF_DEPTH) <= CHECK_TOLERANCE, "marco + modulos cubren 12 m de fondo", "z=[%.3f, %.3f]" % [z_min, z_max])
	# Hueco de 2,8 x 3,0 m libre y jambas macizas (rayos contra la malla del marco).
	var margin := OPENING_HALF_WIDTH - OPENING_PROBE_MARGIN
	failures += _report(not _segment_hits(_frame_node, Vector3(-margin, 1.5, 0.0), Vector3(margin, 1.5, 0.0)), "hueco de 2,8 m libre a 1,5 m de altura")
	failures += _report(not _segment_hits(_frame_node, Vector3(-margin, OPENING_HEIGHT - OPENING_PROBE_MARGIN, 0.0), Vector3(margin, OPENING_HEIGHT - OPENING_PROBE_MARGIN, 0.0)), "hueco libre hasta 3,0 m de altura")
	failures += _report(not _segment_hits(_frame_node, Vector3(0.0, 0.0, -0.4), Vector3(0.0, OPENING_HEIGHT - OPENING_PROBE_MARGIN, -0.4)) and not _segment_hits(_frame_node, Vector3(0.0, 0.0, 0.4), Vector3(0.0, OPENING_HEIGHT - OPENING_PROBE_MARGIN, 0.4)), "umbral sin obstaculos visuales en el hueco")
	failures += _report(_segment_hits(_frame_node, Vector3(-OPENING_HALF_WIDTH - 0.2, 1.5, 0.0), Vector3(-OPENING_HALF_WIDTH + OPENING_PROBE_MARGIN * 0.5, 1.5, 0.0)), "jamba izquierda maciza")
	failures += _report(_segment_hits(_frame_node, Vector3(0.0, OPENING_HEIGHT + 0.3, 0.0), Vector3(0.0, OPENING_HEIGHT + 0.01, 0.0)), "dintel cierra sobre 3,0 m")
	return failures


func _check_elena() -> int:
	var failures := 0
	var box := _local_aabb(_elena_node, _elena_node)
	failures += _report(absf(box.size.y - ELENA_HEIGHT) <= ELENA_HEIGHT_TOLERANCE and absf(box.position.y) <= CHECK_TOLERANCE, "Elena mide 1,70 m con los pies en y=0", "alto=%.3f min_y=%.3f" % [box.size.y, box.position.y])
	var meshes := _mesh_instances(_elena_node)
	var triangles := 0
	for mesh_instance in meshes:
		triangles += mesh_instance.mesh.get_faces().size() / 3
	failures += _report(triangles <= ELENA_MAX_TRIANGLES and meshes.size() <= ELENA_MAX_MESHES, "presupuesto de Elena", "triangulos=%d (max %d) mallas=%d (max %d)" % [triangles, ELENA_MAX_TRIANGLES, meshes.size(), ELENA_MAX_MESHES])
	var missing: Array[String] = []
	for part in ELENA_PARTS:
		if _elena_node.find_child(part, true, false) == null:
			missing.append(part)
	failures += _report(missing.is_empty(), "piezas rigidas de Elena presentes", "faltan=%s" % str(missing))
	failures += _report(_elena_node.find_children("*", "Skeleton3D", true, false).is_empty() and _elena_node.find_children("*", "AnimationPlayer", true, false).is_empty(), "sin esqueleto ni animaciones")
	var backpack := _elena_node.find_child("Backpack", true, false) as Node3D
	var aster := _elena_node.find_child("Aster", true, false) as Node3D
	if backpack != null and aster != null:
		var backpack_z := _local_aabb(backpack, _elena_node).get_center().z
		var aster_z := _local_aabb(aster, _elena_node).get_center().z
		failures += _report(backpack_z < 0.0 and aster_z > 0.0, "frente +Z: mochila detras y Aster delante", "mochila_z=%.3f aster_z=%.3f" % [backpack_z, aster_z])
	else:
		failures += _report(false, "frente +Z", "no se encuentran Backpack o Aster")
	return failures


func _cast(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, COLLISION_WORLD)
	return get_world_3d().direct_space_state.intersect_ray(query)


func _check_ray(label: String, from: Vector3, to: Vector3, axis: int, expected: float, body_name: String) -> int:
	var hit := _cast(from, to)
	if hit.is_empty():
		return _report(false, "colision " + label, "el rayo no golpea nada")
	var point: Vector3 = hit["position"]
	var collider := hit["collider"] as Node
	var ok := absf(point[axis] - expected) <= CHECK_TOLERANCE and collider.name == body_name
	return _report(ok, "colision " + label, "punto=%s esperado[%d]=%.3f collider=%s esperado=%s" % [point, axis, expected, collider.name, body_name])


func _check_collisions() -> int:
	var failures := 0
	failures += _check_ray("suelo", Vector3(13.0, 3.0, 3.0), Vector3(13.0, -1.0, 3.0), Vector3.AXIS_Y, 0.0, "FloorCollider")
	failures += _check_ray("muro del fondo", Vector3(14.0, 1.0, 0.0), Vector3(14.0, 1.0, -7.0), Vector3.AXIS_Z, -ROOM_HALF_DEPTH, "WallBackCollider")
	failures += _check_ray("muro bajo", Vector3(14.0, 0.5, 0.0), Vector3(14.0, 0.5, 7.0), Vector3.AXIS_Z, ROOM_HALF_DEPTH, "WallLowCollider")
	failures += _check_ray("brazo del divisor", Vector3(14.0, 1.0, 4.0), Vector3(18.0, 1.0, 4.0), Vector3.AXIS_X, DIVIDER_X - DIVIDER_THICKNESS * 0.5, "DividerArmCollider_1")
	_set_door_open(false)
	await get_tree().physics_frame
	failures += _check_ray("puerta cerrada", Vector3(14.0, 1.0, 0.0), Vector3(18.0, 1.0, 0.0), Vector3.AXIS_X, DIVIDER_X - DOOR_SIZE.x * 0.5, "DoorSlab")
	var blocked := _walker.test_move(Transform3D(Basis(), Vector3(14.0, 0.05, 0.0)), Vector3(4.0, 0.0, 0.0))
	failures += _report(blocked, "Elena no atraviesa la puerta cerrada")
	_set_door_open(true)
	await get_tree().physics_frame
	failures += _report(_cast(Vector3(14.0, 1.0, 0.0), Vector3(18.0, 1.0, 0.0)).is_empty(), "puerta abierta: el rayo no golpea nada")
	var passes := not _walker.test_move(Transform3D(Basis(), Vector3(14.0, 0.05, 0.0)), Vector3(4.0, 0.0, 0.0))
	failures += _report(passes, "Elena (capsulo r 0,32 / h 1,7) cruza el hueco abierto")
	return failures
