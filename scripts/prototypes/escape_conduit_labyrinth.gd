extends Node3D
## Playable conduit-escape mission, opened from the main menu. The route is loaded from the owner-approved
## geometry JSON and converted from its plan coordinates; no alternative route is built at N1.
const PlayerScript := preload("res://scripts/prototypes/phase1_spatial_player.gd")
const MissionState := preload("res://scripts/phase1/escape_mission_state.gd")
const ActorScript := preload("res://scripts/phase1/escape_human_actor.gd")
const SfxSynth := preload("res://scripts/audio/sfx_synth.gd")
const B := preload("res://scripts/components/build_util.gd")
const ROUTE_SPEC := "res://docs/design/assets/escape_conduit/geometria_ruta.json"

const WIDTH := 3.2
const HEIGHT := 3.6
const SLAB := 0.30
const WALL := 0.25
const MAP_ORIGIN := Vector2(80.0, 100.0)
const MAIN_LIGHT := Color(1.0, 0.78, 0.38)
const DEAD_LIGHT := Color(0.32, 0.39, 0.48)
const ROOM_WALL := Color(0.25, 0.29, 0.31)
const FLOOR_COLOR := Color(0.22, 0.26, 0.28)
const INTERACTION_REACH := 2.4
const N1_MAP := Vector2(80.0, 87.0)
const SHELF_MAP := Vector2(80.0, 83.5)
const ALARM_BUTTON_MAP := Vector2(78.0, 87.0)
const CABINET_MAP := Vector2(80.0, 89.0)
const GUARD_INTERCEPT_MAP := Vector2(75.0, 46.0)
const ALARM_GATE_MAP := Vector2(90.0, 46.0)
const GUARD_START_MAP := Vector2(92.0, 20.0)
const MAX_WORKER_ROUTE_RETRIES := 3

var player
var hud: Label
var mission_state: EscapeMissionState
var route_spec: Dictionary = {}
var route_map: Array[Vector2] = []
var route_world: Array[Vector3] = []
var actors: Dictionary = {}
var interactables: Dictionary = {}
var current_interaction := ""
var carried_extinguisher: Node3D
var security_door: Node3D
var extinguisher_cloud: GPUParticles3D
var alarm_player: AudioStreamPlayer3D
var _guard_arrivals: Dictionary = {"G1": false, "G2": false}
var _worker_route_retries: Dictionary = {"T2": 0, "T3": 0}
var _cinematic_busy := false
var _encounter_triggered := false
var _alarm_press_pending := false
var _held_route_backup := true
var complete := false
var elapsed := 0.0
var _materials: Dictionary = {}

func _ready() -> void:
	mission_state = MissionState.new()
	_build_environment()
	_load_authoritative_route()
	_build_geometry()
	_build_interactables()
	await _build_player()
	_build_actor_roster()
	_build_alarm()
	_build_hud()
	_build_encounter_trigger()
	_build_forest_trigger()
	print("[escape_mission] route loaded from %s; S-to-A3 path length %.1f m" % [ROUTE_SPEC, _route_length()])

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if alarm_player != null:
		alarm_player.stop()
		alarm_player.stream = null
	if get_tree() != null:
		get_tree().paused = false

func _process(delta: float) -> void:
	if player == null:
		return
	elapsed += delta
	player.set("movement_basis", Basis(Vector3.UP, float(player.get("orbit_yaw"))))
	_update_interaction_prompt()

func _physics_process(_delta: float) -> void:
	if player == null or complete:
		return
	if not mission_state.alarm_active and player.global_position.distance_to(_map_to_world(Vector2(90.0, 46.0), -2.0)) < 1.7:
		security_door.call("set_meta", "waiting_for_alarm", true)

func _unhandled_input(event: InputEvent) -> void:
	if complete or player == null or _cinematic_busy:
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		_try_interact()
	elif event.is_action_pressed("attack_primary") and not event.is_echo():
		_try_strike()

func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.025, 0.035, 0.045)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.43, 0.49, 0.52)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.08, 0.11, 0.13)
	env.fog_density = 0.003
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-42.0, -24.0, 0.0)
	moon.light_energy = 0.28
	moon.light_color = Color(0.66, 0.75, 0.82)
	moon.shadow_enabled = true
	add_child(moon)

func _mat(key: String, color: Color, emission: float = 0.0) -> Material:
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.88
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission
	_materials[key] = m
	return m

