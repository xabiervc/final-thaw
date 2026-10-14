extends Node3D
## Canonical Phase 1 slice following FASE1_SPATIAL_GRAPH.md v0.4.
## This scene deliberately does not alter the preserved six-room comparison prototype.
## Logic comes from phase1_circuit_model.gd; lift mechanics come from service_lift.gd.
const Player = preload("res://scripts/prototypes/phase1_spatial_player.gd")
const CircuitModel = preload("res://scripts/prototypes/phase1_circuit_model.gd")
const ServiceLift = preload("res://scripts/prototypes/service_lift.gd")
const FacilityMaterials = preload("res://scripts/levels/test_room_art/facility_materials.gd")
const HudScript = preload("res://scripts/ui/prompt_hud.gd")

const CHASE_SCENE := "res://scenes/prototypes/motion_chase_prototype.tscn"
const SLAB := 0.25
const WALL_THICKNESS := 0.3
const RAIL_HEIGHT := 1.1
const INTERACTION_REACH := 2.15
const HANDOFF_DELAY := 2.4
const SCAN_CHARGE_TIME := 0.9
const SCAN_REVEAL_TIME := 3.0
const SCAN_COOLDOWN := 4.0
const ARCHIVE_RECORD := "El acta oficial declara alimentación exclusiva del nodo T. La telemetría de bornes registra corriente simultánea en A y T durante la ventana de ensayo; el cierre posterior la atribuye a una interrupción automática."

var materials = FacilityMaterials.new()
var circuit = CircuitModel.new()
var lift = null
var player: CharacterBody3D
var hud: CanvasLayer

var _hotspot_id := ""
var _shortcut_unlocked := false
var _outer_hatch_open := false
var _handoff_started := false
var _archive_consulted := false
var _audit_events: Array[String] = []
var _service_lights: Array[OmniLight3D] = []
var _scan_charge: float = 0.0
var _scan_reveal_left: float = 0.0
var _scan_cooldown_left: float = 0.0
var _scan_labels: Array[Label3D] = []
var _scan_highlights: Array[MeshInstance3D] = []
var _lift_lower_button: MeshInstance3D
var _lift_upper_button: MeshInstance3D
var _lift_deck_label: Label3D
var _safe_point: Vector3 = Vector3(3.0, 0.2, 7.0)
var _lift_deck_button: MeshInstance3D
var _switch_lamp: MeshInstance3D
var _archive_status_label: Label3D
var _status_panel_label: Label3D
var _inner_door: StaticBody3D
var _outer_door: StaticBody3D
var _outer_door_shape: CollisionShape3D
var _outer_door_mesh: MeshInstance3D


func _ready() -> void:
	_build_environment()
	_build_ground_floor()
	_build_fixed_geometry()
	_build_pit()
	_build_scanner_fixtures()
	_build_upper_route()
	_build_lift()
	_build_controls_and_fixtures()
	_build_doors()
	_build_player_and_hud()
	_refresh_state_fixtures()
	_log("slice_ready", "Fase 1 canónica v0.4")


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if player == null or hud == null:
		return
	_update_interaction_prompt()
	_update_scanner(delta)
	if not _hotspot_id.is_empty() and Input.is_action_just_pressed("interact"):
		_interact(_hotspot_id)
	_update_safe_point()
	if player.global_position.y < -8.0:
		player.global_position = _safe_point
		player.velocity = Vector3.ZERO
	if _outer_hatch_open and not _handoff_started and player.global_position.x < -0.25 and player.global_position.y > 2.3 and absf(player.global_position.z + 7.5) < 1.0:
		_begin_handoff()
	_refresh_dynamic_lift_button()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and player != null:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


# --------------------------------------------------------------------------------------------------
# Environment and primitive construction helpers
# --------------------------------------------------------------------------------------------------

func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.018, 0.025, 0.033)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.39, 0.46, 0.53)
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, 24.0, 0.0)
	sun.light_color = Color(0.66, 0.75, 0.84)
	sun.light_energy = 0.32
	add_child(sun)
	_add_room_light(Vector3(14.0, 3.4, 0.0), 1.0, 16.0, Color(0.74, 0.84, 0.94))
	_add_room_light(Vector3(6.0, 5.0, -7.0), 1.0, 10.0, Color(0.7, 0.86, 1.0))
	var pit_light := _add_room_light(Vector3(24.0, -0.7, 4.0), 0.75, 9.0, Color(0.7, 0.82, 0.9))
	_service_lights.append(pit_light)
	var switch_light := _add_room_light(Vector3(26.0, -1.0, 2.0), 0.45, 3.0, Color(0.3, 0.95, 0.9))
	_service_lights.append(switch_light)


func _add_room_light(pos: Vector3, energy: float, radius: float, color: Color) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	add_child(light)
	return light


