extends Node3D
## Standalone, playable greybox for the owner-approved dry-conduit escape.
## Run with: godot --path . res://scenes/prototypes/escape_conduit_labyrinth.tscn
## This is a review prototype; it is not yet wired into the canonical mission transition.
const PlayerScript := preload("res://scripts/prototypes/phase1_spatial_player.gd")
const B := preload("res://scripts/components/build_util.gd")

const WIDTH := 3.2
const HEIGHT := 3.6
const SLAB := 0.30
const WALL := 0.25
const MAIN_LIGHT := Color(1.0, 0.78, 0.38)
const DEAD_LIGHT := Color(0.32, 0.39, 0.48)

var player
var hud: Label
var complete := false
var elapsed := 0.0
var _materials: Dictionary = {}

func _ready() -> void:
	_build_environment()
	_build_geometry()
	_build_player()
	_build_hud()
	_build_forest_trigger()
	print("[escape_labyrinth] greybox loaded; main route ~132 m; stamina lock active")

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if get_tree() != null:
		get_tree().paused = false

func _process(delta: float) -> void:
	if player == null:
		return
	elapsed += delta
	# Keep movement camera-relative while the first-person camera is active.
	player.set("movement_basis", Basis(Vector3.UP, float(player.get("orbit_yaw"))))
	if not complete:
		# Running, jumping and vault practice are intentionally not gated by fatigue here.
		call_deferred("_restore_stamina")

func _physics_process(_delta: float) -> void:
	if player != null and not complete:
		call_deferred("_restore_stamina")

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

func _segment(a: Vector3, b: Vector3, width: float = WIDTH, height: float = HEIGHT, lit: bool = true, label: String = "Conduit") -> void:
	var delta := b - a
	var center := (a + b) * 0.5
	var length := delta.length()
	var color := Color(0.31, 0.35, 0.38)
	var floor_color := Color(0.23, 0.27, 0.30)
	if absf(delta.x) > absf(delta.z):
		_box(label + "_Floor", Vector3(length, SLAB, width), Vector3(center.x, center.y - SLAB * 0.5, center.z), floor_color)
		_box(label + "_Ceiling", Vector3(length, SLAB, width), Vector3(center.x, center.y + height + SLAB * 0.5, center.z), color)
		for side in [-1.0, 1.0]:
			_box(label + "_Wall", Vector3(length, height, WALL), Vector3(center.x, center.y + height * 0.5, center.z + side * (width * 0.5)), color)
	else:
		_box(label + "_Floor", Vector3(width, SLAB, length), Vector3(center.x, center.y - SLAB * 0.5, center.z), floor_color)
		_box(label + "_Ceiling", Vector3(width, SLAB, length), Vector3(center.x, center.y + height + SLAB * 0.5, center.z), color)
		for side in [-1.0, 1.0]:
			_box(label + "_Wall", Vector3(WALL, height, length), Vector3(center.x + side * (width * 0.5), center.y + height * 0.5, center.z), color)
	if lit:
		var count := maxi(1, int(ceil(length / 7.0)))
		for i in count:
			var t := (float(i) + 0.5) / float(count)
			var lp := a.lerp(b, t) + Vector3(0.0, height - 0.22, 0.0)
			_add_light(label + "_EgressLight", lp, MAIN_LIGHT, 1.65, 8.0)
	else:
		_add_light(label + "_DeadEndLight", center + Vector3(0.0, height - 0.3, 0.0), DEAD_LIGHT, 0.22, 4.5)

func _ramp(a: Vector3, b: Vector3, width: float = WIDTH, height: float = HEIGHT) -> void:
	var run := absf(b.z - a.z)
	var rise := b.y - a.y
	var length := Vector2(run, rise).length()
	var angle := atan2(rise, run)
	var center := (a + b) * 0.5
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(width, SLAB, length)
	var floor_body := StaticBody3D.new()
	floor_body.name = "ESC_SLOPE_Floor"
	floor_body.position = Vector3(center.x, center.y - SLAB * 0.5, center.z)
	floor_body.rotation.x = angle
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = floor_mesh.size
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	var floor_visual := MeshInstance3D.new()
	floor_visual.mesh = floor_mesh
	floor_visual.material_override = _mat("ramp_floor", Color(0.23, 0.27, 0.30))
	floor_body.add_child(floor_visual)
	add_child(floor_body)
	for side in [-1.0, 1.0]:
		var wall_mesh := BoxMesh.new()
		wall_mesh.size = Vector3(WALL, height, length)
		var wall_body := StaticBody3D.new()
		wall_body.name = "ESC_SLOPE_Wall"
		wall_body.position = Vector3(center.x + side * (width * 0.5), center.y + height * 0.5, center.z)
		wall_body.rotation.x = angle
		wall_body.collision_layer = 1
		wall_body.collision_mask = 0
		var wall_shape := CollisionShape3D.new()
		var wall_box := BoxShape3D.new()
		wall_box.size = wall_mesh.size
		wall_shape.shape = wall_box
		wall_body.add_child(wall_shape)
		var wall_visual := MeshInstance3D.new()
		wall_visual.mesh = wall_mesh
		wall_visual.material_override = _mat("ramp_wall", Color(0.31, 0.35, 0.38))
		wall_body.add_child(wall_visual)
		add_child(wall_body)
	for i in 3:
		_add_light("ESC_Slope_EgressLight", a.lerp(b, (float(i) + 0.5) / 3.0) + Vector3(0.0, height - 0.25, 0.0), MAIN_LIGHT, 1.8, 9.0)

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