func _box(label: String, size: Vector3, pos: Vector3, color: Color, collision := true, emission := 0.0) -> Node3D:
	var node: Node3D
	if collision:
		node = B.solid_box(self, size, pos, color)
	else:
		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = size
		mi.mesh = mesh
		mi.material_override = _mat(label, color, emission)
		mi.position = pos
		add_child(mi)
		node = mi
	node.name = label
	if node is StaticBody3D:
		var mi := node.get_child(1) as MeshInstance3D
		if mi != null:
			mi.material_override = _mat(label, color, emission)
	return node

func _oriented_box(label: String, size: Vector3, pos: Vector3, basis: Basis, color: Color, collision := true, emission := 0.0) -> Node3D:
	var root: Node3D
	if collision:
		var body := StaticBody3D.new()
		body.name = label
		body.collision_layer = 1
		body.collision_mask = 0
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
		root = body
	else:
		root = Node3D.new()
		root.name = label
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _mat(label, color, emission)
	root.add_child(mesh_instance)
	root.transform = Transform3D(basis, pos)
	add_child(root)
	return root


func _segment(a: Vector3, b: Vector3, width: float = WIDTH, height: float = HEIGHT, lit: bool = true, label: String = "Conduit", build_floor := true) -> void:
	var delta := b - a
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.05:
		return
	var length := delta.length()
	var yaw := atan2(delta.x, delta.z)
	var pitch := -atan2(delta.y, horizontal)
	var basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch)
	var center := (a + b) * 0.5
	var right := basis.x.normalized()
	var wall_color := ROOM_WALL
	if build_floor:
		_oriented_box(label + "_Floor", Vector3(width, SLAB, length), center - Vector3.UP * SLAB * 0.5, basis, FLOOR_COLOR)
	_oriented_box(label + "_Ceiling", Vector3(width, SLAB, length), center + Vector3.UP * (height + SLAB * 0.5), basis, wall_color)
	for side in [-1.0, 1.0]:
		_oriented_box(label + ("_Wall_L" if side < 0.0 else "_Wall_R"), Vector3(WALL, height, length), center + right * side * (width * 0.5 + WALL * 0.5) + Vector3.UP * (height * 0.5), basis, wall_color)
	if lit:
		var count := maxi(1, int(ceil(length / 8.0)))
		for i in count:
			var t := (float(i) + 0.5) / float(count)
			_add_light(label + "_PracticalLight", a.lerp(b, t) + Vector3.UP * (height - 0.22), MAIN_LIGHT, 1.65, 8.0)
	else:
		_add_light(label + "_BlockedBranchLight", center + Vector3.UP * (height - 0.3), DEAD_LIGHT, 0.22, 4.5)
	# Overhead service pipes are visible but remain above the 1.72 m actor/player capsules.
	if length > 4.0:
		for side in [-1.0, 1.0]:
			_oriented_box(label + "_OverheadPipe", Vector3(0.12, 0.12, length), center + right * side * (width * 0.28) + Vector3.UP * (height - 0.62), basis, Color(0.45, 0.32, 0.18), false)


func _build_stairs(a: Vector3, b: Vector3, label: String) -> void:
	var delta := b - a
	var horizontal := Vector2(delta.x, delta.z)
	var yaw := atan2(delta.x, delta.z)
	var basis := Basis(Vector3.UP, yaw)
	_segment(a, b, WIDTH, HEIGHT, true, label, false)
	var count := 8
	var riser := absf(delta.y) / float(count)
	for i in count:
		var depth := horizontal.length() / float(count)
		var top_height := riser * float(i + 1)
		var step_center := a.lerp(b, (float(i) + 0.5) / float(count))
		step_center.y = a.y - top_height * 0.5
		_oriented_box(label + "_Step_%02d" % i, Vector3(WIDTH, top_height, depth + 0.02), step_center, basis, Color(0.28, 0.32, 0.34))

func _add_light(label: String, pos: Vector3, color: Color, energy: float, radius: float) -> void:
	var light := OmniLight3D.new()
	light.name = label
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.omni_attenuation = 1.5
	light.shadow_enabled = false
	add_child(light)

func _label(text: String, pos: Vector3, color: Color = Color(0.92, 0.94, 0.95), size: int = 42) -> void:
	B.label3d(self, text, pos, size, color)