func _body_box(label: String, size: Vector3, center: Vector3, material: Material, collision: bool = true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 0
	if collision:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
	var mesh := MeshInstance3D.new()
	mesh.name = label + "Mesh"
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = material
	body.add_child(mesh)
	add_child(body)
	return body


func _visual_box(label: String, size: Vector3, center: Vector3, material: Material) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = label
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = center
	mesh.material_override = material
	add_child(mesh)
	return mesh


func _label3d(label_name: String, text: String, pos: Vector3, color: Color = Color(0.86, 0.93, 0.96), size: int = 24, pixel_size: float = 0.004) -> Label3D:
	var label := Label3D.new()
	label.name = label_name
	label.text = text
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = size
	label.pixel_size = pixel_size
	label.outline_size = 7
	label.modulate = color
	add_child(label)
	return label


func _flat_material(color: Color, roughness: float = 0.72, metallic: float = 0.0, emission: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if emission > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission
	return material


func _add_floor_rect(rect: Rect2, y: float, label: String, material: Material = null) -> void:
	if rect.size.x <= 0.01 or rect.size.y <= 0.01:
		return
	var chosen: Material = materials.get_material("floor") if material == null else material
	_body_box(label, Vector3(rect.size.x, SLAB, rect.size.y), Vector3(rect.position.x + rect.size.x * 0.5, y - SLAB * 0.5, rect.position.y + rect.size.y * 0.5), chosen)


func _subtract_rect(base: Rect2, hole: Rect2) -> Array:
	var ix0: float = maxf(base.position.x, hole.position.x)
	var iz0: float = maxf(base.position.y, hole.position.y)
	var ix1: float = minf(base.end.x, hole.end.x)
	var iz1: float = minf(base.end.y, hole.end.y)
	if ix1 <= ix0 or iz1 <= iz0:
		return [base]
	var pieces: Array = []
	if iz0 > base.position.y:
		pieces.append(Rect2(base.position.x, base.position.y, base.size.x, iz0 - base.position.y))
	if iz1 < base.end.y:
		pieces.append(Rect2(base.position.x, iz1, base.size.x, base.end.y - iz1))
	if ix0 > base.position.x:
		pieces.append(Rect2(base.position.x, iz0, ix0 - base.position.x, iz1 - iz0))
	if ix1 < base.end.x:
		pieces.append(Rect2(ix1, iz0, base.end.x - ix1, iz1 - iz0))
	return pieces


func _wall_x(label: String, x: float, z0: float, z1: float, y0: float, y1: float, material: Material = null) -> void:
	if z1 <= z0 or y1 <= y0:
		return
	var chosen: Material = materials.get_material("bulkhead") if material == null else material
	_body_box(label, Vector3(WALL_THICKNESS, y1 - y0, z1 - z0), Vector3(x, (y0 + y1) * 0.5, (z0 + z1) * 0.5), chosen)


func _wall_z(label: String, z: float, x0: float, x1: float, y0: float, y1: float, material: Material = null) -> void:
	if x1 <= x0 or y1 <= y0:
		return
	var chosen: Material = materials.get_material("bulkhead") if material == null else material
	_body_box(label, Vector3(x1 - x0, y1 - y0, WALL_THICKNESS), Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, z), chosen)


func _build_ground_floor() -> void:
	# The only intentional holes in the ground slab: the lift shaft, pit, and pit-stair mouth.
	var regions: Array = [Rect2(Vector2(0.0, -10.0), Vector2(30.0, 22.0))]
	var holes: Array = [
		Rect2(Vector2(24.5, -4.5), Vector2(3.0, 3.0)),
		Rect2(Vector2(20.0, 1.0), Vector2(8.0, 7.0)),
		Rect2(Vector2(24.0, 8.0), Vector2(2.0, 3.0)),
	]
	for hole in holes:
		var next_regions: Array = []
		for region in regions:
			next_regions.append_array(_subtract_rect(region, hole))
		regions = next_regions
	for i in regions.size():
		_add_floor_rect(regions[i], 0.0, "GroundFloor_%02d" % i)


func _build_fixed_geometry() -> void:
	# Outer shell. The west wall has an upper-level hatch aperture only; its ground-level wall remains solid.
	_wall_x("OuterWestLowerA", 0.0, -10.0, -8.25, 0.0, 5.4)
	_wall_x("OuterWestLowerB", 0.0, -6.75, 12.0, 0.0, 5.4)
	_wall_x("OuterWestHatchLower", 0.0, -8.25, -6.75, 0.0, 3.0)
	_wall_x("OuterWestHatchLintel", 0.0, -8.25, -6.75, 5.2, 5.4)
	_wall_z("OuterNorth", -10.0, 0.0, 30.0, 0.0, 5.4)
	_wall_x("OuterEast", 30.0, -10.0, 12.0, 0.0, 4.5)
	# Main south edge: entry aperture x=2..4. The stair opening is inside the floor, not an outside doorway.
	_wall_z("OuterSouthWest", 12.0, 0.0, 2.0, 0.0, 4.5)
	_wall_z("OuterSouthMiddle", 12.0, 4.0, 30.0, 0.0, 4.5)

	# Central machine block: it is scenery/obstacle, never a running machine.
	_body_box("CentralTestRig", Vector3(6.0, 2.0, 4.0), Vector3(14.5, 1.0, 0.5), materials.get_material("machine"))
	_visual_box("TestRigTopMarker", Vector3(1.3, 0.12, 1.1), Vector3(14.5, 2.08, 0.5), _flat_material(Color(0.3, 0.8, 0.8), 0.45, 0.2, 1.2))
	_label3d("TestRigLabel", "ASTER · NODO T", Vector3(14.5, 2.4, 0.5), Color(0.5, 0.92, 0.9), 26)

	# Blocked direct stairs: the one-metre missing span is not a jump challenge.
	_build_sloped_stairs("BrokenApproachStairs", 2.0, 4.0, -3.0, 3.0, 3.0, 0.0)
	_add_floor_rect(Rect2(Vector2(2.0, -4.0), Vector2(2.0, 1.0)), 3.0, "BrokenStairUpperLanding", materials.get_material("grate"))
	_wall_z("BrokenStairBlockedGap", -4.5, 2.0, 4.0, 3.0, 5.4, materials.get_material("safety_paint"))
	_visual_box("BrokenApproachWarning", Vector3(1.5, 0.16, 0.08), Vector3(3.0, 3.35, -4.48), _flat_material(Color(0.95, 0.54, 0.12), 0.45, 0.0, 1.1))

	# Service-apron guardrail around the pit; leave the fixed stair mouth open.
	var rail := _flat_material(Color(0.55, 0.58, 0.6), 0.5, 0.7)
	_body_box("PitRailWest", Vector3(0.12, RAIL_HEIGHT, 7.0), Vector3(19.94, RAIL_HEIGHT * 0.5, 4.5), rail)
	_body_box("PitRailEast", Vector3(0.12, RAIL_HEIGHT, 7.0), Vector3(28.06, RAIL_HEIGHT * 0.5, 4.5), rail)
	_body_box("PitRailNorth", Vector3(8.0, RAIL_HEIGHT, 0.12), Vector3(24.0, RAIL_HEIGHT * 0.5, 0.94), rail)
	_body_box("PitRailSouthWest", Vector3(4.0, RAIL_HEIGHT, 0.12), Vector3(22.0, RAIL_HEIGHT * 0.5, 8.06), rail)
	_body_box("PitRailSouthEast", Vector3(2.0, RAIL_HEIGHT, 0.12), Vector3(27.0, RAIL_HEIGHT * 0.5, 8.06), rail)

	# Service paths are painted into the ground slab and stay lit independently of maintenance.
	_label3d("SouthRouteMark", "PASILLO DE SERVICIO", Vector3(13.0, 0.06, 6.0), Color(0.7, 0.82, 0.86), 20, 0.003)
	_label3d("PitApproachMark", "FOSO DE SERVICIO ↓", Vector3(21.8, 0.06, 9.7), Color(0.9, 0.74, 0.35), 20, 0.003)


func _build_pit() -> void:
	_add_floor_rect(Rect2(Vector2(20.0, 1.0), Vector2(8.0, 7.0)), -2.0, "PitFloor", materials.get_material("grate"))
	# A continuous sloped collision surface with visible individual treads.
	_build_sloped_stairs("FixedPitStairs", 24.0, 26.0, 8.0, 11.0, -2.0, 0.0)
	_visual_box("SchematicBoard", Vector3(1.6, 1.0, 0.12), Vector3(27.0, -1.35, 6.0), materials.get_material("screen_dark"))
	_label3d("PitSchematicTitle", "ESQUEMA · DISTRIBUCIÓN PREVISTA", Vector3(27.0, -0.91, 6.08), Color(0.7, 0.9, 0.94), 15, 0.0028)
	_label3d("SchematicDiagram", "AUXILIAR → DIAGNÓSTICO\nMANTENIMIENTO → LUCES / ASCENSOR\nPROTECCIÓN → SELECTOR\nENSAYO → T\nARCHIVO → A", Vector3(27.0, -1.42, 6.08), Color(0.86, 0.95, 0.96), 12, 0.0024)
	_label3d("BridgeTitle", "PUENTE A → T", Vector3(22.2, -1.0, 4.0), Color(1.0, 0.63, 0.18), 22, 0.0035)
	_visual_box("TamperedBridge", Vector3(1.5, 0.16, 0.3), Vector3(22.0, -1.78, 4.0), _flat_material(Color(0.95, 0.38, 0.08), 0.42, 0.3, 1.4))
	_label3d("TamperedBridgeLabel", "CONEXIÓN MANIPULADA", Vector3(22.0, -1.45, 4.0), Color(1.0, 0.66, 0.3), 20, 0.0032)
	_visual_box("MaintenanceHousing", Vector3(0.65, 0.55, 0.35), Vector3(26.0, -1.55, 2.0), materials.get_material("steel_light"))
	_switch_lamp = _visual_box("MaintenanceStatusLamp", Vector3(0.22, 0.12, 0.08), Vector3(26.0, -1.22, 1.78), _flat_material(Color(0.9, 0.2, 0.1), 0.35, 0.0, 1.3))
	_label3d("MaintenanceLabel", "MANTENIMIENTO", Vector3(26.0, -0.85, 2.0), Color(0.92, 0.88, 0.7), 20, 0.0032)


func _build_scanner_fixtures() -> void:
	# Three transient markers communicate continuity at A, the physical bridge and T without naming an action.
	var marker_a := _label3d("ScanSchematicLabel", "TRAZA DE CONTINUIDAD · A", Vector3(27.0, -0.52, 6.12), Color(0.35, 0.98, 0.95), 18, 0.0035)
	var marker_bridge := _label3d("ScanBridgeLabel", "CONTINUIDAD A → T", Vector3(22.0, -0.72, 4.0), Color(0.35, 0.98, 0.95), 20, 0.0037)
	var marker_t := _label3d("ScanNodeTLabel", "TRAZA DETECTADA · T", Vector3(14.5, 2.75, 2.7), Color(0.35, 0.98, 0.95), 18, 0.0035)
	var markers: Array[Label3D] = [marker_a, marker_bridge, marker_t]
	for marker: Label3D in markers:
		marker.visible = false
		_scan_labels.append(marker)
	var glow := _flat_material(Color(0.25, 0.98, 0.9), 0.35, 0.1, 2.0)
	var schematic_glow := _visual_box("ScanSchematicHighlight", Vector3(1.7, 0.05, 0.18), Vector3(27.0, -0.82, 6.1), glow)
	var bridge_glow := _visual_box("ScanBridgeHighlight", Vector3(1.65, 0.05, 0.36), Vector3(22.0, -1.65, 4.0), glow)
	var node_t_glow := _visual_box("ScanNodeTHighlight", Vector3(0.8, 0.05, 0.8), Vector3(14.5, 2.14, 0.5), glow)
	var highlights: Array[MeshInstance3D] = [schematic_glow, bridge_glow, node_t_glow]
	for highlight: MeshInstance3D in highlights:
		highlight.visible = false
		_scan_highlights.append(highlight)


func _set_scan_visibility(value: bool) -> void:
	for marker in _scan_labels:
		marker.visible = value
	for highlight in _scan_highlights:
		highlight.visible = value


func _start_scan_reveal() -> void:
	_scan_charge = 0.0
	_scan_reveal_left = SCAN_REVEAL_TIME
	_scan_cooldown_left = SCAN_COOLDOWN
	_set_scan_visibility(true)
	_banner("TRAZAS REVELADAS", "Continuidad detectada entre A y T. Contrasta la traza con el esquema previsto.", Color(0.35, 0.98, 0.95), SCAN_REVEAL_TIME)


func _update_scanner(delta: float) -> void:
	_scan_cooldown_left = maxf(0.0, _scan_cooldown_left - delta)
	if _scan_reveal_left > 0.0:
		_scan_reveal_left -= delta
		if _scan_reveal_left <= 0.0:
			_set_scan_visibility(false)
		return
	if Input.is_action_pressed("scan") and _scan_cooldown_left <= 0.0:
		_scan_charge += delta
		if _scan_charge >= SCAN_CHARGE_TIME:
			_start_scan_reveal()
	else:
		_scan_charge = 0.0


func _build_sloped_stairs(label: String, x0: float, x1: float, z0: float, z1: float, y0: float, y1: float) -> void:
	# z0 < z1, coordinates increase north-to-south. y0/y1 are heights at those coordinates.
	var run: float = z1 - z0
	var rise: float = y1 - y0
	if run <= 0.0 or absf(rise) < 0.01:
		return
	var width: float = x1 - x0
	var angle: float = atan2(rise, run)
	var ramp_length: float = sqrt(run * run + rise * rise)
	var ramp := _body_box(label + "CollisionRamp", Vector3(width, 0.18, ramp_length), Vector3.ZERO, materials.get_material("grate"))
	ramp.rotation.x = -angle
	ramp.position = Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, (z0 + z1) * 0.5) - ramp.basis.y * 0.09
	(ramp.get_child(1) as MeshInstance3D).visible = false
	var count: int = maxi(1, int(ceil(absf(rise) / 0.2)))
	var base_y: float = minf(y0, y1) - 0.3
	for i in count:
		var t: float = (float(i) + 0.5) / float(count)
		var z: float = z0 + t * run
		var top_y: float = y0 + (float(i) + 1.0) / float(count) * rise
		var tread: float = run / float(count)
		var block_height: float = maxf(0.08, top_y - base_y)
		_body_box(label + "Tread_%02d" % i, Vector3(width, block_height, tread), Vector3((x0 + x1) * 0.5, base_y + block_height * 0.5, z), materials.get_material("grate"), false)


