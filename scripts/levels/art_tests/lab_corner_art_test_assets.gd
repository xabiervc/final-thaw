extends "res://scripts/levels/art_tests/lab_palette_test.gd"
## Prueba aislada del primer lote de arte del rincon de laboratorio (assets GLB).
##
## Hereda de lab_palette_test.gd (sin modificarlo): entorno, luz clave, acento ambar,
## Elena de referencia, camara existente (follow_camera.gd), encuadres, escala de
## grises y modo captura son los mismos. Solo sustituye las primitivas del rincon
## por los assets de assets/models/lab/ y anade colisiones simples. No es un nivel:
## no usa abandoned_lab.tscn, autoloads ni input actions.
##
## Ejecucion interactiva (teclas identicas a lab_palette_test):
##   godot --path . res://scenes/levels/art_tests/lab_corner_art_test_assets.tscn
## Captura (usa un directorio distinto al de la prueba de paleta; los nombres de
## archivo coinciden con los de esa prueba para poder compararlos lado a lado):
##   godot --path . res://scenes/levels/art_tests/lab_corner_art_test_assets.tscn -- --capture --capture-dir=C:/ruta/evidencia
## Comprobacion automatica (medidas/pivotes/materiales de los GLB y colisiones):
##   godot --headless --path . res://scenes/levels/art_tests/lab_corner_art_test_assets.tscn -- --check
##
## Los assets se generan con tools/blender/build_lab_corner_assets.py; la
## especificacion esta en docs/art/LAB_STYLE_SPEC.md.

const ASSET_DIR := "res://assets/models/lab/"
const CAPTURE_DIR_ASSETS := "user://lab_corner_art_test_assets"

# --- Modulos (metros) ---------------------------------------------------------
const FLOOR_TILE_SIZE := 2.0
const WALL_MODULE_WIDTH := 2.0
const LEFT_WALL_YAW_DEGREES := 90.0

# --- Colisiones simples (patron del proyecto: StaticBody3D, capa 1, mascara 0) --
const COLLISION_LAYER_WORLD := 1
const FLOOR_COLLIDER_THICKNESS := 0.5
const TERMINAL_COLLIDER_SIZE := Vector3(1.0, 1.5, 0.7)
const CONTAINER_COLLIDER_SIZE := Vector3(1.24, 1.0, 0.84)

# --- Comprobacion automatica ---------------------------------------------------
const CHECK_TOLERANCE := 0.01
const CHECK_COLOR_TOLERANCE := 0.01
const CHECK_RADIANCE_TOLERANCE := 0.02
const CHECK_PHYSICS_FRAMES := 2
const RAY_ABOVE := 3.0
# Por asset: tamano del AABB y esquina minima, respecto al pivote del asset.
const EXPECTED_ASSETS := {
	"lab_floor_2x2_a": {"size": Vector3(2.0, 0.1, 2.0), "min": Vector3(-1.0, -0.1, -1.0)},
	"lab_wall_2m_a": {"size": Vector3(2.0, 3.2, 0.53), "min": Vector3(-1.0, 0.0, -0.5)},
	"lab_wall_corner_a": {"size": Vector3(0.56, 3.2, 0.56), "min": Vector3(-0.5, 0.0, -0.5)},
	"lab_terminal_a": {"size": Vector3(1.04, 1.463, 0.74), "min": Vector3(-0.52, 0.0, -0.37)},
	"lab_container_a": {"size": Vector3(1.24, 1.0, 0.88), "min": Vector3(-0.62, 0.0, -0.42)},
	"lab_wall_light_a": {"size": Vector3(0.8, 0.2, 0.26), "min": Vector3(-0.4, -0.1, -0.125)},
}
const EXPECTED_EMISSION := {"lab_mat_screen_emissive": 2.0, "lab_mat_light_emissive": 2.5}

var _check: bool = false
var _asset_instances: Dictionary = {}


func _ready() -> void:
	super._ready()
	if _check:
		_run_checks()