func _load_authoritative_route() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(ROUTE_SPEC))
	if not parsed is Dictionary:
		push_error("Escape route geometry could not be parsed: %s" % ROUTE_SPEC)
		return
	route_spec = parsed
	var raw_main: Array = route_spec.get("route_S_to_A2", [])
	for i in raw_main.size():
		var raw: Array = raw_main[i]
		route_map.append(Vector2(float(raw[0]), float(raw[1])))
		if i + 1 < raw_main.size():
			var next_raw: Array = raw_main[i + 1]
			if is_equal_approx(float(raw[0]), 20.0) and is_equal_approx(float(raw[1]), 60.0) and is_equal_approx(float(next_raw[0]), 43.0) and is_equal_approx(float(next_raw[1]), 60.0):
				route_map.append(Vector2(30.0, 60.0))
				route_map.append(Vector2(34.0, 60.0))
	for point in route_map:
		route_world.append(_map_to_world(point, _main_route_height(point)))
	var raw_a2: Array = route_spec.get("route_A2_plan", [])
	var total_horizontal := 0.0
	for i in range(1, raw_a2.size()):
		var a: Array = raw_a2[i - 1]
		var b: Array = raw_a2[i]
		total_horizontal += Vector2(float(b[0]) - float(a[0]), float(b[1]) - float(a[1])).length()
	var traveled := 0.0
	for i in range(1, raw_a2.size()):
		var a: Array = raw_a2[i - 1]
		var b: Array = raw_a2[i]
		var from_map := Vector2(float(a[0]), float(a[1]))
		var to_map := Vector2(float(b[0]), float(b[1]))
		traveled += from_map.distance_to(to_map)
		route_map.append(to_map)
		var elevation := -2.0 + float(route_spec.get("A2_rise_m", 10.0)) * traveled / total_horizontal
		route_world.append(_map_to_world(to_map, elevation))


func _main_route_height(point: Vector2) -> float:
	if is_equal_approx(point.y, 60.0):
		if point.x <= 30.0:
			return 0.0
		if point.x >= 34.0:
			return -2.0
		return -2.0 * (point.x - 30.0) / 4.0
	return 0.0 if point.y > 60.0 else -2.0


func _map_to_world(point: Vector2, elevation: float) -> Vector3:
	return Vector3(point.x - MAP_ORIGIN.x, elevation, MAP_ORIGIN.y - point.y)


func _route_length() -> float:
	var length := 0.0
	for i in range(route_world.size() - 1):
		length += route_world[i].distance_to(route_world[i + 1])
	return length


func _nearest_route_index(point: Vector2) -> int:
	var nearest := 0
	var nearest_distance := INF
	for i in route_map.size():
		var distance := route_map[i].distance_to(point)
		if distance < nearest_distance:
			nearest = i
			nearest_distance = distance
	return nearest


func _route_slice(start_map: Vector2, end_map: Vector2) -> Array[Vector3]:
	var start_index := _nearest_route_index(start_map)
	var end_index := _nearest_route_index(end_map)
	var points: Array[Vector3] = []
	if start_index <= end_index:
		for i in range(start_index, end_index + 1):
			points.append(route_world[i])
	else:
		for i in range(start_index, end_index - 1, -1):
			points.append(route_world[i])
	return points


func _build_geometry() -> void:
	if route_world.size() < 2:
		return
	for i in range(route_world.size() - 1):
		var a := route_world[i]
		var b := route_world[i + 1]
		var stair := is_equal_approx(a.y, 0.0) and is_equal_approx(b.y, -2.0) and absf(a.x - b.x) > 3.5 and absf(a.z - b.z) < 0.01
		var label := "EscapeRoute_%02d" % i
		if stair:
			_build_stairs(a, b, label + "_N6_Stair")
		else:
			_segment(a, b, WIDTH, HEIGHT, true, label)
		if i > 0 and i < route_world.size() - 1:
			var incoming := (route_map[i] - route_map[i - 1]).normalized()
			var outgoing := (route_map[i + 1] - route_map[i]).normalized()
			if absf(incoming.cross(outgoing)) > 0.01:
				var corner := route_world[i]
				_oriented_box("Route_Junction_%02d" % i, Vector3(WIDTH, SLAB, WIDTH), corner - Vector3.UP * (SLAB * 0.5 - 0.004), Basis.IDENTITY, FLOOR_COLOR)
	_build_n1_encounter_fork()
	_build_exterior()
	_build_route_landmarks()
	# Physical cap directly ahead of N1: the northbound corridor shown on the reference is not an egress.
	_box("N1_NORTH_ROUTE_BLOCKED", Vector3(6.5, HEIGHT, WALL), Vector3(0.0, HEIGHT * 0.5, 18.2), Color(0.30, 0.33, 0.35))
	_label("N1 · GIRO OESTE / TURN WEST", Vector3(-1.4, 2.6, 12.8), Color(0.92, 0.78, 0.42), 24)


