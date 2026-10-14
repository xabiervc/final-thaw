extends Node3D
## Art direction for the Elena test room: "Helix test bay B", a flood-control wing evacuated during the thaw.
##
## Visual-only (decision D1): the level scene and its colliders are not modified. This node re-skins the greybox walls,
## hides placeholder meshes and debug labels, and adds architecture, set pieces, signage and the room's light rig.
## The few large set pieces that stand on walkable floor get their own colliders so Elena cannot walk through them;
## they are placed only in dead space (against walls, behind the generator lever), never on the critical path.
##
## Composition, west to east (the camera looks north):
##   B-1 access     lockers, evacuation map, security terminal (amber focal point)
##   B-2 flood hall four deployed flood barriers, sealed frosted flood shutter, pump, meltwater gauge, warming station
##   B-3 generator  the auxiliary generator (main landmark; its stacks and red beacon show over the alcove wall)
##   B-4 airlock    checkpoint gate and the pressure door to the laboratory, lit only once power is restored
## The recurring motif is the meltwater line: a tide stain at 0.55 m on every wall, the gauge that measures it and
## standing water on the floor.

const Materials := preload("res://scripts/levels/test_room_art/facility_materials.gd")
const PowerScript := preload("res://scripts/levels/test_room_art/test_room_power.gd")
const AudioScript := preload("res://scripts/levels/test_room_art/test_room_audio.gd")
const FadeScript := preload("res://scripts/levels/test_room_art/occluder_fade.gd")
## Generator alcove: the floor area hidden from the camera by the alcove wall (x 4.2..8.25, z -8..-4.85).
const ALCOVE_REGION := Rect2(4.2, -8.0, 4.05, 3.15)

const ROOM_X := Vector2(-12.0, 12.0)
const ROOM_Z := Vector2(-8.0, 8.0)
const WALL_H := 3.2
const BACK := -8.0  # interior face of the back wall
const BARRIER_XS := [-6.3, -4.4, -2.5, 1.6]
const DIVIDERS := [-8.0, 3.9, 8.5]
const DOORWAY_HALF := 1.4

## Camera framing for this room: a slightly lower, wider view shows wall faces and depth, and the limits keep Elena
## near the centre of the frame in the end bays (the previous limits pinned her to the screen edge at spawn).
const CAMERA_OFFSET := Vector3(0.0, 9.0, 7.4)
const CAMERA_FOV := 42.0
const CAMERA_LIMIT := Vector2(8.5, 3.0)
const CAMERA_LOOK_AHEAD := 0.35

## Environment: dark room, low cold ambient, light comes from the fixtures.
const AMBIENT_COLOR := Color(0.34, 0.42, 0.52)
const AMBIENT_ENERGY := 0.3
const SUN_COLOR := Color(0.6, 0.7, 0.88)
const SUN_ENERGY := 0.38
const SUN_ROTATION := Vector3(-58.0, 205.0, 0.0)

var mats := Materials.new()
var room: Node3D = null
var power: Node = null
var audio: Node = null
var alcove_fade: Node = null

var _alcove_parts: Array = []  # wall + everything mounted on it, faded while Elena is in the alcove

var _boxes: Dictionary = {}  # "material|shadow" -> Array[Transform3D]
var _cylinders: Dictionary = {}
var _collision: StaticBody3D = null
var _unit_box := BoxMesh.new()
var _unit_cylinder := CylinderMesh.new()


func _ready() -> void:
	name = "TestRoomDressing"
	_unit_cylinder.top_radius = 0.5
	_unit_cylinder.bottom_radius = 0.5
	_unit_cylinder.height = 1.0
	_unit_cylinder.radial_segments = 16
	_unit_cylinder.rings = 1
	room = _find_room(get_parent())
	if room == null:
		push_warning("TestRoomDressing: no room with an `elena` property found")
		return
	_collision = StaticBody3D.new()
	_collision.name = "SetPieceCollision"
	_collision.collision_layer = 1
	_collision.collision_mask = 0
	add_child(_collision)
	_reskin_greybox()
	_build_floor()
	_build_outer_mass()
	_build_back_wall()
	_build_doorways()
	_build_access_bay()
	_build_flood_hall()
	_build_generator_bay()
	_build_airlock()
	_flush()
	_environment()
	_frame_camera()
	power = PowerScript.new()
	power.name = "PowerRig"
	power.set("mats", mats)
	power.set("room", room)
	add_child(power)
	audio = AudioScript.new()
	audio.set("room", room)
	add_child(audio)
	alcove_fade = FadeScript.new()
	alcove_fade.name = "AlcoveWallFade"
	alcove_fade.set("target", room.get("elena"))
	alcove_fade.set("region", ALCOVE_REGION)
	alcove_fade.set("parts", _alcove_parts)
	alcove_fade.set("wall_material", mats.get_material("wall_alcove"))
	add_child(alcove_fade)