func _build_geometry() -> void:
	# Start at the decision fork. North is forward; the right-hand branch is the personnel story area.
	_segment(Vector3(0, 0, 0), Vector3(0, 0, -18), WIDTH, HEIGHT, true, "ESC_E01")
	_segment(Vector3(0, 0, -18), Vector3(-14, 0, -18), WIDTH, HEIGHT, true, "ESC_E02_LEFT")
	_segment(Vector3(-14, 0, -18), Vector3(-14, 0, -32), WIDTH, HEIGHT, true, "ESC_E03_RIGHT")
	_segment(Vector3(-14, 0, -32), Vector3(-28, 0, -32), WIDTH, HEIGHT, true, "ESC_E04_LEFT")
	_segment(Vector3(-28, 0, -32), Vector3(-28, 0, -46), WIDTH, HEIGHT, true, "ESC_E05_RIGHT")
	_segment(Vector3(-28, 0, -46), Vector3(-12, 0, -46), WIDTH, HEIGHT, true, "ESC_E06_RIGHT")
	_segment(Vector3(-12, 0, -46), Vector3(-12, 0, -62), WIDTH, HEIGHT, true, "ESC_E07_LEFT")
	_ramp(Vector3(-12, 0, -62), Vector3(-12, 3.5, -82))
	_segment(Vector3(-12, 3.5, -82), Vector3(-12, 3.5, -88), 3.2, 3.6, true, "ESC_HATCH_APPROACH")
	# Side routes: dimmer fixtures and a clear, recoverable terminal wall.
	_segment(Vector3(0, 0, -18), Vector3(10, 0, -18), WIDTH, HEIGHT, false, "ESC_D01")
	_segment(Vector3(-14, 0, -32), Vector3(-22, 0, -32), WIDTH, HEIGHT, false, "ESC_D02")
	_segment(Vector3(-28, 0, -46), Vector3(-38, 0, -46), WIDTH, HEIGHT, false, "ESC_D03")
	# Real end caps keep the optional branches recoverable instead of letting the player walk off the floor.
	_box("ESC_D01_EndCap", Vector3(WALL, HEIGHT, WIDTH), Vector3(10.0, HEIGHT * 0.5, -18.0), Color(0.31, 0.35, 0.38))
	_box("ESC_D02_EndCap", Vector3(WALL, HEIGHT, WIDTH), Vector3(-22.0, HEIGHT * 0.5, -32.0), Color(0.31, 0.35, 0.38))
	_box("ESC_D03_EndCap", Vector3(WALL, HEIGHT, WIDTH), Vector3(-38.0, HEIGHT * 0.5, -46.0), Color(0.31, 0.35, 0.38))
	# Personnel branch at the original fork, intentionally distinct from the escape conduit.
	_segment(Vector3(0, 0, 0), Vector3(12, 0, 0), WIDTH, HEIGHT, true, "ESC_PERSONNEL_BRANCH")
	_box("Personnel_Room_Floor", Vector3(10, SLAB, 8), Vector3(17, -SLAB * 0.5, 0), Color(0.23, 0.27, 0.30))
	_box("Personnel_Room_Ceiling", Vector3(10, SLAB, 8), Vector3(17, HEIGHT + SLAB * 0.5, 0), Color(0.31, 0.35, 0.38))
	_box("Personnel_Room_Wall", Vector3(0.25, HEIGHT, 8), Vector3(22, HEIGHT * 0.5, 0), Color(0.31, 0.35, 0.38))
	_box("Personnel_Room_SideWall", Vector3(10, HEIGHT, 0.25), Vector3(17, HEIGHT * 0.5, -4), Color(0.31, 0.35, 0.38))
	_box("Personnel_Room_SideWall", Vector3(10, HEIGHT, 0.25), Vector3(17, HEIGHT * 0.5, 4), Color(0.31, 0.35, 0.38))
	_label("PERSONNEL AREA / ELENA DISCOVERY", Vector3(17, 2.3, -2.0), Color(0.77, 0.68, 1.0), 28)
	_label("DEAD END — RETURN TO THE FORK", Vector3(9.0, 2.3, -16.0), Color(0.65, 0.69, 0.75), 24)
	_label("DARKER BRANCH — NO EGRESS", Vector3(-20, 2.3, -30), Color(0.65, 0.69, 0.75), 24)
	_label("DARKER BRANCH — NO EGRESS", Vector3(-37, 2.3, -44), Color(0.65, 0.69, 0.75), 24)
	# Traversal beat O1: waist-low pipe rack spanning the conduit. Jump over it.
	_box("O1_Jumpable_Pipe_Rack", Vector3(WIDTH - 0.15, 0.55, 0.65), Vector3(-28, 0.275, -39), Color(0.54, 0.31, 0.14))
	_label("JUMP / VAULT", Vector3(-28, 2.3, -39), Color(1.0, 0.78, 0.38), 25)
	# Traversal beat O2: the beam leaves 1.32 m clearance, requiring crouch.
	_box("O2_Low_Service_Beam", Vector3(WIDTH - 0.15, 0.25, 0.3), Vector3(-12, 1.445, -54), Color(0.54, 0.31, 0.14))
	_label("CROUCH UNDER BEAM", Vector3(-12, 2.3, -54), Color(1.0, 0.78, 0.38), 25)
	# Final approach, maintenance hatch, road and forest.
	_box("ESC_HATCH_FRAME", Vector3(3.4, 2.5, 0.25), Vector3(-12, 4.75, -88), Color(0.24, 0.29, 0.32))
	_box("ESC_SECONDARY_ROAD", Vector3(14, SLAB, 5), Vector3(-5, 3.5 - SLAB * 0.5, -91), Color(0.19, 0.22, 0.24))
	for i in 12:
		var x := -13.0 + float(i % 6) * 3.0
		var z := -96.0 - float(i / 6) * 5.0
		var trunk := _box("Forest_Tree_Trunk", Vector3(0.35, 2.0, 0.35), Vector3(x, 4.5, z), Color(0.20, 0.15, 0.10))
		var crown := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 1.5
		mesh.height = 3.0
		crown.mesh = mesh
		crown.position = Vector3(x, 6.0, z)
		crown.material_override = _mat("forest_crown", Color(0.12, 0.28, 0.17))
		add_child(crown)
	_label("SECONDARY ROAD", Vector3(-5, 5.3, -91), Color(0.88, 0.9, 0.91), 34)
	_label("FOREST HIDEOUT — END OF PHASE", Vector3(-5, 5.3, -101), Color(0.76, 0.9, 0.76), 30)