func _build_n1_encounter_fork() -> void:
	_box("N1_Foyer_Floor", Vector3(6.0, SLAB, 6.2), Vector3(0.0, -SLAB * 0.5, 15.8), FLOOR_COLOR)
	_box("N1_Foyer_Ceiling", Vector3(6.0, SLAB, 6.2), Vector3(0.0, HEIGHT + SLAB * 0.5, 15.8), ROOM_WALL)
	_box("N1_Foyer_Wall_L", Vector3(WALL, HEIGHT, 6.2), Vector3(-3.0, HEIGHT * 0.5, 15.8), ROOM_WALL)
	_box("N1_Foyer_Wall_R", Vector3(WALL, HEIGHT, 6.2), Vector3(3.0, HEIGHT * 0.5, 15.8), ROOM_WALL)
	_box("N1_Encounter_Practical", Vector3(2.0, 0.08, 0.35), Vector3(0.0, HEIGHT - 0.18, 15.8), Color(0.78, 0.66, 0.42), false, 1.2)


func _build_exterior() -> void:
	var exit_point: Vector3 = route_world.back()
	_box("A3_Secondary_Road", Vector3(18.0, SLAB, 8.0), Vector3(exit_point.x + 6.0, 8.0 - SLAB * 0.5, exit_point.z), Color(0.17, 0.20, 0.22))
	_box("Forest_Ground", Vector3(28.0, SLAB, 22.0), Vector3(exit_point.x + 20.0, 8.0 - SLAB * 0.5, exit_point.z), Color(0.13, 0.21, 0.15))
	for side in [-1.0, 1.0]:
		_box("A3_Exit_Frame_Post", Vector3(0.25, 2.5, 0.25), exit_point + Vector3(0.0, 1.25, side * (WIDTH * 0.5 + 0.1)), Color(0.25, 0.30, 0.33))
	_box("A3_Exit_Frame_Header", Vector3(0.25, 0.25, WIDTH + 0.45), exit_point + Vector3(0.0, 2.5, 0.0), Color(0.25, 0.30, 0.33))
	var tree_positions := [Vector2(11, -8), Vector2(17, -10), Vector2(22, -7), Vector2(25, -11), Vector2(12, 7), Vector2(18, 10), Vector2(23, 6), Vector2(26, 12), Vector2(29, -9), Vector2(30, 1)]
	for i in tree_positions.size():
		var offset: Vector2 = tree_positions[i]
		var x: float = exit_point.x + offset.x
		var z: float = exit_point.z + offset.y
		_box("Forest_Tree_Trunk_%02d" % i, Vector3(0.38, 2.4, 0.38), Vector3(x, 9.2, z), Color(0.20, 0.15, 0.10))
		var crown := MeshInstance3D.new()
		crown.name = "Forest_Canopy_%02d" % i
		var mesh := SphereMesh.new()
		mesh.radius = 1.7
		mesh.height = 3.2
		crown.mesh = mesh
		crown.position = Vector3(x, 10.9, z)
		crown.material_override = _mat("forest_canopy", Color(0.10, 0.24, 0.15))
		add_child(crown)
	_label("A3 · CARRETERA SECUNDARIA", exit_point + Vector3(6.0, 4.0, 4.0), Color(0.86, 0.91, 0.93), 26)
	_label("BOSQUE · OCULTACIÓN", exit_point + Vector3(20.0, 4.0, 0.0), Color(0.70, 0.88, 0.73), 28)


func _build_route_landmarks() -> void:
	_label("SECTOR B · BOMBEO Y TRATAMIENTO", _map_to_world(Vector2(47.0, 80.0), 2.5), Color(0.53, 0.77, 0.95), 22)
	_label("SECTOR D · DRENAJE Y SERVICIO", _map_to_world(Vector2(70.0, 30.0), 1.2), Color(0.70, 0.87, 0.72), 22)
	_label("A2 · CONDUCCIÓN SECA +10°", _map_to_world(Vector2(101.0, 6.0), 3.8), Color(1.0, 0.78, 0.38), 22)
	# Restricted side accesses are real solid door panels; they cannot become shortcuts through a room.
	for i in 3:
		var index := int(float(route_world.size() - 5) * float(i + 1) / 4.0)
		var p := route_world[index]
		_box("Restricted_Door_%02d" % i, Vector3(WIDTH - 0.35, 2.6, WALL), Vector3(p.x, p.y + 1.3, p.z + 4.0), Color(0.25, 0.27, 0.29))
		_box("Restricted_Door_Light_%02d" % i, Vector3(0.18, 0.12, 0.08), Vector3(p.x, p.y + 2.1, p.z + 3.82), Color(0.65, 0.13, 0.10), false, 0.9)