func _build_upper_route() -> void:
	# The cabin and public walkway share Y=3. Their floor slabs meet edge-to-edge.
	_add_floor_rect(Rect2(Vector2(2.0, -9.0), Vector2(7.0, 4.0)), 3.0, "ArchiveCabinFloor")
	_add_floor_rect(Rect2(Vector2(0.0, -9.0), Vector2(2.0, 3.0)), 3.0, "WestVestibuleFloor", materials.get_material("grate"))
	_add_floor_rect(Rect2(Vector2(9.0, -8.0), Vector2(17.0, 2.0)), 3.0, "PublicControlWalkway", materials.get_material("grate"))
	_add_floor_rect(Rect2(Vector2(24.0, -7.0), Vector2(4.0, 2.5)), 3.0, "UpperLiftLanding", materials.get_material("grate"))

	# Cabin shell/partitions. Openings remain 2 m clear; the inner west door is controlled separately.
	_wall_z("CabinNorthWall", -9.0, 2.0, 9.0, 3.0, 5.4)
	_wall_z("CabinSouthWall", -5.0, 2.0, 9.0, 3.0, 5.4)
	_wall_x("CabinEastNorthPier", 9.0, -9.0, -8.0, 3.0, 5.4)
	_wall_x("CabinEastSouthPier", 9.0, -6.0, -5.0, 3.0, 5.4)
	_wall_x("CabinEastLintel", 9.0, -8.0, -6.0, 5.2, 5.4)
	_wall_x("CabinWestPierNorth", 2.0, -9.0, -8.5, 3.0, 5.4)
	_wall_x("CabinWestPierSouth", 2.0, -6.5, -5.0, 3.0, 5.4)

	# Guardrails around walkable upper edges, not across cabin entrances.
	var rail := _flat_material(Color(0.55, 0.58, 0.6), 0.45, 0.7)
	_body_box("WalkwayRailSouth", Vector3(17.0, RAIL_HEIGHT, 0.1), Vector3(17.5, 3.0 + RAIL_HEIGHT * 0.5, -6.02), rail)
	_body_box("WalkwayRailNorth", Vector3(15.0, RAIL_HEIGHT, 0.1), Vector3(16.5, 3.0 + RAIL_HEIGHT * 0.5, -7.98), rail)
	_body_box("UpperLandingOuterRail", Vector3(2.0, RAIL_HEIGHT, 0.1), Vector3(27.0, 3.0 + RAIL_HEIGHT * 0.5, -7.02), rail)
	_body_box("UpperLandingEastRail", Vector3(0.1, RAIL_HEIGHT, 2.5), Vector3(28.02, 3.0 + RAIL_HEIGHT * 0.5, -5.75), rail)

	# The west vestibule is bounded by the external hatch at x=0 and the inner F→G door at x=2.
	_wall_z("VestibuleNorthWall", -9.0, 0.0, 2.0, 3.0, 5.4)
	# Keep outer west lower wall and lintel as already built; only the upper door is movable.

	# Stairs from vestibule to ground are a secondary return route. They don't lead to H.
	_build_sloped_stairs("WestShortcutStairs", 0.0, 2.0, -6.0, 0.0, 3.0, 0.0)
	# Railings on stairwell edges, outside the two-metre clear stairway.
	_body_box("ShortcutRailWest", Vector3(0.1, 1.1, 6.0), Vector3(-0.12, 1.9, -3.0), rail)
	_body_box("ShortcutRailEast", Vector3(0.1, 1.1, 6.0), Vector3(2.12, 1.9, -3.0), rail)


