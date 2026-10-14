extends Node3D
## Phase 1 spatial review: six rooms on four levels joined by fixed stairs (layout in phase1_layout.gd).
## Reuses the art team's FacilityMaterials, prompt HUD and wall dither, and Elena's animations.
## No circuit, archive extraction, pursuit or containment. The lift is not installed.
const Layout = preload("res://scripts/prototypes/phase1_layout.gd")
const Player = preload("res://scripts/prototypes/phase1_spatial_player.gd")
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

var materials = FacilityMaterials.new()
var player: CharacterBody3D
var hud: CanvasLayer
var fade_groups: Array = []
var body_group: Dictionary = {}
var shortcut_body: StaticBody3D
var shortcut_open: bool = false
var safe_point: Vector3 = Vector3(2.0, 0.2, 1.0)
var current_room: String = ""

func _ready() -> void:
	_build_environment()
	for id in Layout.ROOMS:
		_build_room(id)
	for stair in Layout.STAIRS:
		_build_stairs(stair)
	_build_shortcut_door()
	_build_markers()
	player = Player.new()
	player.position = Layout.ROOMS["entry"]["spawn"]
	add_child(player)
	hud = HudScript.new()
	add_child(hud)
	hud.call("set_objective", "OBJETIVO  /  Accede al registro del archivo")
	hud.call("set_hint", "Prueba espacial: recorre las salas y los niveles. El ascensor no está instalado.")

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().change_scene_to_file(MENU_PATH)

func _physics_process(delta: float) -> void:
	_update_room()
	_update_shortcut_prompt()
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

# --- Shortcut (unlockable only from the cabin side) ---------------------------------------------------

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

func _update_shortcut_prompt() -> void:
	var near := not shortcut_open and unlock_allowed(player.position)
	hud.call("set_prompt", "[E] Desbloquear - Puerta del atajo" if near else "")
	if near and Input.is_action_just_pressed("interact"):
		unlock_shortcut(player.position)

func _build_shortcut_door() -> void:
	shortcut_body = _body("ShortcutDoor", Vector3(2.0, 2.4, 0.2), Vector3(2.0, 4.2, -10.0), materials.get_material("safety_paint"))

# --- Wall dither: walls between the camera and Elena fade out through the shared wall shader -------------

