extends Node3D
## Phase 1 spatial review: six rooms on four levels joined by fixed stairs (layout in phase1_layout.gd).
## Reuses the art team's FacilityMaterials, prompt HUD and wall dither, and Elena's animations. The rooms are dressed by
## phase1_dressing.gd and the clues and controls are wired to the circuit model by phase1_interactions.gd.
## Review views: F4 top-down, F5 side cut. No archive record, extraction, pursuit or containment. The lift is not installed.
const Layout = preload("res://scripts/prototypes/phase1_layout.gd")
const Player = preload("res://scripts/prototypes/phase1_spatial_player.gd")
const Dressing = preload("res://scripts/prototypes/phase1_dressing.gd")
const Interactions = preload("res://scripts/prototypes/phase1_interactions.gd")
const FacilityMaterials = preload("res://scripts/levels/test_room_art/facility_materials.gd")
const HudScript = preload("res://scripts/ui/prompt_hud.gd")
const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const WALL_THICKNESS := 0.3
const RAIL_HEIGHT := 1.1
const RAIL_THICKNESS := 0.1
const SLAB := 0.25
const STEP_HEIGHT := 0.2
const FADED := 0.8
const FADE_SPEED := 5.0
const SHORTCUT_REACH := 2.5
const SHORTCUT_CENTER := Vector3(2.0, 3.0, -10.0)
## Standing meltwater per room: Vector4(x, z, radius, strength) pairs for the floor shader.
const WET_SPOTS := {
	"entry": [Vector4(6.0, 2.0, 2.2, 0.8), Vector4(2.0, 3.5, 1.4, 0.6)],
	"test_hall": [Vector4(14.0, 6.0, 3.0, 0.8), Vector4(23.0, -7.0, 2.6, 0.7)],
	"pit": [Vector4(18.0, 19.0, 5.0, 1.0), Vector4(22.5, 22.0, 3.0, 0.9)],
	"pump": [Vector4(36.0, -3.0, 2.4, 0.7), Vector4(41.0, 4.0, 2.0, 0.6)],
}

var materials = FacilityMaterials.new()
var dressing = null
var interactions = null
var player: CharacterBody3D
var hud: CanvasLayer
var fade_groups: Array = []
var body_group: Dictionary = {}
var marker_labels: Array = []
var room_lights: Array = []
var shortcut_body: StaticBody3D
var shortcut_open: bool = false
var safe_point: Vector3 = Vector3(2.0, 0.2, 1.0)
var current_room: String = ""
var overview_camera: Camera3D
var side_camera: Camera3D
var view_mode: String = "player"

func _ready() -> void:
	_build_environment()
	for id in Layout.ROOMS:
		_build_room(id)
	for stair in Layout.STAIRS:
		_build_stairs(stair)
	_build_shortcut_door()
	dressing = Dressing.new()
	add_child(dressing)
	dressing.build(materials)
	_build_markers()
	player = Player.new()
	player.position = Layout.ROOMS["entry"]["spawn"]
	add_child(player)
	overview_camera = _make_review_camera(Vector3(22.0, 52.0, 3.0), Vector3(22.0, 0.0, 3.0), Vector3(0.0, 0.0, -1.0))
	side_camera = _make_review_camera(Vector3(22.0, 9.0, 70.0), Vector3(22.0, 2.0, 0.0), Vector3.UP)
	hud = HudScript.new()
	add_child(hud)
	hud.call("set_objective", "OBJETIVO  /  Accede al registro del archivo")
	hud.call("set_hint", "Prueba espacial · F4 vista elevada · F5 corte lateral · H pista")
	interactions = Interactions.new()
	interactions.name = "Interactions"
	add_child(interactions)
	interactions.setup(self)

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _make_review_camera(pos: Vector3, target: Vector3, up: Vector3) -> Camera3D:
	var cam := Camera3D.new()
	cam.fov = 50.0
	add_child(cam)
	cam.global_position = pos
	cam.look_at(target, up)
	return cam