func _build_lift() -> void:
	lift = ServiceLift.new()
	lift.name = "ServiceLift"
	lift.position = Vector3(26.0, 0.0, -3.0)
	lift.powered = false
	add_child(lift)
	# No ramp or second platform: the original lift shaft is the one canonical transport.
	_lift_lower_button = _visual_box("LiftCallLower", Vector3(0.28, 0.12, 0.12), Vector3(27.1, 0.28, -0.2), _flat_material(Color(0.9, 0.6, 0.15), 0.45, 0.0, 1.2))
	_label3d("LiftCallLowerLabel", "LLAMAR · NIVEL INFERIOR", Vector3(26.7, 0.72, -0.2), Color(0.95, 0.8, 0.4), 16, 0.003)
	_lift_upper_button = _visual_box("LiftCallUpper", Vector3(0.28, 0.12, 0.12), Vector3(27.1, 3.28, -6.1), _flat_material(Color(0.9, 0.6, 0.15), 0.45, 0.0, 1.2))
	_label3d("LiftCallUpperLabel", "LLAMAR · NIVEL SUPERIOR", Vector3(26.8, 3.72, -6.1), Color(0.95, 0.8, 0.4), 16, 0.003)
	_lift_deck_button = _visual_box("LiftDeckButton", Vector3(0.25, 0.08, 0.2), Vector3(26.0, float(lift.platform_y) + 0.06, -3.0), _flat_material(Color(0.25, 0.9, 0.6), 0.4, 0.0, 1.2))
	_lift_deck_label = _label3d("LiftDeckButtonLabel", "ENVIAR AL OTRO NIVEL", Vector3(26.0, float(lift.platform_y) + 0.32, -3.0), Color(0.6, 1.0, 0.75), 14, 0.0028)