func _parse_args() -> void:
	super._parse_args()
	for arg in OS.get_cmdline_user_args():
		if arg == "--check":
			_check = true


func _resolve_capture_dir() -> String:
	var base := _capture_dir if _capture_dir != "" else CAPTURE_DIR_ASSETS
	return ProjectSettings.globalize_path(base)


# --- Montaje ------------------------------------------------------------------
func _instance_asset(parent: Node3D, asset_name: String, node_name: String, pos: Vector3, yaw_degrees: float = 0.0) -> Node3D:
	var packed := load(ASSET_DIR + asset_name + ".glb") as PackedScene
	var instance := packed.instantiate() as Node3D
	instance.name = node_name
	instance.position = pos
	instance.rotation_degrees.y = yaw_degrees
	parent.add_child(instance)
	_asset_instances[node_name] = {"asset": asset_name, "node": instance}
	return instance


func _add_collider(parent: Node3D, node_name: String, size: Vector3, pos: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	body.collision_layer = COLLISION_LAYER_WORLD
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
	var floor_root := Node3D.new()
	floor_root.name = "LabFloor"
	add_child(floor_root)
	var columns := int(FLOOR_SIZE.x / FLOOR_TILE_SIZE)
	var rows := int(FLOOR_SIZE.y / FLOOR_TILE_SIZE)
	for column in columns:
		for row in rows:
			var x := -FLOOR_SIZE.x * 0.5 + FLOOR_TILE_SIZE * 0.5 + FLOOR_TILE_SIZE * column
			var z := -FLOOR_SIZE.y * 0.5 + FLOOR_TILE_SIZE * 0.5 + FLOOR_TILE_SIZE * row
			_instance_asset(floor_root, "lab_floor_2x2_a", "FloorTile_%d_%d" % [column, row], Vector3(x, 0.0, z))
	_add_collider(floor_root, "FloorCollider", Vector3(FLOOR_SIZE.x, FLOOR_COLLIDER_THICKNESS, FLOOR_SIZE.y), Vector3(0.0, -FLOOR_COLLIDER_THICKNESS * 0.5, 0.0))


func _build_walls() -> void:
	var wall_root := Node3D.new()
	wall_root.name = "LabWalls"
	add_child(wall_root)
	var half_x := FLOOR_SIZE.x * 0.5
	var half_z := FLOOR_SIZE.y * 0.5
	var back_count := int(FLOOR_SIZE.x / WALL_MODULE_WIDTH)
	var left_count := int(FLOOR_SIZE.y / WALL_MODULE_WIDTH)
	for index in back_count:
		var x := -half_x + WALL_MODULE_WIDTH * 0.5 + WALL_MODULE_WIDTH * index
		_instance_asset(wall_root, "lab_wall_2m_a", "WallBack_%d" % index, Vector3(x, 0.0, -half_z))
	for index in left_count:
		var z := -half_z + WALL_MODULE_WIDTH * 0.5 + WALL_MODULE_WIDTH * index
		_instance_asset(wall_root, "lab_wall_2m_a", "WallLeft_%d" % index, Vector3(-half_x, 0.0, z), LEFT_WALL_YAW_DEGREES)
	_instance_asset(wall_root, "lab_wall_corner_a", "WallCorner", Vector3(-half_x, 0.0, -half_z))
	# Mismos volumenes que las paredes de lab_palette_test (la del fondo cubre la esquina).
	var wall_y := WALL_HEIGHT * 0.5
	_add_collider(wall_root, "WallBackCollider", Vector3(FLOOR_SIZE.x + WALL_THICKNESS, WALL_HEIGHT, WALL_THICKNESS), Vector3(-WALL_THICKNESS * 0.5, wall_y, -half_z - WALL_THICKNESS * 0.5))
	_add_collider(wall_root, "WallLeftCollider", Vector3(WALL_THICKNESS, WALL_HEIGHT, FLOOR_SIZE.y), Vector3(-half_x - WALL_THICKNESS * 0.5, wall_y, 0.0))


func _build_terminal() -> void:
	var body := _add_collider(self, "LabTerminal", TERMINAL_COLLIDER_SIZE, TERMINAL_POSITION)
	body.get_node("CollisionShape").position.y = TERMINAL_COLLIDER_SIZE.y * 0.5
	_instance_asset(body, "lab_terminal_a", "LabTerminalAsset", Vector3.ZERO)


func _build_container() -> void:
	var body := _add_collider(self, "LabContainer", CONTAINER_COLLIDER_SIZE, CONTAINER_POSITION)
	body.get_node("CollisionShape").position.y = CONTAINER_COLLIDER_SIZE.y * 0.5
	_instance_asset(body, "lab_container_a", "LabContainerAsset", Vector3.ZERO)


func _build_wall_light() -> void:
	# Sin colision: va a 2,4 m en la pared, por encima de Elena (~1,7 m).
	var fixture := Node3D.new()
	fixture.name = "LabWallLight"
	fixture.position = WALL_LIGHT_POSITION
	add_child(fixture)
	_instance_asset(fixture, "lab_wall_light_a", "LabWallLightAsset", Vector3.ZERO)


# --- Comprobacion automatica ---------------------------------------------------
func _run_checks() -> void:
	for _frame in CHECK_PHYSICS_FRAMES:
		await get_tree().physics_frame
	var failures := 0
	failures += _check_assets()
	failures += _check_materials()
	failures += _check_collisions()
	print("[lab_corner_art_test_assets] comprobaciones terminadas, fallos: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


func _report(ok: bool, label: String, detail: String = "") -> int:
	print("[lab_corner_art_test_assets] %s %s%s" % ["PASS" if ok else "FAIL", label, (" | " + detail) if detail != "" else ""])
	return 0 if ok else 1


func _mesh_instances(root: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		found.append(root as MeshInstance3D)
	for child in root.get_children():
		found.append_array(_mesh_instances(child))
	return found


func _local_aabb(instance: Node3D) -> AABB:
	# AABB combinado en el espacio local del asset (respecto a su pivote).
	var combined := AABB()
	var first := true
	var inverse := instance.global_transform.affine_inverse()
	for mesh_instance in _mesh_instances(instance):
		var box := (inverse * mesh_instance.global_transform) * mesh_instance.get_aabb()
		combined = box if first else combined.merge(box)
		first = false
	return combined


func _max_abs(v: Vector3) -> float:
	return maxf(maxf(absf(v.x), absf(v.y)), absf(v.z))


func _check_assets() -> int:
	var failures := 0
	var seen: Dictionary = {}
	for node_name in _asset_instances:
		var entry: Dictionary = _asset_instances[node_name]
		var asset_name: String = entry["asset"]
		if seen.has(asset_name):
			continue
		seen[asset_name] = true
		var instance: Node3D = entry["node"]
		var expected: Dictionary = EXPECTED_ASSETS[asset_name]
		var box := _local_aabb(instance)
		var size_ok := _max_abs(box.size - (expected["size"] as Vector3)) <= CHECK_TOLERANCE
		var min_ok := _max_abs(box.position - (expected["min"] as Vector3)) <= CHECK_TOLERANCE
		failures += _report(size_ok and min_ok, "medidas y pivote de " + asset_name, "size=%s esperado=%s min=%s esperado=%s" % [box.size, expected["size"], box.position, expected["min"]])
	return failures


func _check_materials() -> int:
	var failures := 0
	var expected_colors := {
		"lab_mat_floor_epoxy": COLOR_FLOOR_EPOXY,
		"lab_mat_floor_joint": COLOR_FLOOR_JOINT,
		"lab_mat_wall_panel": COLOR_WALL_PANEL,
		"lab_mat_trim_metal": COLOR_TRIM_METAL,
		"lab_mat_painted_metal": COLOR_PAINTED_METAL,
		"lab_mat_rubber": COLOR_RUBBER,
		"lab_mat_screen_emissive": COLOR_SCREEN_AMBER,
		"lab_mat_light_emissive": COLOR_LIGHT_EMISSIVE,
	}
	var found: Dictionary = {}
	for node_name in _asset_instances:
		for mesh_instance in _mesh_instances(_asset_instances[node_name]["node"]):
			for surface in mesh_instance.mesh.get_surface_count():
				var material := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
				if material != null:
					found[material.resource_name] = material
	for material_name in expected_colors:
		if not found.has(material_name):
			failures += _report(false, "material " + material_name, "no aparece en ningun asset")
			continue
		var material: StandardMaterial3D = found[material_name]
		var wanted: Color = expected_colors[material_name]
		var color_ok := absf(material.albedo_color.r - wanted.r) <= CHECK_COLOR_TOLERANCE and absf(material.albedo_color.g - wanted.g) <= CHECK_COLOR_TOLERANCE and absf(material.albedo_color.b - wanted.b) <= CHECK_COLOR_TOLERANCE
		var detail := "albedo=%s esperado=%s" % [material.albedo_color.to_html(false), wanted.to_html(false)]
		if EXPECTED_EMISSION.has(material_name):
			# El exportador glTF normaliza el color emisivo y compensa con la energia,
			# asi que se compara la radiancia efectiva (color lineal x energia).
			var radiance := material.emission.srgb_to_linear() * material.emission_energy_multiplier
			var wanted_radiance := wanted.srgb_to_linear() * float(EXPECTED_EMISSION[material_name])
			var radiance_ok := material.emission_enabled and absf(radiance.r - wanted_radiance.r) <= CHECK_RADIANCE_TOLERANCE and absf(radiance.g - wanted_radiance.g) <= CHECK_RADIANCE_TOLERANCE and absf(radiance.b - wanted_radiance.b) <= CHECK_RADIANCE_TOLERANCE
			color_ok = color_ok and radiance_ok
			detail += " emision=%s energia=%.2f radiancia=(%.3f, %.3f, %.3f) esperada=(%.3f, %.3f, %.3f)" % [str(material.emission_enabled), material.emission_energy_multiplier, radiance.r, radiance.g, radiance.b, wanted_radiance.r, wanted_radiance.g, wanted_radiance.b]
		failures += _report(color_ok, "material " + material_name, detail)
	return failures


func _cast(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, COLLISION_LAYER_WORLD)
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
	var half_x := FLOOR_SIZE.x * 0.5
	var half_z := FLOOR_SIZE.y * 0.5
	failures += _check_ray("suelo", Vector3(1.0, RAY_ABOVE, 1.0), Vector3(1.0, -1.0, 1.0), Vector3.AXIS_Y, 0.0, "FloorCollider")
	failures += _check_ray("pared del fondo", Vector3(-2.0, 1.0, 0.0), Vector3(-2.0, 1.0, -RAY_ABOVE), Vector3.AXIS_Z, -half_z, "WallBackCollider")
	failures += _check_ray("pared izquierda", Vector3(0.0, 1.0, 1.0), Vector3(-RAY_ABOVE - half_x, 1.0, 1.0), Vector3.AXIS_X, -half_x, "WallLeftCollider")
	failures += _check_ray("terminal", Vector3(0.0, 0.5, 0.5), Vector3(0.0, 0.5, -1.5), Vector3.AXIS_Z, TERMINAL_POSITION.z + TERMINAL_COLLIDER_SIZE.z * 0.5, "LabTerminal")
	failures += _check_ray("contenedor", Vector3(CONTAINER_POSITION.x, 0.5, 1.0), Vector3(CONTAINER_POSITION.x, 0.5, -0.4), Vector3.AXIS_Z, CONTAINER_POSITION.z + CONTAINER_COLLIDER_SIZE.z * 0.5, "LabContainer")
	return failures