func _build_player() -> void:
	player = PlayerScript.new()
	player.name = "Elena_EscapeMission"
	player.position = _map_to_world(Vector2(80.0, 100.0), 0.0) + Vector3.UP * 0.05
	add_child(player)
	player.set("collision_mask", int(player.get("collision_mask")) | 4)
	player.set("orbit_yaw", 0.0)
	player.set("orbit_pitch", 0.0)
	player.set("movement_basis", Basis.IDENTITY)
	await get_tree().process_frame
	if player.get("arm") != null:
		player.arm.spring_length = 0.05
		player.arm.position.x = 0.0
	if player.get("pivot") != null:
		player.pivot.position.y = 1.58
	if player.get("view") != null:
		player.view.fov = 78.0
	player.set("camera_mode", "explore")
	player.set("input_enabled", true)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "EscapeMissionHUD"
	add_child(layer)
	hud = Label.new()
	hud.name = "Objective"
	hud.position = Vector2(24, 22)
	hud.size = Vector2(1120, 52)
	hud.add_theme_font_size_override("font_size", 20)
	hud.add_theme_color_override("font_color", Color(0.93, 0.95, 0.96))
	hud.text = NarrativeTextManager.get_option("escape_objective_reach_forest", "Reach the forest and hide.")
	layer.add_child(hud)
	var prompt := Label.new()
	prompt.name = "InteractionPrompt"
	prompt.position = Vector2(24, 80)
	prompt.size = Vector2(1120, 46)
	prompt.add_theme_font_size_override("font_size", 22)
	prompt.add_theme_color_override("font_color", Color(1.0, 0.80, 0.35))
	layer.add_child(prompt)
	var controls := Label.new()
	controls.name = "Controls"
	controls.position = Vector2(24, 126)
	controls.size = Vector2(1120, 36)
	controls.add_theme_font_size_override("font_size", 15)
	controls.add_theme_color_override("font_color", Color(0.73, 0.78, 0.81))
	controls.text = NarrativeTextManager.get_option(
		"escape_controls_hint",
		"Move: WASD · Look: Mouse · Interact: E/F · Strike: J/K · Run: Shift · Jump: Space"
	)
	layer.add_child(controls)
	var alarm_status := Label.new()
	alarm_status.name = "AlarmStatus"
	alarm_status.position = Vector2(24, 164)
	alarm_status.size = Vector2(620, 32)
	alarm_status.add_theme_font_size_override("font_size", 16)
	alarm_status.add_theme_color_override("font_color", Color(0.75, 0.82, 0.84))
	alarm_status.text = NarrativeTextManager.get_option("escape_alarm_inactive", "ALARM · INACTIVE")
	layer.add_child(alarm_status)