func _build_controls_and_fixtures() -> void:
	# E controls retain the contract coordinates. Their interaction colliders are positional, not physical blocks.
	_visual_box("SelectorBody", Vector3(0.45, 0.7, 0.38), Vector3(12.0, 3.35, -7.0), materials.get_material("steel_light"))
	_label3d("SelectorLabel", "SELECTOR\nENSAYO / ARCHIVO", Vector3(12.0, 4.0, -7.0), Color(0.95, 0.72, 0.28), 18, 0.003)
	_visual_box("IsolatorBody", Vector3(0.45, 0.7, 0.38), Vector3(19.0, 3.35, -7.0), materials.get_material("steel_light"))
	_label3d("IsolatorLabel", "AISLADOR\nRAMA ENSAYO", Vector3(19.0, 4.0, -7.0), Color(0.95, 0.72, 0.28), 18, 0.003)

	_visual_box("EStatusPanelBoard", Vector3(2.5, 1.15, 0.16), Vector3(15.5, 4.55, -8.15), materials.get_material("screen_dark"))
	_status_panel_label = _label3d("EStatusPanelText", "", Vector3(15.5, 4.55, -8.05), Color(0.78, 0.92, 0.95), 19, 0.0025)
		_visual_box("RearmButtonBody", Vector3(0.32, 0.22, 0.18), Vector3(15.5, 3.5, -8.15), _flat_material(Color(0.2, 0.55, 0.3), 0.4, 0.0, 0.8))
	_label3d("RearmButtonLabel", "REARME", Vector3(15.5, 3.8, -8.05), Color(0.8, 1.0, 0.8), 17, 0.003)

	_visual_box("ArchiveStatusBoard", Vector3(0.12, 0.9, 0.8), Vector3(8.55, 3.8, -7.0), materials.get_material("screen_dark"))
	_archive_status_label = _label3d("ArchiveStatusText", "", Vector3(8.68, 3.82, -7.0), Color(0.84, 0.95, 0.88), 16, 0.0028)

	# Archive consultation console and the always-available diagnostic terminal are distinct fixtures.
	_visual_box("ArchiveConsole", Vector3(0.9, 0.75, 0.5), Vector3(5.0, 3.38, -7.0), materials.get_material("steel"))
	_label3d("ArchiveConsoleLabel", "CONSULTA DE ARCHIVO", Vector3(5.0, 4.0, -7.0), Color(0.45, 0.95, 0.9), 18, 0.003)
	_visual_box("DiagnosticTerminal", Vector3(0.65, 0.9, 0.35), Vector3(7.25, 3.45, -6.0), materials.get_material("steel_light"))
	_label3d("DiagnosticTerminalLabel", "DIAGNÓSTICO", Vector3(7.25, 4.0, -6.0), Color(0.65, 0.88, 0.96), 16, 0.003)

	# Evidence and service event are visible in-world only; nothing here modifies a save file.
	_visual_box("EvidenceRecordScreen", Vector3(0.12, 0.65, 0.5), Vector3(5.0, 3.65, -7.0), materials.get_material("aster_screen"))
	_label3d("EvidenceRecordHint", "ACTA / TELEMETRÍA", Vector3(5.0, 4.35, -7.0), Color(0.65, 0.94, 0.9), 15, 0.003)