func _find_room(host: Node) -> Node3D:
	if host == null:
		return null
	if host.get("elena") != null:
		return host as Node3D
	for child in host.find_children("*", "Node3D", true, false):
		if child.get("elena") != null:
			return child as Node3D
	return null


# --- batching helpers ---------------------------------------------------------------------------------------------

func box(key: String, size: Vector3, center: Vector3, yaw_deg: float = 0.0, shadow: bool = true) -> void:
	var group := "%s|%s" % [key, shadow]
	if not _boxes.has(group):
		_boxes[group] = []
	var basis := Basis(Vector3.UP, deg_to_rad(yaw_deg)) * Basis.from_scale(size)
	(_boxes[group] as Array).append(Transform3D(basis, center))


## axis: "x", "y" or "z" (the cylinder's long axis).
func cylinder(key: String, radius: float, length: float, center: Vector3, axis: String = "y", shadow: bool = true) -> void:
	var group := "%s|%s" % [key, shadow]
	if not _cylinders.has(group):
		_cylinders[group] = []
	var rot := Basis.IDENTITY
	if axis == "x":
		rot = Basis(Vector3.FORWARD, PI * 0.5)
	elif axis == "z":
		rot = Basis(Vector3.RIGHT, PI * 0.5)
	var d := radius * 2.0
	(_cylinders[group] as Array).append(Transform3D(rot * Basis.from_scale(Vector3(d, length, d)), center))


## A straight cylinder between two points (hoses, cables).
func run(key: String, radius: float, a: Vector3, b: Vector3, shadow: bool = false) -> void:
	var group := "%s|%s" % [key, shadow]
	if not _cylinders.has(group):
		_cylinders[group] = []
	var dir := b - a
	var length := dir.length()
	if length < 0.001:
		return
	var y := dir / length
	var x := y.cross(Vector3.UP if absf(y.y) < 0.95 else Vector3.RIGHT).normalized()
	var z := x.cross(y)
	var d := radius * 2.0
	var basis := Basis(x * d, y * length, z * d)
	(_cylinders[group] as Array).append(Transform3D(basis, (a + b) * 0.5))