func _build_forest_trigger() -> void:
	var area := Area3D.new()
	area.name = "ESC_FOREST_HIDEOUT_TRIGGER"
	area.position = route_world.back() + Vector3(21.0, 1.2, 0.0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(8.0, 3.0, 12.0)
	shape.shape = box
	area.add_child(shape)
	area.body_entered.connect(_on_forest_entered)
	add_child(area)

func _on_forest_entered(body: Node3D) -> void:
	if complete or body != player:
		return
	if not mission_state.complete_escape_at_forest(true):
		return
	complete = true
	player.velocity = Vector3.ZERO
	player.set("input_enabled", false)
	hud.text = NarrativeTextManager.get_option("escape_complete_message", "Elena reaches the forest and is temporarily concealed.")
	get_node("EscapeMissionHUD/InteractionPrompt").text = ""
	print("[escape_mission] FOREST_HIDEOUT reached after %.1f s" % elapsed)


func _build_interactables() -> void:
	var shelf_position := _map_to_world(SHELF_MAP, 0.0)
	var shelf := _make_interactable_body(
		"ESC_SHELF",
		Vector3(WIDTH, 2.15, 0.55),
		shelf_position + Vector3(0.0, 1.075, 0.0),
		Color(0.36, 0.31, 0.24)
	)
	var shelf_collision := shelf.get_node("CollisionShape3D") as CollisionShape3D
	shelf_collision.disabled = true
	interactables["shelf"] = {
		"node": shelf,
		"collision": shelf_collision,
		"at": shelf_position,
		"prompt": "escape_prompt_shelf",
	}

	var cabinet_position := _map_to_world(CABINET_MAP, 0.0)
	var cabinet := _make_interactable_body(
		"ESC_CABINET",
		Vector3(WIDTH, 2.3, 0.9),
		cabinet_position + Vector3(0.0, 1.15, 0.0),
		Color(0.30, 0.34, 0.37)
	)
	var cabinet_collision := cabinet.get_node("CollisionShape3D") as CollisionShape3D
	cabinet_collision.disabled = true
	interactables["cabinet"] = {
		"node": cabinet,
		"collision": cabinet_collision,
		"at": cabinet_position,
		"prompt": "escape_prompt_cabinet",
	}

	var extinguisher_position := _map_to_world(GUARD_INTERCEPT_MAP, -2.0)
	var extinguisher := _box(
		"ESC_EXTINGUISHER",
		Vector3(0.32, 0.78, 0.32),
		extinguisher_position + Vector3(0.0, 0.39, 0.0),
		Color(0.78, 0.12, 0.08)
	)
	interactables["extinguisher"] = {
		"node": extinguisher,
		"at": extinguisher_position,
		"prompt": "escape_prompt_extinguisher",
	}

	var button_position := _map_to_world(ALARM_BUTTON_MAP, 0.0)
	var button := _box(
		"ESC_HUMAN_ALARM_BUTTON",
		Vector3(0.18, 0.35, 0.18),
		button_position + Vector3(0.0, 1.05, 0.0),
		Color(0.75, 0.08, 0.06),
		false,
		1.0
	)
	button.set_meta("activation", "T1_only")
	_label("P · ALARM", button_position + Vector3(0.0, 1.55, 0.0), Color(1.0, 0.55, 0.42), 18)

	var gate_position := _map_to_world(ALARM_GATE_MAP, -2.0)
	security_door = _make_interactable_body(
		"ESC_SECURITY_GATE",
		Vector3(0.35, 2.55, WIDTH),
		gate_position + Vector3(0.0, 1.275, 0.0),
		Color(0.31, 0.34, 0.36)
	)


func _make_interactable_body(label: String, size: Vector3, center: Vector3, color: Color) -> AnimatableBody3D:
	var body := AnimatableBody3D.new()
	body.name = label
	body.collision_layer = 1
	body.collision_mask = 0
	body.sync_to_physics = true
	body.position = center
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _mat(label, color)
	body.add_child(mesh_instance)
	add_child(body)
	return body


func _build_actor_roster() -> void:
	_add_actor("T1", "helix_tech_a", Vector3(-1.0, 0.0, 15.8))
	_add_actor("T2", "helix_tech_b", Vector3(0.0, 0.0, 17.4))
	_add_actor("T3", "helix_supervisor", Vector3(1.0, 0.0, 15.8))
	_add_actor("G1", "helix_guard_a", _map_to_world(GUARD_START_MAP, -2.0))
	_add_actor("G2", "helix_guard_b", _map_to_world(GUARD_START_MAP, -2.0) + Vector3(0.0, 0.0, 1.3))


func _add_actor(actor_id: String, person_id: String, world_position: Vector3) -> void:
	var actor := ActorScript.new()
	actor.configure(actor_id, person_id)
	actor.position = world_position
	actor.route_blocked.connect(_on_actor_route_blocked)
	actor.path_finished.connect(_on_actor_path_finished)
	actors[actor_id] = actor
	add_child(actor)


func _build_alarm() -> void:
	alarm_player = AudioStreamPlayer3D.new()
	alarm_player.name = "EscapeAlarmAudio"
	alarm_player.stream = SfxSynth.alarm_pip()
	alarm_player.volume_db = -10.0
	alarm_player.bus = "SFX"
	alarm_player.position = _map_to_world(ALARM_BUTTON_MAP, 0.0) + Vector3(0.0, 1.2, 0.0)
	add_child(alarm_player)


func _build_encounter_trigger() -> void:
	var area := Area3D.new()
	area.name = "ESC_N1_ENCOUNTER_TRIGGER"
	area.position = _map_to_world(N1_MAP, 0.8)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(6.0, 2.8, 5.0)
	shape.shape = box
	area.add_child(shape)
	area.body_entered.connect(_on_encounter_entered)
	add_child(area)


func _on_encounter_entered(body: Node3D) -> void:
	if body != player or _encounter_triggered:
		return
	_encounter_triggered = true
	for worker_id in ["T2", "T3"]:
		var worker: Node = actors[worker_id]
		worker.call("follow_path", _t1_alarm_path_to_cabinet(), 3.2)
	print("[escape_mission] N1 encounter started; alarm remains inactive")


func _update_interaction_prompt() -> void:
	if hud == null or not _encounter_triggered:
		current_interaction = ""
		return
	var prompt := get_node("EscapeMissionHUD/InteractionPrompt") as Label
	var best_distance := INTERACTION_REACH
	var best_id := ""
	var player_position: Vector3 = player.global_position
	for id in ["shelf", "cabinet", "extinguisher"]:
		if not _interaction_available(id):
			continue
		var data: Dictionary = interactables[id]
		var at: Vector3 = data["at"]
		var horizontal_distance := Vector2(at.x - player_position.x, at.z - player_position.z).length()
		if absf(at.y - player_position.y) > 1.25 or horizontal_distance > best_distance:
			continue
		best_id = id
		best_distance = horizontal_distance
	current_interaction = best_id
	if best_id.is_empty():
		prompt.text = ""
		return
	var prompt_key: String = interactables[best_id]["prompt"]
	if best_id == "extinguisher" and mission_state.extinguisher_picked_up:
		prompt_key = "escape_prompt_extinguisher_use"
	prompt.text = NarrativeTextManager.get_option(prompt_key)


func _interaction_available(id: String) -> bool:
	match id:
		"shelf":
			return not mission_state.shelf_fallen
		"cabinet":
			return mission_state.shelf_fallen and not mission_state.cabinet_fallen
		"extinguisher":
			return (
				mission_state.player_beat == EscapeMissionState.PlayerBeat.EXTINGUISHER_INTERACTION
				and not mission_state.extinguisher_discharged
			)
	return false


func _try_interact() -> void:
	_update_interaction_prompt()
	if current_interaction.is_empty() or not interactables.has(current_interaction):
		return
	var interaction_id := current_interaction
	match interaction_id:
		"shelf":
			if not mission_state.perform_shelving_interaction():
				return
			var shelf_collision := interactables["shelf"]["collision"] as CollisionShape3D
			shelf_collision.disabled = false
			_topple_prop(interactables["shelf"]["node"], Vector3(0.0, 0.0, PI * 0.5))
			(actors["T1"] as Node).call("knock_down")
			(actors["T2"] as Node).call("jump_barrier")
			(actors["T3"] as Node).call("jump_barrier")
			_finish_shelf_sequence()
		"cabinet":
			if not mission_state.topple_cabinet():
				return
			var cabinet_collision := interactables["cabinet"]["collision"] as CollisionShape3D
			cabinet_collision.disabled = false
			_topple_prop(interactables["cabinet"]["node"], Vector3(0.0, 0.0, PI * 0.5))
			for worker_id in ["T2", "T3"]:
				(actors[worker_id] as Node).call("stop_at_barrier")
		"extinguisher":
			if not mission_state.extinguisher_picked_up:
				if not mission_state.pick_up_extinguisher():
					return
				var extinguisher_node: Node3D = interactables["extinguisher"]["node"]
				extinguisher_node.queue_free()
				carried_extinguisher = _make_carried_extinguisher()
				player.add_child(carried_extinguisher)
				carried_extinguisher.position = Vector3(0.3, 1.2, -0.4)
				return
			if not mission_state.discharge_extinguisher():
				return
			if is_instance_valid(carried_extinguisher):
				carried_extinguisher.queue_free()
			carried_extinguisher = null
			_spawn_extinguisher_cloud()


func _finish_shelf_sequence() -> void:
	_cinematic_busy = true
	await get_tree().create_timer(0.8).timeout
	mission_state.finish_shelving_choreography()
	await get_tree().create_timer(1.4).timeout
	var worker_t1: Node = actors["T1"]
	worker_t1.call("recover")
	if mission_state.recover_t1_and_start_alarm_route():
		worker_t1.call("follow_path", _t1_alarm_path(), 2.5)
	_cinematic_busy = false


func _t1_alarm_path() -> Array[Vector3]:
	return [
		Vector3(2.0, 0.0, 15.5),
		Vector3(2.0, 0.0, 13.6),
		Vector3(-2.0, 0.0, 13.6),
		_map_to_world(ALARM_BUTTON_MAP, 0.0),
	]


func _t1_alarm_path_to_cabinet() -> Array[Vector3]:
	var path := _t1_alarm_path()
	path.pop_back()
	path.append(Vector3(0.0, 0.0, 13.6))
	path.append(Vector3(0.7, 0.0, 13.6))
	path.append(Vector3(0.7, 0.0, 11.0))
	path.append(_map_to_world(CABINET_MAP, 0.0))
	return path


func _topple_prop(prop: Node3D, target_rotation: Vector3) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(prop, "rotation", target_rotation, 0.65)


func _make_carried_extinguisher() -> Node3D:
	var root := Node3D.new()
	root.name = "CarriedExtinguisher"
	var mesh_instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.13
	mesh.bottom_radius = 0.13
	mesh.height = 0.58
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _mat("carried_extinguisher", Color(0.78, 0.12, 0.08))
	root.add_child(mesh_instance)
	return root


func _spawn_extinguisher_cloud() -> void:
	extinguisher_cloud = GPUParticles3D.new()
	extinguisher_cloud.name = "ExtinguisherCloud"
	extinguisher_cloud.position = _map_to_world(GUARD_INTERCEPT_MAP, -2.0) + Vector3(0.0, 1.2, 0.0)
	extinguisher_cloud.amount = 80
	extinguisher_cloud.lifetime = 2.2
	extinguisher_cloud.one_shot = true
	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process_material.emission_sphere_radius = 1.2
	process_material.direction = Vector3(0.0, 0.2, 0.0)
	process_material.spread = 65.0
	process_material.initial_velocity_min = 0.3
	process_material.initial_velocity_max = 1.4
	process_material.gravity = Vector3.ZERO
	process_material.scale_min = 0.18
	process_material.scale_max = 0.4
	extinguisher_cloud.process_material = process_material
	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.12
	particle_mesh.height = 0.24
	var particle_material := StandardMaterial3D.new()
	particle_material.albedo_color = Color(0.88, 0.9, 0.82, 0.68)
	particle_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	particle_mesh.material = particle_material
	extinguisher_cloud.draw_pass_1 = particle_mesh
	add_child(extinguisher_cloud)
	extinguisher_cloud.restart()


func _try_strike() -> void:
	if not mission_state.extinguisher_discharged:
		return
	var nearest_guard_id := ""
	var nearest_distance := INTERACTION_REACH
	for guard_id in ["G1", "G2"]:
		if mission_state.guard_state[guard_id] != EscapeMissionState.GuardState.DISORIENTED:
			continue
		var guard: Node3D = actors[guard_id]
		var distance: float = player.global_position.distance_to(guard.global_position)
		if distance < nearest_distance:
			nearest_guard_id = guard_id
			nearest_distance = distance
	if nearest_guard_id.is_empty() or not mission_state.strike_guard(nearest_guard_id):
		return
	(actors[nearest_guard_id] as Node).call("neutralize")
	if mission_state.all_guards_neutralized() and mission_state.begin_escape_run():
		hud.text = NarrativeTextManager.get_option("escape_objective_reach_forest", "Reach the forest and hide.")


func _on_actor_path_finished(actor_id: String) -> void:
	if actor_id == "T1":
		if not mission_state.t1_reach_alarm_button() or _alarm_press_pending:
			return
		_press_alarm_after_delay()
	elif actor_id in ["G1", "G2"]:
		_guard_arrivals[actor_id] = true
		if _guard_arrivals["G1"] and _guard_arrivals["G2"]:
			mission_state.guards_reach_intercept()


func _press_alarm_after_delay() -> void:
	_alarm_press_pending = true
	await get_tree().create_timer(0.6).timeout
	if mission_state.t1_press_alarm_button():
		if alarm_player != null:
			alarm_player.play()
		var alarm_status := get_node("EscapeMissionHUD/AlarmStatus") as Label
		alarm_status.text = NarrativeTextManager.get_option("escape_alarm_active", "ALARM · ACTIVE")
		_open_security_door()
		_send_guards_to_intercept()
	_alarm_press_pending = false


func _open_security_door() -> void:
	if security_door == null:
		return
	security_door.set_meta("waiting_for_alarm", false)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(security_door, "position:y", security_door.position.y + HEIGHT, 0.9)


func _send_guards_to_intercept() -> void:
	var path := _route_slice(GUARD_START_MAP, GUARD_INTERCEPT_MAP)
	for guard_id in ["G1", "G2"]:
		var guard: Node = actors[guard_id]
		guard.call("follow_path", path, 3.0)


func _on_actor_route_blocked(actor_id: String) -> void:
	var actor: Node = actors.get(actor_id)
	if actor == null:
		return
	if actor_id == "T1":
		if not mission_state.retry_t1_alarm_route():
			return
		actor.call("follow_path", _t1_alarm_path(), 2.0)
		return
	if actor_id in ["G1", "G2"]:
		if mission_state.retry_guard_route(actor_id):
			actor.call("follow_path", _remaining_actor_path(actor), 2.5)
			return
	if actor_id in ["T2", "T3"]:
		if mission_state.cabinet_fallen:
			actor.call("stop_at_barrier")
			return
		var retries := int(_worker_route_retries[actor_id])
		var remaining_path := _remaining_actor_path(actor)
		if retries < MAX_WORKER_ROUTE_RETRIES and not remaining_path.is_empty():
			_worker_route_retries[actor_id] = retries + 1
			actor.call("follow_path", remaining_path, 3.2)
			return
	push_warning("Escape actor %s remains blocked; mission progression was not advanced." % actor_id)


func _remaining_actor_path(actor: Node) -> Array[Vector3]:
	var path: Array = actor.get("_path")
	var start_index := int(actor.get("_path_index"))
	var remaining: Array[Vector3] = []
	for index in range(start_index, path.size()):
		var point: Variant = path[index]
		if point is Vector3:
			remaining.append(point)
	return remaining