func _build_doors() -> void:
	_inner_door = _body_box("ShortcutInnerDoor", Vector3(0.2, 2.2, 2.0), Vector3(2.0, 4.1, -7.5), materials.get_material("safety_paint"))
	_outer_door = _body_box("OuterHatch", Vector3(0.2, 2.2, 1.5), Vector3(0.0, 4.1, -7.5), materials.get_material("safety_paint"))
	_outer_door_shape = _outer_door.get_child(0) as CollisionShape3D
	_outer_door_mesh = _outer_door.get_child(1) as MeshInstance3D
	# Keep hatch shut until the player opens it from inside the west vestibule.


func _build_player_and_hud() -> void:
	player = Player.new()
	player.name = "Elena"
	player.position = Vector3(3.0, 0.2, 7.0)
	add_child(player)
	hud = HudScript.new()
	hud.name = "PromptHUD"
	add_child(hud)
	hud.call("set_objective", "OBJETIVO  /  Investiga la anomalía y accede al archivo")
	hud.call("set_hint", "Baja al foso. El esquema y la conexión física describen cosas distintas.")
	hud.call("set_status", "Fase 1 · The Ghost Protocol")


# --------------------------------------------------------------------------------------------------
# Positional interactions
# --------------------------------------------------------------------------------------------------

func _current_hotspots() -> Array:
	var deck_at := Vector3(26.0, float(lift.platform_y) + 0.45, -3.0)
	return [
		{"id":"maintenance", "at":Vector3(26.0, -1.35, 2.0), "verb":"Accionar", "name":"Interruptor de mantenimiento"},
		{"id":"schematic", "at":Vector3(27.0, -1.0, 6.0), "verb":"Examinar", "name":"Esquema de distribución"},
		{"id":"bridge", "at":Vector3(22.0, -1.0, 4.0), "verb":"Examinar", "name":"Conexión manipulada"},
		{"id":"lift_lower", "at":Vector3(26.0, 0.25, -0.25), "verb":"Llamar", "name":"Elevador · nivel inferior"},
		{"id":"lift_upper", "at":Vector3(26.0, 3.25, -6.2), "verb":"Llamar", "name":"Elevador · nivel superior"},
		{"id":"lift_deck", "at":deck_at, "verb":"Enviar", "name":"Elevador · otro nivel"},
		{"id":"selector", "at":Vector3(12.0, 3.0, -7.0), "verb":"Accionar", "name":"Selector de recuperación"},
		{"id":"isolator", "at":Vector3(19.0, 3.0, -7.0), "verb":"Accionar", "name":"Aislador de ensayo"},
		{"id":"indicators", "at":Vector3(15.0, 3.0, -7.0), "verb":"Consultar", "name":"Indicadores del circuito"},
		{"id":"rearm", "at":Vector3(15.5, 3.5, -8.15), "verb":"Rearmar", "name":"Protección de recuperación"},
		{"id":"diagnostic", "at":Vector3(7.25, 3.1, -6.0), "verb":"Inspeccionar", "name":"Terminal de diagnóstico"},
		{"id":"archive", "at":Vector3(5.0, 3.1, -7.0), "verb":"Consultar", "name":"Archivo restringido"},
		{"id":"shortcut", "at":Vector3(2.0, 3.0, -7.5), "verb":"Desbloquear", "name":"Puerta del vestíbulo oeste"},
		{"id":"outer_hatch", "at":Vector3(0.45, 3.1, -7.5), "verb":"Abrir", "name":"Compuerta exterior"},
	]


func _update_interaction_prompt() -> void:
	var best: Dictionary = {}
	var best_distance := INTERACTION_REACH
	for hotspot in _current_hotspots():
		var d: float = player.global_position.distance_to(hotspot["at"])
		if d <= best_distance and _hotspot_available(str(hotspot["id"])):
			best_distance = d
			best = hotspot
	_hotspot_id = str(best.get("id", ""))
	if best.is_empty():
		hud.call("set_prompt", "")
	else:
		hud.call("set_prompt", "[E] %s - %s" % [str(best["verb"]), str(best["name"])])


func _hotspot_available(id: String) -> bool:
	match id:
		"shortcut":
			return not _shortcut_unlocked and player.global_position.x > 2.15
		"outer_hatch":
			return _shortcut_unlocked and not _outer_hatch_open and player.global_position.x < 1.8
		"lift_deck":
			return absf(player.global_position.x - 26.0) < 1.7 and absf(player.global_position.z + 3.0) < 1.7 and absf(player.global_position.y - float(lift.platform_y)) < 1.0
		_:
			return true


