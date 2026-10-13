extends Node3D
## Prueba aislada del lote 2: props interactivos de las salas 1 y 2.
##
## Cada prop se coloca sobre el origen del componente de gameplay que vestira y se puede
## superponer el volumen del greybox (tecla V) para ver que el arte respeta el hueco, los
## colisionadores y el punto de interaccion. Las partes emisivas (emit_*) se recolorean como
## lo hacen los scripts (B.set_glow / material_override). No es un nivel: no usa
## abandoned_lab.tscn, autoloads ni input actions (solo teclas fisicas) ni scripts de
## gameplay, y usa follow_camera.gd sin modificar.
##
## Interactivo (desde la raiz del proyecto):
##   godot --path . res://scenes/levels/art_tests/lab_props_art_test_batch2.tscn
##   A/D o flechas: prop anterior/siguiente | 1-9, 0: saltar a un prop | V volumen del greybox
##   C estados emisivos | K palanca | O puerta | G grises | P captura manual
## Captura (PNG 1280x720 y sale; 10 props x color / grises / volumen):
##   godot --path . res://scenes/levels/art_tests/lab_props_art_test_batch2.tscn -- --capture --capture-dir=C:/ruta/evidencia
## Comprobacion automatica:
##   godot --headless --path . res://scenes/levels/art_tests/lab_props_art_test_batch2.tscn -- --check

const CameraScript = preload("res://scripts/components/follow_camera.gd")

const LAB_DIR := "res://assets/models/lab/"
const CHARACTER_DIR := "res://assets/models/characters/"

# --- Distribucion ---------------------------------------------------------------
const PROP_SPACING := 5.0
const FLOOR_COLUMNS := 30
const FLOOR_ROWS := 4
const FLOOR_X_START := -4.0
const MODULE := 2.0
const BACK_WALL_Z := -4.0
const ELENA_REFERENCE_POSITION := Vector3(-2.5, 0.0, 1.5)
const POLE_POSITION := Vector3(-1.8, 0.0, 1.5)
const POLE_HEIGHT := 1.7
const POLE_WIDTH := 0.04

# --- Estados emisivos (mismos colores que los scripts de gameplay) ----------------
const STATE_COLORS := [Color(0.95, 0.7, 0.25), Color(0.85, 0.2, 0.2), Color(0.2, 0.9, 0.5), Color(0.2, 0.7, 0.9)]
const STATE_ENERGY := 2.0
const LEVER_ANGLE_ON := 35.0
const LEVER_ANGLE_OFF := -35.0
const DOOR_OPEN_OFFSET := 2.8
const GEM_BOB_HEIGHT := 0.1
const GEM_BOB_SPEED := 2.0
const GEM_SPIN_DEGREES_PER_SECOND := 40.0