## mode: "player", "overview" (top-down) or "side" (cut from the south). Review modes show every wall faded.
func _set_view(mode: String) -> void:
	view_mode = mode
	if mode == "overview":
		overview_camera.make_current()
	elif mode == "side":
		side_camera.make_current()
	else:
		var player_view = player.get("view")
		if player_view != null:
			(player_view as Camera3D).make_current()

func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo:
		if key.physical_keycode == KEY_F4:
			_set_view("player" if view_mode == "overview" else "overview")
			return
		if key.physical_keycode == KEY_F5:
			_set_view("player" if view_mode == "side" else "side")
			return
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().change_scene_to_file(MENU_PATH)

func _physics_process(delta: float) -> void:
	_update_room()
	_update_occluders(delta)
	if player.position.y < -8.0:
		player.position = safe_point
		player.velocity = Vector3.ZERO

func _update_room() -> void:
	var id := Layout.room_at(player.position)
	if id == "" or id == current_room:
		return
	current_room = id
	safe_point = Layout.ROOMS[id]["spawn"]
	hud.call("set_status", "Zona: " + str(Layout.ROOMS[id]["name"]))
	for entry in marker_labels:
		(entry["label"] as Label3D).visible = entry["room"] == id

## The trip feedback: every room light dips for a moment and recovers. Visual only.
func dip_lights() -> void:
	for light in room_lights:
		var l := light as OmniLight3D
		if not l.has_meta("base_energy"):
			l.set_meta("base_energy", l.light_energy)
		var base: float = float(l.get_meta("base_energy"))
		var tween := create_tween()
		tween.tween_property(l, "light_energy", base * 0.25, 0.12)
		tween.tween_interval(0.25)
		tween.tween_property(l, "light_energy", base, 0.5)

# --- Shortcut (unlockable only from the cabin side; the prompt is raised by the interactions node) -------

func unlock_allowed(from: Vector3) -> bool:
	return from.z < -10.1 and from.x > 0.5 and from.x < 3.5 and absf(from.y - 3.0) < 1.5 and from.distance_to(SHORTCUT_CENTER) <= SHORTCUT_REACH

func unlock_shortcut(from: Vector3) -> bool:
	if shortcut_open or not unlock_allowed(from):
		return false
	shortcut_open = true
	(shortcut_body.get_child(0) as CollisionShape3D).set_deferred("disabled", true)
	shortcut_body.visible = false
	hud.call("show_banner", "Atajo desbloqueado", "La escalera de servicio conecta la cabina con el vestíbulo.")
	return true

func _build_shortcut_door() -> void:
	shortcut_body = _body("ShortcutDoor", Vector3(2.0, 2.4, 0.2), Vector3(2.0, 4.2, -10.0), materials.get_material("safety_paint"))

# --- Wall dither: walls between the camera and Elena fade out through the shared wall shader -------------

func _apply_fade(group: Dictionary, goal: float, delta: float) -> void:
	group["amount"] = move_toward(float(group["amount"]), goal, FADE_SPEED * delta)
	(group["material"] as ShaderMaterial).set_shader_parameter("dither_fade", group["amount"])

func _update_occluders(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null or fade_groups.is_empty():
		return
	if view_mode != "player":
		for group in fade_groups:
			_apply_fade(group, FADED, delta)
		return
	var hit_groups: Array = []
	var excluded: Array[RID] = [player.get_rid()]
	var from := camera.global_position
	var to := player.global_position + Vector3(0.0, 1.0, 0.0)
	var space := get_world_3d().direct_space_state
	for i in 3:
		var query := PhysicsRayQueryParameters3D.create(from, to, 1)
		query.exclude = excluded
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			break
		var collider = hit["collider"]
		if collider is CollisionObject3D:
			excluded.append((collider as CollisionObject3D).get_rid())
		if body_group.has(collider):
			hit_groups.append(body_group[collider])
	for index in fade_groups.size():
		_apply_fade(fade_groups[index], FADED if hit_groups.has(index) else 0.0, delta)

# --- Construction ----------------------------------------------------------------------------------

func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.32, 0.4, 0.48)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var holder := WorldEnvironment.new()
	holder.environment = env
	add_child(holder)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-55.0, 25.0, 0.0)
	fill.light_color = Color(0.6, 0.72, 0.9)
	fill.light_energy = 0.25
	add_child(fill)