func _interact(id: String) -> void:
	match id:
		"maintenance":
			_toggle_maintenance()
		"schematic":
			_banner("Esquema de distribución", "Una fuente auxiliar alimenta diagnóstico, mantenimiento y protección de recuperación por ramas independientes.", Color(0.55, 0.9, 0.95), 6.0)
			_log("clue", "schematic")
		"bridge":
			_banner("Conexión manipulada", "El puente físico une A con T aunque no aparece en el esquema previsto.", Color(1.0, 0.67, 0.25), 6.0)
			_log("clue", "tampered_bridge_A_to_T")
		"lift_lower":
			_call_lift("lower")
		"lift_upper":
			_call_lift("upper")
		"lift_deck":
			var accepted: bool = lift.send()
			_log("lift_deck_send", "accepted" if accepted else "refused")
			if not accepted:
				_banner("Elevador sin alimentación", "Activa mantenimiento desde el foso.", Color(1.0, 0.67, 0.25), 3.5)
		"selector":
			_toggle_selector()
		"isolator":
			_toggle_isolator()
		"indicators":
			_banner("Estado del circuito", _diagnostic_text(), Color(0.5, 0.9, 0.95), 6.0)
			_log("inspect", "indicators")
		"rearm":
			_request_rearm()
		"diagnostic":
			_banner("Terminal de diagnóstico", _diagnostic_text(), Color(0.5, 0.9, 0.95), 7.0)
			_log("inspect", "diagnostic_terminal")
		"archive":
			_consult_archive()
		"shortcut":
			_unlock_shortcut()
		"outer_hatch":
			_open_outer_hatch()


func _toggle_maintenance() -> void:
	var was_on: bool = circuit.maintenance_on
	circuit.set_maintenance(not was_on)
	lift.set_powered(circuit.maintenance_on)
	if circuit.maintenance_on and not _audit_events.has("SERVICE_OVERRIDE"):
		_audit_events.append("SERVICE_OVERRIDE")
		_log("audit_queued", "SERVICE_OVERRIDE")
	for light in _service_lights:
		light.light_energy = 0.75 if circuit.maintenance_on else 0.12
	if _switch_lamp != null:
		_switch_lamp.material_override = _flat_material(Color(0.2, 0.95, 0.6) if circuit.maintenance_on else Color(0.95, 0.18, 0.12), 0.4, 0.0, 1.5)
	_banner("Mantenimiento " + ("activo" if circuit.maintenance_on else "apagado"), "Luces de servicio y elevador: " + ("con alimentación." if circuit.maintenance_on else "sin alimentación."), Color(0.45, 0.95, 0.65) if circuit.maintenance_on else Color(1.0, 0.67, 0.25), 4.0)
	_refresh_state_fixtures()
	_log("maintenance", "on" if circuit.maintenance_on else "off")


func _toggle_selector() -> void:
	var was_available: bool = circuit.protection_available
	var target: String = CircuitModel.ARCHIVE if circuit.destination == CircuitModel.TRIAL else CircuitModel.TRIAL
	circuit.select_destination(target)
	_after_circuit_change(was_available, "Selector en " + target)
	_log("selector", target)


func _toggle_isolator() -> void:
	var was_available: bool = circuit.protection_available
	circuit.set_isolated(not circuit.trial_isolated)
	_after_circuit_change(was_available, "Ensayo " + ("aislado" if circuit.trial_isolated else "conectado"))
	_log("isolator", "isolated" if circuit.trial_isolated else "connected")


func _after_circuit_change(was_available: bool, title: String) -> void:
	if was_available and not circuit.protection_available:
		_banner("Protección disparada", "Demanda simultánea registrada. No se ha perdido nada; el estado puede recuperarse.", Color(1.0, 0.25, 0.18), 5.0)
		_log("trip", circuit.last_trip)
	else:
		_banner(title, "Consulta el estado actual y el último disparo por separado.", Color(0.5, 0.9, 0.95), 3.5)
	_refresh_state_fixtures()


func _request_rearm() -> void:
	var accepted: bool = circuit.rearm()
	if accepted:
		_banner("Protección rearmada", "La protección vuelve a estar disponible; el último disparo queda registrado.", Color(0.45, 0.95, 0.65), 4.0)
	else:
		_banner("Rearme rechazado", "Sigue presente la demanda simultánea.", Color(1.0, 0.67, 0.25), 4.0)
	_log("rearm", "accepted" if accepted else "rejected")
	_refresh_state_fixtures()


func _consult_archive() -> void:
	if not circuit.consult():
		_banner("Archivo no disponible", "El archivo requiere suministro estable. El terminal de diagnóstico sigue funcionando.", Color(1.0, 0.67, 0.25), 5.0)
		_log("archive_consult", "refused")
		return
	_archive_consulted = true
	if not _audit_events.has("RESTRICTED_RECORD_READ"):
		_audit_events.append("RESTRICTED_RECORD_READ")
		_log("audit_queued", "RESTRICTED_RECORD_READ")
	_banner("Registro consultado", ARCHIVE_RECORD, Color(0.45, 0.95, 0.65), 10.0)
	_log("archive_consult", "success_session_only")
	_refresh_state_fixtures()


func _unlock_shortcut() -> void:
	if _shortcut_unlocked or player.global_position.x <= 2.15:
		return
	_shortcut_unlocked = true
	if _inner_door != null:
		var shape := _inner_door.get_child(0) as CollisionShape3D
		shape.set_deferred("disabled", true)
		_inner_door.visible = false
	_banner("Vestíbulo oeste desbloqueado", "La puerta queda abierta en ambos sentidos. La compuerta exterior lleva a Containment.", Color(0.45, 0.95, 0.65), 5.0)
	_log("shortcut", "unlocked_from_archive_side")