# --- Props: volumen del greybox (relativo al origen del componente) y nodos --------
# triangles_max: presupuesto de la spec. emit: nodos que el gameplay recolorea.
const PROPS := [
	{"asset": "lab_power_node_a", "id": "power_node", "min": Vector3(-0.5, 0.0, -0.5), "max": Vector3(0.5, 1.13, 0.5), "emit": ["emit_orb", "emit_ring"], "triangles_max": 600},
	{"asset": "lab_junction_box_a", "id": "junction_box", "min": Vector3(-0.55, 0.0, -0.3), "max": Vector3(0.55, 1.0, 0.355), "emit": ["emit_lamp"], "triangles_max": 600},
	{"asset": "lab_terminal_power_a", "id": "terminal", "min": Vector3(-0.5, 0.0, -0.35), "max": Vector3(0.5, 1.47, 0.36), "emit": ["emit_screen"], "triangles_max": 600},
	{"asset": "lab_lever_a", "id": "lever", "min": Vector3(-0.45, 0.0, -0.3), "max": Vector3(0.45, 1.6, 0.335), "emit": ["emit_lamp", "emit_knob"], "triangles_max": 600},
	{"asset": "lab_button_pedestal_a", "id": "button", "min": Vector3(-0.25, 0.0, -0.25), "max": Vector3(0.25, 0.8, 0.25), "emit": ["emit_cap"], "triangles_max": 600},
	{"asset": "lab_door_slab_a", "id": "door", "min": Vector3(-0.3, 0.0, -1.55), "max": Vector3(0.3, 3.245, 1.55), "emit": ["emit_strip"], "triangles_max": 600},
	{"asset": "lab_robotic_arm_a", "id": "robotic_arm", "min": Vector3(-0.6, 0.0, -1.6), "max": Vector3(0.6, 2.2, 3.2), "emit": [], "triangles_max": 1000, "focus": Vector3(0.0, 0.0, 0.8)},
	{"asset": "lab_checkpoint_arch_a", "id": "checkpoint", "min": Vector3(-0.1, 0.0, -1.3), "max": Vector3(0.1, 2.7, 1.3), "emit": ["emit_arch_post_L", "emit_arch_post_R", "emit_arch_lintel"], "triangles_max": 600},
	{"asset": "lab_memory_fragment_a", "id": "memory_fragment", "min": Vector3(-0.3, 0.0, -0.3), "max": Vector3(0.3, 1.3, 0.3), "emit": ["emit_gem"], "triangles_max": 600},
	{"asset": "lab_console_a", "id": "console", "min": Vector3(-0.35, 0.0, -0.25), "max": Vector3(0.35, 1.0, 0.29), "emit": ["emit_screen"], "triangles_max": 600},
]

# --- Iluminacion -------------------------------------------------------------------
const BACKGROUND_COLOR := Color(0.02, 0.03, 0.05)
const AMBIENT_COLOR := Color(0.35, 0.42, 0.5)
const AMBIENT_ENERGY := 0.35
const FOG_COLOR := Color(0.08, 0.11, 0.15)
const FOG_DENSITY := 0.012
const SUN_ROTATION := Vector3(-60.0, -30.0, 0.0)
const SUN_COLOR := Color(0.7, 0.8, 1.0)
const SUN_ENERGY := 0.35
const FOCUS_LIGHT_OFFSET := Vector3(0.0, 3.0, 1.5)
const FOCUS_LIGHT_ENERGY := 1.4
const FOCUS_LIGHT_RANGE := 9.0
const FOCUS_LIGHT_COLOR := Color(0.8, 0.9, 1.0)
const VOLUME_COLOR := Color(1.0, 0.35, 0.1)