func _update_occluders(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null or fade_groups.is_empty():
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
		var group: Dictionary = fade_groups[index]
		var goal := FADED if hit_groups.has(index) else 0.0
		group["amount"] = move_toward(float(group["amount"]), goal, FADE_SPEED * delta)
		(group["material"] as ShaderMaterial).set_shader_parameter("dither_fade", group["amount"])

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

func _build_room(id: String) -> void:
	var r: Dictionary = Layout.ROOMS[id]
	var x0 := float(r["x0"])
	var x1 := float(r["x1"])
	var z0 := float(r["z0"])
	var z1 := float(r["z1"])
	var y := float(r["y"])
	_body("Floor_" + id, Vector3(x1 - x0, SLAB, z1 - z0), Vector3((x0 + x1) * 0.5, y - SLAB * 0.5, (z0 + z1) * 0.5), materials.get_material(str(r.get("floor", "floor"))))
	var gaps := Layout.openings(id)
	var skipped := Layout.skipped_sides(id)
	var rails: Array = r.get("rail_sides", [])
	var heights: Dictionary = r.get("side_h", {})
	var wall_key := str(r.get("wall", "wall"))
	for side in ["north", "south", "west", "east"]:
		if skipped.has(side):
			continue
		var is_rail := rails.has(side)
		var h := RAIL_HEIGHT if is_rail else float(heights.get(side, Layout.WALL_HEIGHT))
		var thick := RAIL_THICKNESS if is_rail else WALL_THICKNESS
		var material: Material = materials.get_material("steel_light")
		var group := -1
		if not is_rail:
			group = _new_fade_group(wall_key)
			material = (fade_groups[group]["material"] as Material)
		var horizontal := side == "north" or side == "south"
		var fixed := z0 if side == "north" else (z1 if side == "south" else (x0 if side == "west" else x1))
		var run_lo := x0 if horizontal else z0
		var run_hi := x1 if horizontal else z1
		for segment in _segments(run_lo, run_hi, gaps[side]):
			var a := float(segment[0])
			var b := float(segment[1])
			var size := Vector3(b - a, h, thick) if horizontal else Vector3(thick, h, b - a)
			var center := Vector3((a + b) * 0.5, y + h * 0.5, fixed) if horizontal else Vector3(fixed, y + h * 0.5, (a + b) * 0.5)
			var body := _body("Wall_%s_%s" % [id, side], size, center, material)
			if group >= 0:
				body_group[body] = group
	var light := OmniLight3D.new()
	light.position = Vector3((x0 + x1) * 0.5, y + 3.6, (z0 + z1) * 0.5)
	light.light_color = Color(0.78, 0.88, 1.0)
	light.light_energy = 0.7
	light.omni_range = maxf(x1 - x0, z1 - z0) * 0.6 + 4.0
	add_child(light)

func _segments(run_lo: float, run_hi: float, gaps: Array) -> Array:
	var sorted := gaps.duplicate()
	sorted.sort_custom(func(p, q): return float(p[0]) < float(q[0]))
	var out: Array = []
	var cursor := run_lo
	for gap in sorted:
		if float(gap[0]) > cursor + 0.001:
			out.append([cursor, float(gap[0])])
		cursor = maxf(cursor, float(gap[1]))
	if cursor < run_hi - 0.001:
		out.append([cursor, run_hi])
	return out

func _build_stairs(stair: Dictionary) -> void:
	var along_z: bool = stair["axis"] == "z"
	var a0 := float(stair["a0"])
	var a1 := float(stair["a1"])
	var y0 := float(stair["y0"])
	var y1 := float(stair["y1"])
	var c0 := float(stair["c0"])
	var c1 := float(stair["c1"])
	var length := a1 - a0
	var rise := y1 - y0
	var width := c1 - c0
	var lateral := (c0 + c1) * 0.5
	var angle := atan2(rise, length)
	var surface: Material = materials.get_material("grate")
	# Collision ramp: smooth for the character controller. Its mesh is hidden; the steps below are what is seen.
	var ramp_length := sqrt(length * length + rise * rise)
	var ramp_size := Vector3(width, SLAB, ramp_length) if along_z else Vector3(ramp_length, SLAB, width)
	var ramp := _body("Stair_" + str(stair["id"]), ramp_size, Vector3.ZERO, surface)
	if along_z:
		ramp.rotation.x = -angle
	else:
		ramp.rotation.z = angle
	var middle := Vector3(lateral, (y0 + y1) * 0.5, (a0 + a1) * 0.5) if along_z else Vector3((a0 + a1) * 0.5, (y0 + y1) * 0.5, lateral)
	ramp.position = middle - ramp.basis.y * (SLAB * 0.5)
	(ramp.get_child(1) as MeshInstance3D).visible = false
	var count := int(ceil(absf(rise) / STEP_HEIGHT))
	var base_y := minf(y0, y1) - 0.3
	for i in count:
		var t := (float(i) + 0.5) / float(count)
		var run_pos := a0 + t * length
		var top := y0 + t * rise
		var tread := absf(length) / float(count)
		var block := top - base_y
		var size := Vector3(width, block, tread) if along_z else Vector3(tread, block, width)
		var center := Vector3(lateral, base_y + block * 0.5, run_pos) if along_z else Vector3(run_pos, base_y + block * 0.5, lateral)
		_body("Step_%s_%d" % [stair["id"], i], size, center, surface, false)
	# Stairwell side walls: constant height, flush with the room walls on both sides.
	var group := _new_fade_group("bulkhead")
	var wall_bottom := base_y
	var wall_top := maxf(y0, y1) + 2.4
	var wall_h := wall_top - wall_bottom
	for edge in [c0 - 0.1, c1 + 0.1]:
		var size := Vector3(0.2, wall_h, absf(length)) if along_z else Vector3(absf(length), wall_h, 0.2)
		var center := Vector3(edge, wall_bottom + wall_h * 0.5, (a0 + a1) * 0.5) if along_z else Vector3((a0 + a1) * 0.5, wall_bottom + wall_h * 0.5, edge)
		var wall := _body("StairWall_" + str(stair["id"]), size, center, fade_groups[group]["material"] as Material)
		body_group[wall] = group

func _build_markers() -> void:
	for key in Layout.POSITIONS:
		var entry: Dictionary = Layout.POSITIONS[key]
		var label := Label3D.new()
		label.text = str(entry["label"])
		label.position = (entry["at"] as Vector3) + Vector3(0.0, 1.8, 0.0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 36
		label.pixel_size = 0.008
		label.outline_size = 8
		add_child(label)