func _open_outer_hatch() -> void:
	if not _shortcut_unlocked or player.global_position.x >= 1.8:
		return
	_outer_hatch_open = true
	if _outer_door_shape != null:
		_outer_door_shape.set_deferred("disabled", true)
	if _outer_door_mesh != null:
		_outer_door_mesh.visible = false
	_banner("Compuerta abierta", "Al cruzar se sincronizará la auditoría de mantenimiento.", Color(0.95, 0.67, 0.25), 4.0)
	_log("outer_hatch", "opened")


func _begin_handoff() -> void:
	if _handoff_started:
		return
	_handoff_started = true
	# Latch Elena at the hatch during the short synchronization beat; the outside is a scene transition, not a fall.
	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	player.set_process_input(false)
	var transmitted := ", ".join(PackedStringArray(_audit_events))
	_log("audit_transmitted", transmitted)
	_log("containment_trigger", "outer_hatch_crossed")
	hud.call("set_objective", "OBJETIVO  /  Sobrevive a la respuesta de Helix")
	hud.call("show_banner", "SINCRONIZACIÓN DETECTADA", "Helix ha recibido la auditoría. Containment activado.", Color(1.0, 0.22, 0.16), HANDOFF_DELAY)
	await get_tree().create_timer(HANDOFF_DELAY).timeout
	var error: Error = get_tree().change_scene_to_file(CHASE_SCENE)
	if error != OK:
		push_error("No se pudo abrir la escena de Containment: %s" % error)


func _call_lift(destination: String) -> void:
	var accepted: bool = lift.call_to(destination)
	_log("lift_call", "%s:%s" % [destination, "accepted" if accepted else "refused"])
	if not accepted:
		_banner("Elevador sin alimentación", "El interruptor de mantenimiento del foso controla la plataforma.", Color(1.0, 0.67, 0.25), 3.5)


func _diagnostic_text() -> String:
	var info: Dictionary = circuit.inspect()
	var current: String
	match str(info["current"]):
		"ARCHIVE_STABLE":
			current = "ARCHIVO ESTABLE"
		"RECOVERY_TRIPPED_FAULT_PRESENT":
			current = "PROTECCIÓN DISPARADA · FALLO PRESENTE"
		"RECOVERY_TRIPPED_REARM_PENDING":
			current = "PROTECCIÓN DISPARADA · REARME PENDIENTE"
		_:
			current = "ARCHIVO SIN SUMINISTRO"
	return "%s\nDestino: %s\nEnsayo: %s\nProtección: %s\nÚltimo disparo: %s" % [
		current,
		str(info["destination"]),
		"aislado" if circuit.trial_isolated else "conectado",
		"disponible" if circuit.protection_available else "disparada",
		"DEMANDA_SIMULTANEA" if str(info["last_trip"]) != "" else "ninguno"
	]


func _refresh_state_fixtures() -> void:
	if _status_panel_label == null:
		return
	var info: Dictionary = circuit.inspect()
	var output: Dictionary = circuit.outputs()
	_status_panel_label.text = "DESTINO  %s\nARCHIVO %s · ENSAYO %s\nPROTECCIÓN  %s\nÚLTIMO DISPARO  %s" % [
		str(info["destination"]),
		"ESTABLE" if bool(output["archive"]) else "NO DISPONIBLE",
		"AISLADO" if circuit.trial_isolated else "CONECTADO",
		"DISPONIBLE" if circuit.protection_available else "DISPARADA",
		"DEMANDA_SIMULTANEA" if str(info["last_trip"]) != "" else "NINGUNO"
	]
	if _archive_status_label != null:
		_archive_status_label.text = "SUMINISTRO\nESTABLE" if bool(output["archive"]) else "NO\nDISPONIBLE"
		_archive_status_label.modulate = Color(0.45, 1.0, 0.65) if bool(output["archive"]) else Color(1.0, 0.63, 0.35)


func _refresh_dynamic_lift_button() -> void:
	if _lift_deck_button == null or lift == null:
		return
	_lift_deck_button.position = Vector3(26.0, float(lift.platform_y) + 0.06, -3.0)
	if _lift_deck_label != null:
		_lift_deck_label.position = Vector3(26.0, float(lift.platform_y) + 0.32, -3.0)


func _update_safe_point() -> void:
	if not player.is_on_floor():
		return
	var p: Vector3 = player.global_position
	if p.y > 2.7:
		_safe_point = Vector3(26.0, 3.2, -6.2)
	elif p.y < -1.55 and p.y > -3.0:
		_safe_point = Vector3(25.0, -1.8, 7.0)
	elif absf(p.y) < 0.45:
		if p.x >= 23.5 and p.x <= 26.5 and p.z >= 8.0 and p.z <= 12.0:
			_safe_point = Vector3(25.0, 0.2, 11.0)
		elif p.x < 18.0 and p.z > 4.5:
			_safe_point = Vector3(3.0, 0.2, 7.0)
		else:
			_safe_point = Vector3(25.0, 0.2, 9.0)


func _current_audit_events() -> Array[String]:
	return _audit_events.duplicate()


func _log(id: String, detail: String = "") -> void:
	print("[phase1 %.1fs] %s %s" % [Time.get_ticks_msec() / 1000.0, id, detail])


func _banner(title: String, body: String, accent: Color, seconds: float) -> void:
	if hud != null:
		hud.call("show_banner", title, body, accent, seconds)