## An individual (unbatched) box, for parts that must change on their own, e.g. fade with a wall.
func piece(key: String, size: Vector3, center: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = mats.get_material(key)
	mi.position = center
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func solid(size: Vector3, center: Vector3) -> void:
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	cs.position = center
	_collision.add_child(cs)


func _flush() -> void:
	_flush_group(_boxes, _unit_box, "Box")
	_flush_group(_cylinders, _unit_cylinder, "Cyl")


func _flush_group(groups: Dictionary, mesh: Mesh, suffix: String) -> void:
	for group in groups:
		var parts := String(group).split("|")
		var list: Array = groups[group]
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mesh
		mm.instance_count = list.size()
		for i in list.size():
			mm.set_instance_transform(i, list[i])
		var inst := MultiMeshInstance3D.new()
		inst.name = "%s_%s" % [parts[0].capitalize().replace(" ", ""), suffix]
		inst.multimesh = mm
		inst.material_override = mats.get_material(parts[0])
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if parts[1] == "true" else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(inst)


## Diegetic stencil text painted on a surface. facing: "south" (wall facing the camera) or "floor".
func stencil(text: String, pos: Vector3, size: int, facing: String = "south", color: Color = Color(0.78, 0.76, 0.68), yaw_deg: float = 0.0) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font_size = size
	l.pixel_size = 0.004
	l.modulate = color
	l.outline_size = 0
	l.shaded = true
	l.double_sided = false
	l.no_depth_test = false
	l.position = pos
	if facing == "floor":
		l.rotation = Vector3(-PI * 0.5, deg_to_rad(yaw_deg), 0.0)
	else:
		l.rotation.y = deg_to_rad(yaw_deg)
	add_child(l)
	return l


func text(key: String, fallback: String) -> String:
	return NarrativeTextManager.get_option(key, fallback)


# --- greybox --------------------------------------------------------------------------------------------------------

## Re-skins the level's wall boxes with the facility materials (geometry and colliders untouched), caps them, and hides
## the placeholder floor grid, barrier slabs, flat checkpoint beams, recovery-zone plate and debug billboards.
func _reskin_greybox() -> void:
	for child in room.get_children():
		if child is StaticBody3D and child.get_script() == null:
			_reskin_static(child as StaticBody3D)
		elif child is Label3D:
			(child as Label3D).visible = false
		elif child is MeshInstance3D:
			(child as MeshInstance3D).layers = 0  # checkpoint beams: replaced by the airlock gate
		elif child is OmniLight3D:
			(child as OmniLight3D).visible = false  # the greybox lamps: replaced by the fixture rig
		elif child is StaticBody3D:
			for m in child.find_children("*", "MeshInstance3D", true, false):
				(m as MeshInstance3D).layers = 0  # flood barriers: dressed below
		elif child is Area3D:
			for m in child.find_children("*", "MeshInstance3D", true, false):
				(m as MeshInstance3D).layers = 0  # recovery-zone plate: dressed as the warming station
			for l in child.find_children("*", "Label3D", true, false):
				(l as Label3D).visible = false


func _reskin_static(body: StaticBody3D) -> void:
	var mesh_node: MeshInstance3D = null
	for c in body.get_children():
		if c is MeshInstance3D:
			mesh_node = c
	if mesh_node == null or not (mesh_node.mesh is BoxMesh):
		return
	var size := (mesh_node.mesh as BoxMesh).size
	var p := body.position
	if p.y < 0.0:
		mesh_node.layers = 0  # greybox grid floor
		return
	var is_divider := false
	for dx in DIVIDERS:
		if absf(p.x - float(dx)) < 0.05 and absf(p.z) < 7.9:
			is_divider = true
	mesh_node.material_override = mats.get_material("bulkhead" if is_divider else "wall")
	# Dark section cap: walls read as solid cut-away mass from the high camera.
	var top := p.y + size.y * 0.5
	var is_alcove := not is_divider and absf(p.x) < 11.9 and absf(p.z) < 7.9
	if is_alcove:
		mesh_node.material_override = mats.get_material("wall_alcove")
		_alcove_parts.append(piece("cap", Vector3(size.x + 0.04, 0.06, size.z + 0.04), Vector3(p.x, top + 0.03, p.z)))
		return
	box("cap", Vector3(size.x + 0.04, 0.06, size.z + 0.04), Vector3(p.x, top + 0.03, p.z))
	if is_divider or size.y > 3.0:
		box("cap_edge", Vector3(size.x + 0.06, 0.03, 0.05), Vector3(p.x, top - 0.02, p.z + size.z * 0.5 + 0.01), 0.0, false)


func _build_floor() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(ROOM_X.y - ROOM_X.x, ROOM_Z.y - ROOM_Z.x)
	var mi := MeshInstance3D.new()
	mi.name = "FacilityFloor"
	mi.mesh = plane
	mi.position = Vector3(0.0, 0.003, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := mats.get_material("floor") as ShaderMaterial
	m.set_shader_parameter("wet_spot_a", Vector4(-0.45, -6.9, 2.6, 0.9))  # meltwater seeping under the shutter
	m.set_shader_parameter("wet_spot_b", Vector4(-5.3, -5.0, 1.8, 0.6))   # around the pump drain
	mi.material_override = m
	add_child(mi)


## Dark structural mass around the room, so the camera never shows empty void past the outer walls.
func _build_outer_mass() -> void:
	box("cap", Vector3(4.0, WALL_H, 26.0), Vector3(-14.5, WALL_H * 0.5, 0.0), 0.0, false)
	box("cap", Vector3(4.0, WALL_H, 26.0), Vector3(14.5, WALL_H * 0.5, 0.0), 0.0, false)
	box("cap", Vector3(33.0, WALL_H, 4.0), Vector3(0.0, WALL_H * 0.5, -10.5), 0.0, false)
	box("cap", Vector3(33.0, 0.9, 5.0), Vector3(0.0, 0.45, 11.0), 0.0, false)


# --- shared architecture ---------------------------------------------------------------------------------------

func _build_back_wall() -> void:
	var z := BACK
	# Structural pilasters: the flood barriers are anchored into them (and into posts on the front parapet).
	for bx in BARRIER_XS:
		box("steel", Vector3(0.5, 3.5, 0.34), Vector3(bx, 1.75, z + 0.17))
		box("cap", Vector3(0.54, 0.05, 0.38), Vector3(bx, 3.52, z + 0.17), 0.0, false)
		solid(Vector3(0.5, 3.2, 0.34), Vector3(bx, 1.6, z + 0.17))
		box("steel", Vector3(0.44, 1.05, 0.26), Vector3(bx, 0.525, ROOM_Z.y - 0.13))
	# Services run along the whole back wall: cable tray with three cables, a main pipe, and the oxide-red fire main.
	box("steel_light", Vector3(24.0, 0.05, 0.32), Vector3(0.0, 2.72, z + 0.2), 0.0, false)
	for i in 3:
		cylinder("rubber", 0.032, 24.0, Vector3(0.0, 2.78, z + 0.1 + 0.09 * i), "x", false)
	cylinder("pipe", 0.1, 24.0, Vector3(0.0, 3.02, z + 0.16), "x")
	cylinder("pipe_red", 0.07, 16.4, Vector3(0.3, 2.34, z + 0.1), "x", false)
	var bracket_x := -11.0
	while bracket_x < 12.0:
		box("steel", Vector3(0.06, 0.8, 0.3), Vector3(bracket_x, 2.7, z + 0.15), 0.0, false)
		bracket_x += 2.0
	# Wall fixtures. Working fixtures sit on the emergency circuit; "lamp_power" ones wait for the generator.
	_fixture(-10.0, "lamp_cold")
	_fixture(-7.15, "lamp_dead")
	_fixture(-5.35, "lamp_cold")
	_fixture(-3.45, "lamp_flicker")
	_fixture(2.75, "lamp_cold")
	_fixture(7.6, "lamp_power")
	_fixture(10.3, "lamp_power")
	# Bay names, painted large on the back wall so each zone is identifiable from the camera.
	stencil(text("test_room_sign_access", "B-1  ACCESO"), Vector3(-10.1, 2.05, z + 0.03), 72)
	stencil(text("test_room_sign_flood", "B-2  CONTROL DE INUNDACIONES"), Vector3(-5.35, 2.05, z + 0.03), 64)
	stencil(text("test_room_sign_generator", "B-3  GENERADOR"), Vector3(5.6, 3.2, z + 0.03), 56)
	stencil(text("test_room_sign_airlock", "B-4  ESCLUSA"), Vector3(10.3, 2.05, z + 0.03), 72)


func _fixture(x: float, lamp_key: String) -> void:
	box("steel", Vector3(0.95, 0.14, 0.24), Vector3(x, 2.47, BACK + 0.12), 0.0, false)
	box(lamp_key, Vector3(0.82, 0.05, 0.07), Vector3(x, 2.41, BACK + 0.23), 0.0, false)


## Heavy frames at the three bulkhead openings, hazard paint on the jambs, threshold plates on the floor.
func _build_doorways() -> void:
	for dx in DIVIDERS:
		var x := float(dx)
		for side in [-1.0, 1.0]:
			var zj: float = side * (DOORWAY_HALF + 0.1)
			box("steel", Vector3(0.86, 3.3, 0.2), Vector3(x, 1.65, zj))
			box("hazard", Vector3(0.74, 2.6, 0.02), Vector3(x, 1.3, side * (DOORWAY_HALF - 0.005)), 0.0, false)
		# Lintel deep enough to cover the door art's status strip; the rig adds compact status lamps instead.
		box("steel", Vector3(0.86, 0.3, 3.2), Vector3(x, 3.13, 0.0))
		box("cap", Vector3(0.88, 0.03, 3.22), Vector3(x, 3.295, 0.0), 0.0, false)
		box("steel_light", Vector3(0.9, 0.012, 2.8), Vector3(x, 0.008, 0.0), 0.0, false)
	# Bay numbers on the floor at each threshold, read in the direction of travel.
	stencil("B-2", Vector3(-7.0, 0.012, -2.3), 90, "floor")
	stencil("B-3", Vector3(4.9, 0.012, -2.3), 90, "floor")
	stencil("B-4", Vector3(9.5, 0.012, -2.3), 90, "floor")


# --- B-1 access -----------------------------------------------------------------------------------------------------

func _build_access_bay() -> void:
	# Locker bank: one door left hanging open by someone who left in a hurry.
	for i in 5:
		var lx := -11.62 + 0.37 * i
		box("locker", Vector3(0.35, 1.9, 0.45), Vector3(lx, 0.95, BACK + 0.23))
		box("cap", Vector3(0.2, 0.012, 0.01), Vector3(lx, 1.7, BACK + 0.46), 0.0, false)
		box("cap", Vector3(0.2, 0.012, 0.01), Vector3(lx, 1.64, BACK + 0.46), 0.0, false)
	box("locker", Vector3(0.33, 1.84, 0.025), Vector3(-10.98, 0.95, BACK + 0.62), 62.0, false)
	box("cap", Vector3(1.86, 0.04, 0.47), Vector3(-10.88, 1.92, BACK + 0.23), 0.0, false)
	solid(Vector3(1.86, 1.9, 0.45), Vector3(-10.88, 0.95, BACK + 0.23))
	# Fire-hose cabinet beside the bulkhead.
	box("pipe_red", Vector3(0.55, 0.75, 0.16), Vector3(-9.0, 1.3, BACK + 0.08))
	box("screen_dark", Vector3(0.42, 0.5, 0.02), Vector3(-9.0, 1.3, BACK + 0.17), 0.0, false)
	# Evacuation plan on the west wall; the northern route is struck through in red by hand.
	box("steel", Vector3(0.06, 1.1, 1.7), Vector3(ROOM_X.x + 0.03, 1.55, 0.5))
	box("stencil", Vector3(0.02, 0.95, 1.55), Vector3(ROOM_X.x + 0.07, 1.55, 0.5), 0.0, false)
	box("cap", Vector3(0.022, 0.03, 1.1), Vector3(ROOM_X.x + 0.08, 1.75, 0.45), 0.0, false)
	box("cap", Vector3(0.022, 0.6, 0.03), Vector3(ROOM_X.x + 0.08, 1.45, 0.9), 0.0, false)
	box("pipe_red", Vector3(0.024, 0.04, 0.7), Vector3(ROOM_X.x + 0.09, 1.75, 0.3), 35.0, false)
	box("pipe_red", Vector3(0.024, 0.04, 0.7), Vector3(ROOM_X.x + 0.09, 1.75, 0.3), -35.0, false)
	# Bench by the plan; a dropped thermal blanket trails towards the bulkhead door.
	box("steel_light", Vector3(0.4, 0.05, 1.4), Vector3(-11.6, 0.45, -1.4))
	box("steel", Vector3(0.36, 0.42, 0.06), Vector3(-11.6, 0.21, -2.0), 0.0, false)
	box("steel", Vector3(0.36, 0.42, 0.06), Vector3(-11.6, 0.21, -0.8), 0.0, false)
	solid(Vector3(0.4, 0.47, 1.4), Vector3(-11.6, 0.235, -1.4))
	box("blanket", Vector3(0.9, 0.015, 0.6), Vector3(-8.9, 0.01, 1.9), 23.0, false)


# --- B-2 flood-control hall -----------------------------------------------------------------------------------

func _build_flood_hall() -> void:
	# Deployed flood barriers: aluminium stop-log planks with hazard-painted tops, standing in the old water.
	for bx in BARRIER_XS:
		var x := float(bx)
		box("steel_light", Vector3(0.26, 0.47, 16.0), Vector3(x, 0.235, 0.0))
		box("cap", Vector3(0.27, 0.014, 16.0), Vector3(x, 0.17, 0.0), 0.0, false)
		box("cap", Vector3(0.27, 0.014, 16.0), Vector3(x, 0.33, 0.0), 0.0, false)
		box("steel", Vector3(0.3, 0.035, 16.0), Vector3(x, 0.49, 0.0), 0.0, false)
		box("safety_paint", Vector3(0.035, 0.012, 16.0), Vector3(x - 0.12, 0.51, 0.0), 0.0, false)
		box("safety_paint", Vector3(0.035, 0.012, 16.0), Vector3(x + 0.12, 0.51, 0.0), 0.0, false)
		for pz in [-5.4, -2.0, 2.0, 5.4]:
			box("hazard", Vector3(0.4, 0.6, 0.14), Vector3(x, 0.3, float(pz)))
	# Sealed flood shutter in the back wall: frosted slats, hazard jambs, meltwater seeping underneath.
	var sx := -0.45
	box("wall_frost", Vector3(3.3, 2.78, 0.1), Vector3(sx, 1.39, BACK + 0.05))
	for i in 11:
		box("cap", Vector3(3.3, 0.02, 0.02), Vector3(sx, 0.2 + 0.25 * i, BACK + 0.11), 0.0, false)
	box("steel", Vector3(3.7, 0.36, 0.34), Vector3(sx, 2.96, BACK + 0.17))
	box("hazard", Vector3(0.14, 2.8, 0.2), Vector3(sx - 1.72, 1.4, BACK + 0.1))
	box("hazard", Vector3(0.14, 2.8, 0.2), Vector3(sx + 1.72, 1.4, BACK + 0.1))
	stencil(text("test_room_sign_shutter", "COMPUERTA 2 — SELLADA"), Vector3(sx, 3.0, BACK + 0.35), 40, "south", Color(0.9, 0.86, 0.72))
	# Portable pump and its hose, laid out to the floor drain: the last attempt to keep the water out.
	var px := -5.35
	box("machine", Vector3(0.95, 0.62, 0.6), Vector3(px, 0.31, BACK + 0.62))
	box("cap", Vector3(0.7, 0.08, 0.45), Vector3(px, 0.66, BACK + 0.62), 0.0, false)
	cylinder("pipe", 0.12, 0.5, Vector3(px - 0.25, 0.75, BACK + 0.62), "y", false)
	solid(Vector3(0.95, 0.62, 0.6), Vector3(px, 0.31, BACK + 0.62))
	run("rubber", 0.055, Vector3(px + 0.3, 0.12, BACK + 0.95), Vector3(px + 0.45, 0.055, BACK + 1.7))
	run("rubber", 0.055, Vector3(px + 0.45, 0.055, BACK + 1.7), Vector3(px + 0.05, 0.055, BACK + 2.4))
	run("rubber", 0.055, Vector3(px + 0.05, 0.055, BACK + 2.4), Vector3(px + 0.2, 0.055, BACK + 3.0))
	box("cap", Vector3(0.7, 0.012, 0.7), Vector3(px + 0.2, 0.006, BACK + 3.25), 0.0, false)
	box("grate", Vector3(0.6, 0.016, 0.6), Vector3(px + 0.2, 0.008, BACK + 3.25), 0.0, false)
	# Meltwater gauge: a graduated board that measures the line stained on every wall.
	var gx := -3.45
	box("stencil", Vector3(0.24, 2.5, 0.03), Vector3(gx, 1.35, BACK + 0.02), 0.0, false)
	for i in 11:
		var h := 0.1 + 0.25 * i
		box("cap", Vector3(0.14 if i % 2 == 1 else 0.22, 0.02, 0.01), Vector3(gx - 0.02, h, BACK + 0.04), 0.0, false)
	for m in [1, 2]:
		stencil("%d m" % m, Vector3(gx + 0.25, 0.1 + 1.0 * m, BACK + 0.04), 32)
	box("pipe_red", Vector3(0.5, 0.035, 0.012), Vector3(gx, 0.55, BACK + 0.045), 0.0, false)
	stencil(text("test_room_gauge_mark", "MÁX. 14/03"), Vector3(gx + 0.55, 0.58, BACK + 0.04), 28, "south", Color(0.85, 0.25, 0.2))
	# Breaker panel, tripped: one red tell-tale left on.
	box("steel", Vector3(0.8, 1.1, 0.2), Vector3(-7.15, 1.45, BACK + 0.1))
	box("beacon_red", Vector3(0.05, 0.05, 0.02), Vector3(-6.92, 1.86, BACK + 0.21), 0.0, false)
	box("cap", Vector3(0.6, 0.6, 0.012), Vector3(-7.15, 1.35, BACK + 0.205), 0.0, false)
	# Warming station: heated grating with an overhead radiant heater (the recovery zone at x = -0.4).
	var wx := -0.4
	box("grate_warm", Vector3(1.9, 0.03, 2.9), Vector3(wx, 0.015, 0.0), 0.0, false)
	box("steel", Vector3(2.0, 0.04, 0.06), Vector3(wx, 0.02, -1.48), 0.0, false)
	box("steel", Vector3(2.0, 0.04, 0.06), Vector3(wx, 0.02, 1.48), 0.0, false)
	box("heater", Vector3(1.7, 0.012, 0.03), Vector3(wx, 0.04, -1.45), 0.0, false)
	box("heater", Vector3(1.7, 0.012, 0.03), Vector3(wx, 0.04, 1.45), 0.0, false)
	cylinder("steel", 0.06, 2.55, Vector3(wx - 1.1, 1.275, -1.6))
	solid(Vector3(0.14, 2.5, 0.14), Vector3(wx - 1.1, 1.25, -1.6))
	run("steel", 0.04, Vector3(wx - 1.1, 2.5, -1.6), Vector3(wx, 2.5, -0.2), true)
	box("steel", Vector3(0.75, 0.16, 0.55), Vector3(wx, 2.42, 0.0))
	box("heater", Vector3(0.62, 0.02, 0.42), Vector3(wx, 2.33, 0.0), 0.0, false)
	stencil(text("test_room_sign_warming", "PUNTO DE CALOR"), Vector3(wx, 0.04, 1.75), 40, "floor", Color(0.95, 0.62, 0.35))


# --- B-3 generator --------------------------------------------------------------------------------------------

func _build_generator_bay() -> void:
	# The auxiliary generator: the room's main landmark. Its stacks and beacon rise above the alcove wall.
	var gx := 5.55
	var gz := BACK + 0.45
	box("machine", Vector3(2.5, 1.9, 0.85), Vector3(gx, 0.95, gz))
	box("machine", Vector3(2.1, 0.5, 0.7), Vector3(gx, 2.15, gz - 0.05))
	box("cap", Vector3(2.54, 0.06, 0.89), Vector3(gx, 1.92, gz), 0.0, false)
	for i in 4:
		box("gen_vent", Vector3(0.42, 0.9, 0.02), Vector3(gx - 0.84 + 0.56 * i, 1.0, gz + 0.43), 0.0, false)
		for s in 5:
			box("cap", Vector3(0.42, 0.025, 0.012), Vector3(gx - 0.84 + 0.56 * i, 0.65 + 0.17 * s, gz + 0.445), 0.0, false)
	solid(Vector3(2.5, 2.4, 0.85), Vector3(gx, 1.2, gz))
	for sx in [gx - 0.8, gx + 0.75]:
		cylinder("pipe", 0.16, 2.6, Vector3(sx, 3.6, gz - 0.15))
		cylinder("cap", 0.2, 0.14, Vector3(sx, 4.93, gz - 0.15))
		cylinder("steel", 0.19, 0.08, Vector3(sx, 3.25, gz - 0.15), "y", false)
	cylinder("beacon_red", 0.09, 0.16, Vector3(gx, 2.5, gz - 0.05), "y", false)
	box("status_power", Vector3(0.3, 0.06, 0.02), Vector3(gx + 0.85, 1.75, gz + 0.435), 0.0, false)
	box("hazard", Vector3(2.9, 0.008, 0.14), Vector3(gx, 0.006, gz + 0.55), 0.0, false)
	run("rubber", 0.05, Vector3(gx + 1.2, 1.9, BACK + 0.12), Vector3(gx + 1.2, 2.72, BACK + 0.12), false)
	stencil("GEN-02", Vector3(gx - 0.3, 1.62, gz + 0.44), 64, "south", Color(0.82, 0.8, 0.7))
	# Alcove wall, south face: warning plate pointing at the generator behind it.
	# Everything on this wall fades with it while Elena is inside the alcove.
	_alcove_parts.append(piece("hazard", Vector3(2.4, 0.3, 0.02), Vector3(5.9, 0.15, -4.34)))
	_alcove_parts.append(stencil("GEN-02", Vector3(5.6, 1.55, -4.33), 110, "south", Color(0.8, 0.78, 0.68)))
	_alcove_parts.append(stencil(text("test_room_sign_gen_warning", "GENERADOR AUXILIAR — ACCESO POR EL ESTE  →"), Vector3(5.9, 1.05, -4.33), 30))
	_alcove_parts.append(piece("steel", Vector3(0.95, 0.14, 0.24), Vector3(5.9, 2.62, -4.23)))
	_alcove_parts.append(piece("lamp_power", Vector3(0.82, 0.05, 0.07), Vector3(5.9, 2.56, -4.12)))
	# Fuel drums and a toppled one by the abandoned pack.
	for d in [Vector3(4.55, 0.44, 6.95), Vector3(5.2, 0.44, 7.35)]:
		cylinder("pipe_red", 0.29, 0.88, d)
		cylinder("cap", 0.3, 0.03, d + Vector3(0.0, 0.3, 0.0), "y", false)
		solid(Vector3(0.58, 0.88, 0.58), d)
	cylinder("pipe_red", 0.29, 0.88, Vector3(6.6, 0.29, 6.6), "x")
	solid(Vector3(0.88, 0.58, 0.58), Vector3(6.6, 0.29, 6.6))


# --- B-4 airlock --------------------------------------------------------------------------------------------------

func _build_airlock() -> void:
	# Checkpoint gate at x = 11 (the exit trigger is at x = 10): posts, lintel and status strips that turn green on power.
	var ax := 11.0
	for side in [-1.0, 1.0]:
		box("steel", Vector3(0.32, 2.9, 0.32), Vector3(ax, 1.45, side * 1.45))
		box("status_power", Vector3(0.06, 2.3, 0.05), Vector3(ax, 1.4, side * 1.27), 0.0, false)
		solid(Vector3(0.32, 2.9, 0.32), Vector3(ax, 1.45, side * 1.45))
	box("steel", Vector3(0.32, 0.34, 3.22), Vector3(ax, 3.07, 0.0))
	box("hazard", Vector3(0.3, 0.01, 2.6), Vector3(ax, 0.008, 0.0), 0.0, false)
	# Exit chevrons on the floor, unlit paint until the generator runs.
	for i in 4:
		var cx := 9.2 + 0.65 * i
		box("chevron", Vector3(0.5, 0.012, 0.09), Vector3(cx, 0.01, -0.16), -40.0, false)
		box("chevron", Vector3(0.5, 0.012, 0.09), Vector3(cx, 0.01, 0.16), 40.0, false)
	# Pressure door to the laboratory in the east wall.
	var ex := ROOM_X.y
	box("steel", Vector3(0.3, 3.1, 3.3), Vector3(ex - 0.12, 1.55, 0.0))
	box("steel_light", Vector3(0.08, 2.6, 2.5), Vector3(ex - 0.3, 1.3, 0.0))
	box("cap", Vector3(0.09, 2.6, 0.03), Vector3(ex - 0.3, 1.3, 0.0), 0.0, false)
	box("hazard", Vector3(0.1, 0.3, 2.5), Vector3(ex - 0.3, 0.15, 0.0), 0.0, false)
	box("status_power", Vector3(0.05, 0.08, 1.2), Vector3(ex - 0.28, 2.85, 0.0), 0.0, false)
	# Airlock control panel on the back wall.
	box("steel", Vector3(0.9, 1.2, 0.24), Vector3(10.3, 1.3, BACK + 0.12))
	box("status_power", Vector3(0.6, 0.35, 0.02), Vector3(10.3, 1.5, BACK + 0.25), 0.0, false)
	stencil(text("test_room_sign_lab", "LABORATORIO  →"), Vector3(10.3, 0.75, BACK + 0.25), 36)


# --- environment and camera -------------------------------------------------------------------------------------

func _environment() -> void:
	for node in room.find_children("*", "WorldEnvironment", true, false):
		var env := (node as WorldEnvironment).environment
		if env == null:
			continue
		env.background_color = Color(0.012, 0.016, 0.022)
		env.ambient_light_color = AMBIENT_COLOR
		env.ambient_light_energy = AMBIENT_ENERGY
		env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		env.tonemap_exposure = 1.05
		env.fog_enabled = false
		env.glow_enabled = true
		env.glow_intensity = 0.55
		env.glow_strength = 1.0
		env.glow_bloom = 0.0
		env.glow_hdr_threshold = 1.2
		env.adjustment_enabled = true
		env.adjustment_contrast = 1.1
		env.adjustment_saturation = 0.95
	for node in room.find_children("*", "DirectionalLight3D", true, false):
		var sun := node as DirectionalLight3D
		sun.light_color = SUN_COLOR
		sun.light_energy = SUN_ENERGY
		sun.rotation_degrees = SUN_ROTATION
		sun.shadow_enabled = true
		sun.shadow_blur = 1.5
		sun.directional_shadow_max_distance = 30.0


func _frame_camera() -> void:
	for node in room.find_children("*", "Camera3D", true, false):
		var cam := node as Camera3D
		if cam.get("offset") == null:
			continue
		cam.set("offset", CAMERA_OFFSET)
		cam.set("limit_min", -CAMERA_LIMIT)
		cam.set("limit_max", CAMERA_LIMIT)
		cam.set("look_ahead", CAMERA_LOOK_AHEAD)
		cam.fov = CAMERA_FOV
		cam.rotation = Vector3(-atan2(CAMERA_OFFSET.y, CAMERA_OFFSET.z), 0.0, 0.0)
		if cam.has_method("snap"):
			cam.call("snap")