# --- Captura ------------------------------------------------------------------------
const CAPTURE_SIZE := Vector2i(1280, 720)
const CAPTURE_WARMUP_FRAMES := 20
const CAPTURE_SETTLE_FRAMES := 4
const CAPTURE_DEFAULT_DIR := "user://lab_props_art_test_batch2"
const GRAYSCALE_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
void fragment() {
	vec3 c = texture(screen_texture, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
	COLOR = vec4(vec3(l), 1.0);
}
"""

# --- Comprobacion automatica ------------------------------------------------------------
const CHECK_TOLERANCE := 0.01
const CHECK_CONTAIN_TOLERANCE := 0.05
const CHECK_COVER_TOLERANCE := 0.25
const CHECK_COLOR_TOLERANCE := 0.01
const CHECK_RADIANCE_TOLERANCE := 0.02
const CHECK_PHYSICS_FRAMES := 2
const LEVER_PIVOT := Vector3(0.0, 0.55, 0.0)
const LEVER_KNOB_DISTANCE := 0.95
const GEM_ORIGIN := Vector3(0.0, 1.0, 0.0)
const DOOR_SLAB_ORIGIN := Vector3(0.0, 1.5, 0.0)
const EXPECTED_COLORS := {
	"lab_mat_painted_metal": "56656C", "lab_mat_trim_metal": "3B4347", "lab_mat_rubber": "1E2124",
	"lab_mat_screen_emissive": "F2B340", "lab_mat_arm_orange": "E6801F", "lab_mat_state_red": "D93333",
	"lab_mat_state_green": "33E680", "lab_mat_state_cyan": "33B3E6", "lab_mat_state_gem": "4DE6FF",
	"lab_mat_state_console": "4DCCE6",
}
const EXPECTED_EMISSION := {
	"lab_mat_screen_emissive": 2.0, "lab_mat_state_red": 2.0, "lab_mat_state_green": 2.0,
	"lab_mat_state_cyan": 2.0, "lab_mat_state_gem": 3.0, "lab_mat_state_console": 1.2,
}

var _capture: bool = false
var _capture_dir: String = ""
var _check: bool = false
var _environment: Environment
var _focus_light: OmniLight3D
var _focus: Node3D
var _camera: Camera3D
var _gray_layer: CanvasLayer
var _index: int = 0
var _state_index: int = 0
var _lever_on: bool = false
var _door_open: bool = false
var _volumes_visible: bool = false
var _time: float = 0.0
var _holders: Array[Node3D] = []
var _instances: Array[Node3D] = []
var _volumes: Array[MeshInstance3D] = []
var _recolored: Dictionary = {}


func _ready() -> void:
	_parse_args()
	_build_environment()
	_build_dressing()
	_build_props()
	_build_scale_references()
	_build_camera()
	_build_grayscale_overlay()
	_apply_shot(0)
	if _capture:
		_capture_sequence()
	elif _check:
		_run_checks()
	else:
		print("[lab_props_art_test_batch2] A/D o 1-0 props | V volumen | C estados | K palanca | O puerta | G grises | P captura")


func _parse_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture":
			_capture = true
		elif arg == "--check":
			_check = true
		elif arg.begins_with("--capture-dir="):
			_capture_dir = arg.substr("--capture-dir=".length())


# --- Montaje ---------------------------------------------------------------------------
func _load_asset(directory: String, asset_name: String) -> Node3D:
	return (load(directory + asset_name + ".glb") as PackedScene).instantiate() as Node3D


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
	var world_environment := WorldEnvironment.new()
	world_environment.name = "LabWorldEnvironment"
	world_environment.environment = _environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = SUN_ROTATION
	sun.light_color = SUN_COLOR
	sun.light_energy = SUN_ENERGY
	sun.shadow_enabled = true
	add_child(sun)
	_focus_light = OmniLight3D.new()
	_focus_light.name = "FocusLight"
	_focus_light.light_color = FOCUS_LIGHT_COLOR
	_focus_light.light_energy = FOCUS_LIGHT_ENERGY
	_focus_light.omni_range = FOCUS_LIGHT_RANGE
	_focus_light.shadow_enabled = true
	add_child(_focus_light)


func _build_dressing() -> void:
	var root := Node3D.new()
	root.name = "LabDressing"
	add_child(root)
	for column in FLOOR_COLUMNS:
		for row in FLOOR_ROWS:
			var tile := _load_asset(LAB_DIR, "lab_floor_2x2_a")
			tile.name = "FloorTile_%d_%d" % [column, row]
			tile.position = Vector3(FLOOR_X_START + MODULE * 0.5 + MODULE * column, 0.0, BACK_WALL_Z + MODULE * 0.5 + MODULE * row)
			root.add_child(tile)
		var wall := _load_asset(LAB_DIR, "lab_wall_2m_a")
		wall.name = "WallBack_%d" % column
		wall.position = Vector3(FLOOR_X_START + MODULE * 0.5 + MODULE * column, 0.0, BACK_WALL_Z)
		root.add_child(wall)


func _build_props() -> void:
	for index in PROPS.size():
		var spec: Dictionary = PROPS[index]
		var holder := Node3D.new()
		holder.name = "Prop_" + String(spec["id"])
		holder.position = Vector3(index * PROP_SPACING, 0.0, 0.0)
		add_child(holder)
		var instance := _load_asset(LAB_DIR, spec["asset"])
		instance.name = spec["asset"]
		holder.add_child(instance)
		var volume := _make_volume(spec["min"], spec["max"])
		volume.visible = false
		holder.add_child(volume)
		_holders.append(holder)
		_instances.append(instance)
		_volumes.append(volume)


func _make_volume(low: Vector3, high: Vector3) -> MeshInstance3D:
	# Aristas del volumen del greybox (colisionador/zona de interaccion) como lineas.
	var corners: Array[Vector3] = []
	for x in [low.x, high.x]:
		for y in [low.y, high.y]:
			for z in [low.z, high.z]:
				corners.append(Vector3(x, y, z))
	var immediate := ImmediateMesh.new()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)
	for a in corners.size():
		for b in range(a + 1, corners.size()):
			var diff := corners[a] - corners[b]
			var differing_axes := 0
			for axis in 3:
				if absf(diff[axis]) > 0.0:
					differing_axes += 1
			if differing_axes == 1:
				immediate.surface_add_vertex(corners[a])
				immediate.surface_add_vertex(corners[b])
	immediate.surface_end()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = VOLUME_COLOR
	material.no_depth_test = true
	immediate.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = "GreyboxVolume"
	instance.mesh = immediate
	return instance


func _build_scale_references() -> void:
	var elena := _load_asset(CHARACTER_DIR, "elena_blockout_a")
	elena.name = "ElenaBlockout"
	elena.position = ELENA_REFERENCE_POSITION
	add_child(elena)
	var pole := MeshInstance3D.new()
	pole.name = "ScalePole"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(POLE_WIDTH, POLE_HEIGHT, POLE_WIDTH)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.95, 0.95)
	mesh.material = material
	pole.mesh = mesh
	pole.position = POLE_POSITION + Vector3(0.0, POLE_HEIGHT * 0.5, 0.0)
	add_child(pole)


func _build_camera() -> void:
	_focus = Node3D.new()
	_focus.name = "CameraFocus"
	add_child(_focus)
	var camera: Camera3D = CameraScript.new()
	camera.name = "FollowCamera"
	camera.set("target", _focus)
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


# --- Estados y animacion (replican lo que hacen los scripts) -------------------------------
func _node(instance: Node3D, node_name: String) -> Node3D:
	return instance.find_child(node_name, true, false) as Node3D


func _recolor(mesh_instance: MeshInstance3D, color: Color, energy: float) -> void:
	# Igual que B.set_glow: material propio por instancia (el material del GLB es compartido).
	var key := mesh_instance.get_instance_id()
	if not _recolored.has(key):
		var base := mesh_instance.mesh.surface_get_material(0) as StandardMaterial3D
		_recolored[key] = base.duplicate() as StandardMaterial3D
		mesh_instance.set_surface_override_material(0, _recolored[key])
	var material: StandardMaterial3D = _recolored[key]
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy


func _cycle_state() -> void:
	_state_index = (_state_index + 1) % STATE_COLORS.size()
	for index in PROPS.size():
		for node_name in PROPS[index]["emit"]:
			var node := _node(_instances[index], node_name) as MeshInstance3D
			if node != null:
				_recolor(node, STATE_COLORS[_state_index], STATE_ENERGY)


func _set_lever(on: bool) -> void:
	_lever_on = on
	var arm := _node(_instances[3], "LeverArm")
	arm.rotation_degrees.z = LEVER_ANGLE_ON if on else LEVER_ANGLE_OFF


func _set_door(open: bool) -> void:
	_door_open = open
	_node(_instances[5], "DoorSlab").position.z = DOOR_SLAB_ORIGIN.z + (DOOR_OPEN_OFFSET if open else 0.0)


func _process(delta: float) -> void:
	if _capture or _check:
		return
	_time += delta
	var gem := _node(_instances[8], "emit_gem")
	gem.position.y = GEM_ORIGIN.y + GEM_BOB_HEIGHT * sin(_time * GEM_BOB_SPEED)
	gem.rotation_degrees.y += GEM_SPIN_DEGREES_PER_SECOND * delta


# --- Encuadres e input ------------------------------------------------------------------------
func _apply_shot(index: int) -> void:
	_index = posmod(index, PROPS.size())
	var spec: Dictionary = PROPS[_index]
	var offset: Vector3 = spec.get("focus", Vector3.ZERO)
	_focus.global_position = _holders[_index].global_position + offset
	_focus_light.global_position = _focus.global_position + FOCUS_LIGHT_OFFSET
	_camera.global_position = _camera.call("_desired")
	if not _capture and not _check:
		print("[lab_props_art_test_batch2] prop %d: %s" % [_index + 1, spec["id"]])


func _set_volumes_visible(value: bool) -> void:
	_volumes_visible = value
	for volume in _volumes:
		volume.visible = value


func _unhandled_input(event: InputEvent) -> void:
	if _capture or _check or not (event is InputEventKey):
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_D, KEY_RIGHT:
			_apply_shot(_index + 1)
		KEY_A, KEY_LEFT:
			_apply_shot(_index - 1)
		KEY_0:
			_apply_shot(9)
		KEY_V:
			_set_volumes_visible(not _volumes_visible)
		KEY_C:
			_cycle_state()
		KEY_K:
			_set_lever(not _lever_on)
		KEY_O:
			_set_door(not _door_open)
		KEY_G:
			_gray_layer.visible = not _gray_layer.visible
		KEY_P:
			_save_manual_screenshot()
		_:
			var code := int(key.keycode)
			if code >= int(KEY_1) and code <= int(KEY_9):
				_apply_shot(code - int(KEY_1))


# --- Captura ---------------------------------------------------------------------------------------
func _resolve_capture_dir() -> String:
	var base := _capture_dir if _capture_dir != "" else CAPTURE_DEFAULT_DIR
	return ProjectSettings.globalize_path(base)


func _save_manual_screenshot() -> void:
	var dir_path := _resolve_capture_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	var image := get_viewport().get_texture().get_image()
	var path := dir_path.path_join("lab_props_batch2_manual_%d.png" % Time.get_ticks_msec())
	if image.save_png(path) == OK:
		print("[lab_props_art_test_batch2] captura manual guardada: ", path)
	else:
		push_error("[lab_props_art_test_batch2] no se pudo guardar la captura manual: " + path)


func _capture_sequence() -> void:
	var dir_path := _resolve_capture_dir()
	var dir_err := DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_err != OK:
		push_error("[lab_props_art_test_batch2] no se pudo crear el directorio (error %d): %s" % [dir_err, dir_path])
		get_tree().quit(1)
		return
	print("[lab_props_art_test_batch2] modo captura -> ", dir_path)
	var window := get_window()
	window.mode = Window.MODE_WINDOWED
	window.size = CAPTURE_SIZE
	for _frame in CAPTURE_WARMUP_FRAMES:
		await get_tree().process_frame
	var failures := 0
	var variants := [{"suffix": "", "gray": false, "volume": false}, {"suffix": "_gray", "gray": true, "volume": false}, {"suffix": "_volume", "gray": false, "volume": true}]
	for index in PROPS.size():
		_apply_shot(index)
		for variant in variants:
			_gray_layer.visible = variant["gray"]
			_set_volumes_visible(variant["volume"])
			for _frame in CAPTURE_SETTLE_FRAMES:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image := get_viewport().get_texture().get_image()
			if image.get_size() != CAPTURE_SIZE:
				push_warning("[lab_props_art_test_batch2] tamano %s distinto de %s; ejecuta en ventana propia." % [image.get_size(), CAPTURE_SIZE])
			var file_name := "lab_props_batch2_%02d_%s%s.png" % [index + 1, PROPS[index]["id"], variant["suffix"]]
			var path := dir_path.path_join(file_name)
			var save_err := image.save_png(path)
			if save_err == OK:
				print("[lab_props_art_test_batch2] guardado: ", path)
			else:
				failures += 1
				push_error("[lab_props_art_test_batch2] error %d al guardar %s" % [save_err, path])
	_gray_layer.visible = false
	_set_volumes_visible(false)
	print("[lab_props_art_test_batch2] captura terminada, fallos: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


# --- Comprobacion automatica -------------------------------------------------------------------------
func _run_checks() -> void:
	for _frame in CHECK_PHYSICS_FRAMES:
		await get_tree().physics_frame
	var failures := 0
	failures += _check_volumes()
	failures += _check_budget_and_nodes()
	failures += _check_materials()
	failures += _check_pivots()
	failures += _check_recolor()
	print("[lab_props_art_test_batch2] comprobaciones terminadas, fallos: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


func _report(ok: bool, label: String, detail: String = "") -> int:
	print("[lab_props_art_test_batch2] %s %s%s" % ["PASS" if ok else "FAIL", label, (" | " + detail) if detail != "" else ""])
	return 0 if ok else 1


func _mesh_instances(root: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		found.append(root as MeshInstance3D)
	for child in root.get_children():
		found.append_array(_mesh_instances(child))
	return found


func _local_aabb(instance: Node3D) -> AABB:
	var combined := AABB()
	var first := true
	var inverse := instance.global_transform.affine_inverse()
	for mesh_instance in _mesh_instances(instance):
		var box := (inverse * mesh_instance.global_transform) * mesh_instance.get_aabb()
		combined = box if first else combined.merge(box)
		first = false
	return combined


func _check_volumes() -> int:
	var failures := 0
	for index in PROPS.size():
		var spec: Dictionary = PROPS[index]
		var box := _local_aabb(_instances[index])
		var low: Vector3 = spec["min"]
		var high: Vector3 = spec["max"]
		var inside := box.position.x >= low.x - CHECK_CONTAIN_TOLERANCE and box.position.y >= low.y - CHECK_CONTAIN_TOLERANCE and box.position.z >= low.z - CHECK_CONTAIN_TOLERANCE and box.end.x <= high.x + CHECK_CONTAIN_TOLERANCE and box.end.y <= high.y + CHECK_CONTAIN_TOLERANCE and box.end.z <= high.z + CHECK_CONTAIN_TOLERANCE
		var covers := box.size.x >= (high.x - low.x) - CHECK_COVER_TOLERANCE and box.size.y >= (high.y - low.y) - CHECK_COVER_TOLERANCE and box.size.z >= (high.z - low.z) - CHECK_COVER_TOLERANCE
		var grounded := absf(box.position.y) <= CHECK_TOLERANCE
		failures += _report(inside and covers and grounded, "volumen y base de " + String(spec["asset"]), "aabb=[%s .. %s] volumen=[%s .. %s]" % [box.position, box.end, low, high])
	return failures


func _check_budget_and_nodes() -> int:
	var failures := 0
	for index in PROPS.size():
		var spec: Dictionary = PROPS[index]
		var triangles := 0
		for mesh_instance in _mesh_instances(_instances[index]):
			triangles += mesh_instance.mesh.get_faces().size() / 3
		failures += _report(triangles <= int(spec["triangles_max"]), "presupuesto de " + String(spec["asset"]), "triangulos=%d (max %d)" % [triangles, spec["triangles_max"]])
		var main_materials: Dictionary = {}
		var emit_materials: Dictionary = {}
		var missing: Array[String] = []
		for node_name in spec["emit"]:
			var node := _node(_instances[index], node_name) as MeshInstance3D
			if node == null:
				missing.append(node_name)
				continue
			var material := node.mesh.surface_get_material(0) as StandardMaterial3D
			if material == null or not material.emission_enabled:
				missing.append(node_name + " (sin emision)")
			else:
				emit_materials[node_name] = material
		for mesh_instance in _mesh_instances(_instances[index]):
			if String(mesh_instance.name).begins_with("emit_"):
				continue
			for surface in mesh_instance.mesh.get_surface_count():
				main_materials[mesh_instance.mesh.surface_get_material(surface)] = true
		var shared := false
		for material in emit_materials.values():
			if main_materials.has(material):
				shared = true
		failures += _report(missing.is_empty() and not shared, "partes emisivas recoloreables de " + String(spec["asset"]), "faltan=%s material_compartido_con_el_resto=%s" % [str(missing), str(shared)])
	return failures


func _check_materials() -> int:
	var failures := 0
	var found: Dictionary = {}
	for instance in _instances:
		for mesh_instance in _mesh_instances(instance):
			for surface in mesh_instance.mesh.get_surface_count():
				var material := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
				if material != null:
					found[material.resource_name] = material
	for material_name in EXPECTED_COLORS:
		if not found.has(material_name):
			failures += _report(false, "material " + material_name, "no aparece en ningun prop")
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


func _check_pivots() -> int:
	var failures := 0
	var arm := _node(_instances[3], "LeverArm")
	var knob := _node(_instances[3], "emit_knob")
	failures += _report(arm.position.is_equal_approx(LEVER_PIVOT) or (arm.position - LEVER_PIVOT).length() <= CHECK_TOLERANCE, "pivote de la palanca en (0, 0,55, 0)", "pos=%s" % arm.position)
	_set_lever(true)
	var pivot_world := arm.global_position
	var distance_on := knob.global_position.distance_to(pivot_world)
	var moved := absf(knob.global_position.x - pivot_world.x) > 0.3
	_set_lever(false)
	var distance_off := knob.global_position.distance_to(pivot_world)
	failures += _report(moved and absf(distance_on - LEVER_KNOB_DISTANCE) <= CHECK_TOLERANCE and absf(distance_off - LEVER_KNOB_DISTANCE) <= CHECK_TOLERANCE, "la empunadura gira alrededor del pivote a 0,95 m", "distancias=%.3f / %.3f" % [distance_on, distance_off])
	var gem := _node(_instances[8], "emit_gem")
	failures += _report((gem.position - GEM_ORIGIN).length() <= CHECK_TOLERANCE, "gema con origen en (0, 1,0, 0) para la animacion del script", "pos=%s" % gem.position)
	var slab := _node(_instances[5], "DoorSlab")
	var strip := _node(_instances[5], "emit_strip")
	failures += _report((slab.position - DOOR_SLAB_ORIGIN).length() <= CHECK_TOLERANCE and strip.position.length() <= CHECK_TOLERANCE, "losa en (0, 1,5, 0) y franja en el origen de la puerta", "losa=%s franja=%s" % [slab.position, strip.position])
	var strip_before := strip.global_position
	_set_door(true)
	failures += _report(absf(slab.position.z - DOOR_OPEN_OFFSET) <= CHECK_TOLERANCE and strip.global_position.is_equal_approx(strip_before), "al abrir, la losa se desplaza 2,8 m y la franja no se mueve")
	_set_door(false)
	return failures


func _check_recolor() -> int:
	# Recolorear un prop no debe contaminar a otra instancia del mismo asset.
	var failures := 0
	var other := _load_asset(LAB_DIR, "lab_console_a")
	add_child(other)
	var screen_a := _node(_instances[9], "emit_screen") as MeshInstance3D
	var screen_b := _node(other, "emit_screen") as MeshInstance3D
	var shared_before := screen_a.mesh.surface_get_material(0) == screen_b.mesh.surface_get_material(0)
	var original := (screen_b.mesh.surface_get_material(0) as StandardMaterial3D).albedo_color
	_recolor(screen_a, Color(1.0, 0.0, 0.0), 2.0)
	var untouched := ((screen_b.get_active_material(0)) as StandardMaterial3D).albedo_color.is_equal_approx(original)
	var changed := ((screen_a.get_active_material(0)) as StandardMaterial3D).albedo_color.is_equal_approx(Color(1.0, 0.0, 0.0))
	failures += _report(shared_before and untouched and changed, "recolorear con material propio no contamina otras instancias", "material_del_GLB_compartido=%s" % str(shared_before))
	other.queue_free()
	return failures