func _body(label: String, size: Vector3, center: Vector3, material: Material, collide: bool = true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 0
	if collide:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		shape.shape = box
		body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = material
	body.add_child(mesh)
	add_child(body)
	return body

func _new_fade_group(wall_key: String) -> int:
	var material := materials.get_material(wall_key).duplicate() as ShaderMaterial
	fade_groups.append({"material": material, "amount": 0.0})
	return fade_groups.size() - 1

func _floor_material(id: String, key: String) -> Material:
	var base: Material = materials.get_material(key)
	if key != "floor" or not WET_SPOTS.has(id):
		return base
	var wet := base.duplicate() as ShaderMaterial
	var spots: Array = WET_SPOTS[id]
	wet.set_shader_parameter("wet_spot_a", spots[0])
	wet.set_shader_parameter("wet_spot_b", spots[1])
	return wet

func _build_room(id: String) -> void:
	var r: Dictionary = Layout.ROOMS[id]
	var x0: float = float(r["x0"])
	var x1: float = float(r["x1"])
	var z0: float = float(r["z0"])
	var z1: float = float(r["z1"])
	var y: float = float(r["y"])
	_body("Floor_" + id, Vector3(x1 - x0, SLAB, z1 - z0), Vector3((x0 + x1) * 0.5, y - SLAB * 0.5, (z0 + z1) * 0.5), _floor_material(id, str(r.get("floor", "floor"))))
	var gaps: Dictionary = Layout.openings(id)
	var skipped: Array = Layout.skipped_sides(id)
	var rails: Array = r.get("rail_sides", [])
	var heights: Dictionary = r.get("side_h", {})
	var wall_key: String = str(r.get("wall", "wall"))
	for side: String in ["north", "south", "west", "east"]:
		if skipped.has(side):
			continue
		var is_rail: bool = rails.has(side)
		var h: float = RAIL_HEIGHT if is_rail else float(heights.get(side, Layout.WALL_HEIGHT))
		var thick: float = RAIL_THICKNESS if is_rail else WALL_THICKNESS
		var material: Material = materials.get_material("steel_light")
		var group: int = -1
		if not is_rail:
			group = _new_fade_group(wall_key)
			material = (fade_groups[group]["material"] as Material)
		var horizontal: bool = side == "north" or side == "south"
		var fixed: float = x1
		if side == "north":
			fixed = z0
		elif side == "south":
			fixed = z1
		elif side == "west":
			fixed = x0
		var run_lo: float = x0 if horizontal else z0
		var run_hi: float = x1 if horizontal else z1
		for segment in _segments(run_lo, run_hi, gaps[side]):
			var a: float = float(segment[0])
			var b: float = float(segment[1])
			var size: Vector3 = Vector3(b - a, h, thick) if horizontal else Vector3(thick, h, b - a)
			var center: Vector3 = Vector3((a + b) * 0.5, y + h * 0.5, fixed) if horizontal else Vector3(fixed, y + h * 0.5, (a + b) * 0.5)
			var body := _body("Wall_%s_%s" % [id, side], size, center, material)
			if group >= 0:
				body_group[body] = group
	var light := OmniLight3D.new()
	light.position = Vector3((x0 + x1) * 0.5, y + 3.6, (z0 + z1) * 0.5)
	light.light_color = Color(0.78, 0.88, 1.0)
	light.light_energy = 0.7
	light.omni_range = maxf(x1 - x0, z1 - z0) * 0.5 + 2.0
	add_child(light)
	room_lights.append(light)

func _segments(run_lo: float, run_hi: float, gaps: Array) -> Array:
	var sorted: Array = gaps.duplicate()
	sorted.sort_custom(func(p, q): return float(p[0]) < float(q[0]))
	var out: Array = []
	var cursor: float = run_lo
	for gap in sorted:
		if float(gap[0]) > cursor + 0.001:
			out.append([cursor, float(gap[0])])
		cursor = maxf(cursor, float(gap[1]))
	if cursor < run_hi - 0.001:
		out.append([cursor, run_hi])
	return out

func _build_stairs(stair: Dictionary) -> void:
	var along_z: bool = stair["axis"] == "z"
	var a0: float = float(stair["a0"])
	var a1: float = float(stair["a1"])
	var y0: float = float(stair["y0"])
	var y1: float = float(stair["y1"])
	var c0: float = float(stair["c0"])
	var c1: float = float(stair["c1"])
	var length: float = a1 - a0
	var rise: float = y1 - y0
	var width: float = c1 - c0
	var lateral: float = (c0 + c1) * 0.5
	var angle: float = atan2(rise, length)
	var surface: Material = materials.get_material("grate")
	# Collision ramp: smooth for the character controller. Its mesh is hidden; the steps below are what is seen.
	var ramp_length: float = sqrt(length * length + rise * rise)
	var ramp_size: Vector3 = Vector3(width, SLAB, ramp_length) if along_z else Vector3(ramp_length, SLAB, width)
	var ramp := _body("Stair_" + str(stair["id"]), ramp_size, Vector3.ZERO, surface)
	if along_z:
		ramp.rotation.x = -angle
	else:
		ramp.rotation.z = angle
	var middle: Vector3 = Vector3(lateral, (y0 + y1) * 0.5, (a0 + a1) * 0.5) if along_z else Vector3((a0 + a1) * 0.5, (y0 + y1) * 0.5, lateral)
	ramp.position = middle - ramp.basis.y * (SLAB * 0.5)
	(ramp.get_child(1) as MeshInstance3D).visible = false
	var count: int = int(ceil(absf(rise) / STEP_HEIGHT))
	var base_y: float = minf(y0, y1) - 0.3
	for i in count:
		var t: float = (float(i) + 0.5) / float(count)
		var run_pos: float = a0 + t * length
		var top: float = y0 + t * rise
		var tread: float = absf(length) / float(count)
		var block: float = top - base_y
		var step_size: Vector3 = Vector3(width, block, tread) if along_z else Vector3(tread, block, width)
		var step_center: Vector3 = Vector3(lateral, base_y + block * 0.5, run_pos) if along_z else Vector3(run_pos, base_y + block * 0.5, lateral)
		_body("Step_%s_%d" % [stair["id"], i], step_size, step_center, surface, false)
	# Stairwell side walls: constant height, flush with the room walls on both sides.
	var group: int = _new_fade_group("bulkhead")
	var wall_bottom: float = base_y
	var wall_top: float = maxf(y0, y1) + 2.4
	var wall_h: float = wall_top - wall_bottom
	for edge: float in [c0 - 0.1, c1 + 0.1]:
		var wall_size: Vector3 = Vector3(0.2, wall_h, absf(length)) if along_z else Vector3(absf(length), wall_h, 0.2)
		var wall_center: Vector3 = Vector3(edge, wall_bottom + wall_h * 0.5, (a0 + a1) * 0.5) if along_z else Vector3((a0 + a1) * 0.5, wall_bottom + wall_h * 0.5, edge)
		var wall := _body("StairWall_" + str(stair["id"]), wall_size, wall_center, fade_groups[group]["material"] as Material)
		body_group[wall] = group

## Position signs are shown only for the room the player is in, so they never pile up over the HUD or show through walls.
func _build_markers() -> void:
	for key in Layout.POSITIONS:
		var entry: Dictionary = Layout.POSITIONS[key]
		var at: Vector3 = entry["at"]
		var label := Label3D.new()
		label.text = str(entry["label"])
		label.position = at + Vector3(0.0, 1.8, 0.0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 28
		label.pixel_size = 0.008
		label.outline_size = 8
		label.modulate = Color(0.7, 0.9, 0.95, 0.85)
		label.visible = false
		add_child(label)
		marker_labels.append({"label": label, "room": Layout.room_at(at)})