func _build_player() -> void:
	player = PlayerScript.new()
	player.name = "Elena_EscapePrototype"
	player.position = Vector3(0.0, 0.05, 2.0)
	add_child(player)
	player.set("orbit_yaw", 0.0)
	player.set("orbit_pitch", 0.0)
	player.set("movement_basis", Basis.IDENTITY)
	player.set("run_drain", 0.0)
	player.set("mantle_cost", 0.0)
	await get_tree().process_frame
	if player.get("arm") != null:
		player.arm.spring_length = 0.05
		player.arm.position.x = 0.0
	if player.get("pivot") != null:
		player.pivot.position.y = 1.58
	if player.get("view") != null:
		player.view.fov = 78.0
	player.set("camera_mode", "explore")
	if player.has_signal("jumped"):
		player.jumped.connect(func(): call_deferred("_restore_stamina"))

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "EscapePrototypeHUD"
	add_child(layer)
	hud = Label.new()
	hud.name = "Instructions"
	hud.position = Vector2(24, 22)
	hud.size = Vector2(1100, 120)
	hud.add_theme_font_size_override("font_size", 18)
	hud.add_theme_color_override("font_color", Color(0.93, 0.95, 0.96))
	hud.text = "ESCAPE PROTOTYPE  |  WASD: move  ·  Mouse: look  ·  Shift: sprint  ·  Space: jump  ·  Ctrl: crouch\nFollow the brighter, continuous lights. Darker side branches are recoverable dead ends. Reach the forest."
	layer.add_child(hud)

func _build_forest_trigger() -> void:
	var area := Area3D.new()
	area.name = "ESC_FOREST_HIDEOUT_TRIGGER"
	area.position = Vector3(-5.0, 4.0, -101.0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(12.0, 5.0, 12.0)
	shape.shape = box
	area.add_child(shape)
	area.body_entered.connect(_on_forest_entered)
	add_child(area)

func _on_forest_entered(body: Node3D) -> void:
	if complete or body != player:
		return
	complete = true
	player.velocity = Vector3.ZERO
	player.set("input_enabled", false)
	hud.text = "ESCAPE COMPLETE\nElena reaches the forest and hides. The pursuers pass the road and search in the wrong direction."
	print("[escape_labyrinth] FOREST_HIDEOUT reached after %.1f s" % elapsed)

func _restore_stamina() -> void:
	if player == null or not is_instance_valid(player) or complete:
		return
	if player.get("condition") != null:
		player.condition.stamina = 100.0
	player.set("stamina", 100.0)
