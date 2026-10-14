extends Node3D
## Set dressing for the Phase 1 room complex, in the style of the test room dressing: batched boxes and cylinders
## (one MultiMesh per material), a few diegetic stencils and a handful of lights. Visual only, except a few set pieces
## in dead space (against walls, away from stairs and doorways) that get colliders.
## Dynamic parts (Column rings, indicator strips, archive screen) are kept for the circuit hook-up in a later block.

const COLD_WHITE := Color(0.78, 0.88, 1.0)
const ASTER_CYAN := Color(0.35, 0.95, 0.9)
const WARNING_RED := Color(1.0, 0.16, 0.08)
const SAFE_GREEN := Color(0.35, 1.0, 0.3)
const HEATER_WARM := Color(1.0, 0.55, 0.25)
const PAINT := Color(0.78, 0.76, 0.68)

var mats = null
var column_rings: Array = []
var indicators: Dictionary = {}
var archive_screen: MeshInstance3D = null
## Plan footprints (Rect2 in x/z) of every collider added by the dressing, for the layout tests.
var solids: Array = []

var _boxes: Dictionary = {}
var _cylinders: Dictionary = {}
var _collision: StaticBody3D = null
var _unit_box := BoxMesh.new()
var _unit_cylinder := CylinderMesh.new()


func build(materials) -> void:
	mats = materials
	name = "Phase1Dressing"
	_unit_cylinder.top_radius = 0.5
	_unit_cylinder.bottom_radius = 0.5
	_unit_cylinder.height = 1.0
	_unit_cylinder.radial_segments = 16
	_unit_cylinder.rings = 1
	_collision = StaticBody3D.new()
	_collision.name = "SetPieceCollision"
	_collision.collision_layer = 1
	_collision.collision_mask = 0
	add_child(_collision)
	_build_entry()
	_build_hall()
	_build_pit()
	_build_pump()
	_build_catwalk()
	_build_cabin()
	_flush()


# --- batching helpers (same technique as the test room dressing) --------------------------------------------

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


func solid(size: Vector3, center: Vector3) -> void:
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	cs.position = center
	_collision.add_child(cs)
	solids.append(Rect2(center.x - size.x * 0.5, center.z - size.z * 0.5, size.x, size.z))


## An emissive box kept as its own node so its energy can change with the circuit state.
func glow_box(color: Color, energy: float, size: Vector3, center: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _emissive(color, energy)
	mi.position = center
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func glow_ring(color: Color, energy: float, radius: float, height: float, center: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh.rings = 1
	mi.mesh = mesh
	mi.material_override = _emissive(color, energy)
	mi.position = center
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func _emissive(color: Color, energy: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.05, 0.05, 0.05)
	m.roughness = 0.4
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	return m


func _light(pos: Vector3, color: Color, energy: float, light_range: float) -> void:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = light_range
	add_child(l)


## Diegetic stencil text painted on a surface. facing: "south" (a vertical surface, rotated by yaw_deg) or "floor".
## Yaw: 0 faces +z, 180 faces -z, 90 faces +x, -90 faces -x.
func stencil(label_text: String, pos: Vector3, size: int, facing: String = "south", color: Color = PAINT, yaw_deg: float = 0.0) -> Label3D:
	var l := Label3D.new()
	l.text = label_text
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


# --- entry vestibule (0 m) --------------------------------------------------------------------------------------

func _build_entry() -> void:
	# Locker bank on the west wall.
	for i in 5:
		box("locker", Vector3(0.45, 1.9, 0.35), Vector3(0.3, 0.95, 0.2 + 0.37 * float(i)))
	box("cap", Vector3(0.47, 0.04, 1.83), Vector3(0.3, 1.92, 0.94), 0.0, false)
	solid(Vector3(0.45, 1.9, 1.83), Vector3(0.3, 0.95, 0.94))
	# Evacuation plan on the south wall.
	box("steel", Vector3(1.7, 1.1, 0.06), Vector3(5.0, 1.55, 4.82))
	box("stencil", Vector3(1.55, 0.95, 0.02), Vector3(5.0, 1.55, 4.78), 0.0, false)
	box("cap", Vector3(1.1, 0.03, 0.012), Vector3(5.0, 1.75, 4.77), 0.0, false)
	stencil("PLAN DE EVACUACIÓN", Vector3(5.0, 2.3, 4.78), 40, "south", PAINT, 180.0)
	# Bench and a dropped thermal blanket.
	box("steel_light", Vector3(1.4, 0.05, 0.4), Vector3(3.0, 0.45, 4.3))
	box("steel", Vector3(0.06, 0.42, 0.36), Vector3(2.4, 0.21, 4.3), 0.0, false)
	box("steel", Vector3(0.06, 0.42, 0.36), Vector3(3.6, 0.21, 4.3), 0.0, false)
	solid(Vector3(1.4, 0.47, 0.4), Vector3(3.0, 0.235, 4.3))
	box("blanket", Vector3(0.9, 0.015, 0.6), Vector3(6.0, 0.01, 2.2), 23.0, false)
	# Heavy frame around the door to the test hall.
	for side in [-1.0, 1.0]:
		box("steel", Vector3(0.3, 3.3, 0.3), Vector3(9.8, 1.65, float(side) * 1.65), 0.0, false)
	box("steel", Vector3(0.3, 0.3, 3.6), Vector3(9.8, 3.2, 0.0), 0.0, false)
	stencil("B-1  ACCESO", Vector3(6.0, 2.4, -2.84), 64, "south", PAINT, 0.0)


# --- test hall (0 m): the rig housing and the Column ----------------------------------------------------

func _build_hall() -> void:
	# Test rig housing: low and compact, so it forces a detour without hiding the hall from the camera.
	box("machine", Vector3(5.0, 1.6, 4.0), Vector3(18.0, 0.8, -1.0))
	box("steel", Vector3(4.2, 0.4, 3.2), Vector3(18.0, 1.8, -1.0))
	box("cap", Vector3(5.04, 0.06, 4.04), Vector3(18.0, 1.63, -1.0), 0.0, false)
	for i in 4:
		var vx := 16.3 + 1.1 * float(i)
		box("gen_vent", Vector3(0.8, 0.9, 0.02), Vector3(vx, 0.8, 1.02), 0.0, false)
		for s in 5:
			box("cap", Vector3(0.8, 0.025, 0.012), Vector3(vx, 0.5 + 0.15 * float(s), 1.03), 0.0, false)
	box("hazard", Vector3(5.6, 0.008, 0.2), Vector3(18.0, 0.006, 1.5), 0.0, false)
	cylinder("beacon_red", 0.1, 0.18, Vector3(18.0, 2.1, -1.0), "y", false)
	solid(Vector3(5.0, 2.0, 4.0), Vector3(18.0, 1.0, -1.0))
	_light(Vector3(18.0, 2.8, -1.0), WARNING_RED, 0.45, 5.0)
	# The Column: the Aster calibration column, a landmark visible from every level.
	var cx := 18.0
	var cz := -8.6
	cylinder("steel", 1.0, 0.3, Vector3(cx, 0.15, cz))
	cylinder("machine", 0.8, 7.2, Vector3(cx, 3.9, cz))
	cylinder("steel", 1.0, 0.3, Vector3(cx, 7.65, cz))
	solid(Vector3(2.0, 7.8, 2.0), Vector3(cx, 3.9, cz))
	for i in 5:
		column_rings.append(glow_ring(ASTER_CYAN, 0.35, 0.84, 0.1, Vector3(cx, 1.3 + 1.25 * float(i), cz)))
	# Services along the north wall (under the catwalk): cable tray with three cables, a main pipe, fixtures.
	var wz := -11.8
	box("steel_light", Vector3(15.0, 0.05, 0.32), Vector3(18.0, 2.3, wz), 0.0, false)
	for i in 3:
		cylinder("rubber", 0.032, 15.0, Vector3(18.0, 2.36, wz + 0.1 + 0.09 * float(i)), "x", false)
	cylinder("pipe", 0.1, 15.0, Vector3(18.0, 2.7, wz + 0.05), "x")
	for fx in [12.5, 23.5]:
		box("steel", Vector3(0.95, 0.14, 0.24), Vector3(float(fx), 2.0, wz + 0.12), 0.0, false)
		box("lamp_cold", Vector3(0.82, 0.05, 0.07), Vector3(float(fx), 1.94, wz + 0.23), 0.0, false)
	stencil("B-2  SALA DE ENSAYO", Vector3(18.0, 2.55, wz + 0.4), 56, "south", PAINT, 0.0)
	# Floor stencils at the three exits, hazard paint at the stair mouths.
	stencil("FOSO", Vector3(13.0, 0.012, 6.3), 70, "floor", PAINT, 0.0)
	stencil("BOMBAS", Vector3(24.2, 0.012, -2.6), 56, "floor", PAINT, 0.0)
	stencil("ACCESO", Vector3(12.2, 0.012, -2.6), 56, "floor", PAINT, 0.0)
	box("hazard", Vector3(2.0, 0.008, 0.3), Vector3(13.0, 0.006, 7.8), 0.0, false)
	box("hazard", Vector3(0.3, 0.008, 3.0), Vector3(25.8, 0.006, 0.0), 0.0, false)


# --- service pit (-2 m) ---------------------------------------------------------------------------------------

func _build_pit() -> void:
	var fy := -2.0
	# Intended-distribution schematic: a freestanding board facing north, towards the stairs.
	box("steel", Vector3(0.1, 0.9, 0.1), Vector3(20.9, fy + 0.45, 19.0), 0.0, false)
	box("steel", Vector3(0.1, 0.9, 0.1), Vector3(23.1, fy + 0.45, 19.0), 0.0, false)
	box("steel", Vector3(2.6, 1.5, 0.08), Vector3(22.0, fy + 1.65, 19.0))
	box("stencil", Vector3(2.45, 1.35, 0.02), Vector3(22.0, fy + 1.65, 18.95), 0.0, false)
	box("cap", Vector3(1.9, 0.04, 0.012), Vector3(22.0, fy + 2.05, 18.94), 0.0, false)
	for bx in [21.2, 22.0, 22.8]:
		box("cap", Vector3(0.04, 0.55, 0.012), Vector3(float(bx), fy + 1.78, 18.94), 0.0, false)
	solid(Vector3(2.6, 2.0, 0.2), Vector3(22.0, fy + 1.0, 19.0))
	stencil("DISTRIBUCIÓN PREVISTA", Vector3(22.0, fy + 2.3, 18.92), 30, "south", PAINT, 180.0)
	stencil("MANT.", Vector3(21.2, fy + 1.35, 18.92), 26, "south", PAINT, 180.0)
	stencil("ENSAYO", Vector3(22.0, fy + 1.35, 18.92), 26, "south", PAINT, 180.0)
	stencil("ARCHIVO", Vector3(22.8, fy + 1.35, 18.92), 26, "south", PAINT, 180.0)
	# Tampered bridge: a floor cable, a scorched patch and an orange jumper over the junction box.
	run("rubber", 0.05, Vector3(10.4, fy + 0.08, 18.0), Vector3(13.7, fy + 0.08, 18.0))
	box("steel", Vector3(0.7, 0.9, 0.5), Vector3(14.2, fy + 0.45, 18.0))
	box("cap", Vector3(0.74, 0.04, 0.54), Vector3(14.2, fy + 0.92, 18.0), 0.0, false)
	solid(Vector3(0.7, 0.95, 0.5), Vector3(14.2, fy + 0.475, 18.0))
	box("cap", Vector3(1.1, 0.012, 1.1), Vector3(13.0, fy + 0.008, 18.0), 0.0, false)
	run("safety_paint", 0.035, Vector3(13.95, fy + 0.95, 17.85), Vector3(14.0, fy + 1.3, 17.85))
	run("safety_paint", 0.035, Vector3(14.0, fy + 1.3, 17.85), Vector3(14.5, fy + 1.3, 17.85))
	run("safety_paint", 0.035, Vector3(14.5, fy + 1.3, 17.85), Vector3(14.45, fy + 0.95, 17.85))
	# Maintenance switch on a pedestal, with a work light: amber means it can be used.
	box("steel", Vector3(0.8, 1.1, 0.5), Vector3(23.0, fy + 0.55, 22.6))
	box("safety_paint", Vector3(0.1, 0.45, 0.1), Vector3(23.0, fy + 1.3, 22.45))
	solid(Vector3(0.8, 1.1, 0.5), Vector3(23.0, fy + 0.55, 22.6))
	stencil("MANTENIMIENTO", Vector3(23.0, fy + 1.0, 22.34), 26, "south", Color(0.95, 0.74, 0.35), 180.0)
	_light(Vector3(23.0, fy + 2.4, 22.0), HEATER_WARM, 0.6, 5.0)
	# Pipes along the north wall (the stair mouth is left clear), a portable pump and its hose to the drain.
	cylinder("pipe", 0.12, 11.5, Vector3(20.25, fy + 2.3, 14.2), "x")
	cylinder("pipe_red", 0.07, 11.5, Vector3(20.25, fy + 2.0, 14.12), "x", false)
	for px in [15.0, 19.0, 23.0]:
		box("steel", Vector3(0.06, 0.8, 0.3), Vector3(float(px), fy + 2.2, 14.3), 0.0, false)
	box("machine", Vector3(1.2, 0.8, 0.8), Vector3(11.2, fy + 0.4, 22.8))
	box("cap", Vector3(1.0, 0.08, 0.6), Vector3(11.2, fy + 0.84, 22.8), 0.0, false)
	solid(Vector3(1.2, 0.8, 0.8), Vector3(11.2, fy + 0.4, 22.8))
	run("rubber", 0.055, Vector3(11.9, fy + 0.12, 22.5), Vector3(13.0, fy + 0.055, 21.4))
	box("grate", Vector3(0.6, 0.016, 0.6), Vector3(13.2, fy + 0.008, 21.2), 0.0, false)
	stencil("B-2  FOSO DE SERVICIO", Vector3(18.0, fy + 2.5, 23.82), 48, "south", PAINT, 180.0)


# --- pump room (+1.5 m) ---------------------------------------------------------------------------------------

func _build_pump() -> void:
	var fy := 1.5
	# Warming station: heated grating with an overhead radiant heater.
	var wx := 40.0
	var wz := -1.0
	box("grate_warm", Vector3(3.2, 0.03, 3.0), Vector3(wx, fy + 0.015, wz), 0.0, false)
	box("steel", Vector3(3.3, 0.04, 0.06), Vector3(wx, fy + 0.02, wz - 1.5), 0.0, false)
	box("steel", Vector3(3.3, 0.04, 0.06), Vector3(wx, fy + 0.02, wz + 1.5), 0.0, false)
	box("heater", Vector3(3.0, 0.012, 0.03), Vector3(wx, fy + 0.04, wz - 1.47), 0.0, false)
	box("heater", Vector3(3.0, 0.012, 0.03), Vector3(wx, fy + 0.04, wz + 1.47), 0.0, false)
	cylinder("steel", 0.06, 2.55, Vector3(41.7, fy + 1.275, -2.5))
	solid(Vector3(0.14, 2.5, 0.14), Vector3(41.7, fy + 1.25, -2.5))
	run("steel", 0.04, Vector3(41.7, fy + 2.5, -2.5), Vector3(wx, fy + 2.5, wz - 0.2), true)
	box("steel", Vector3(0.75, 0.16, 0.55), Vector3(wx, fy + 2.42, wz))
	box("heater", Vector3(0.62, 0.02, 0.42), Vector3(wx, fy + 2.33, wz), 0.0, false)
	stencil("PUNTO DE CALOR", Vector3(wx, fy + 0.04, wz + 1.75), 40, "floor", Color(0.95, 0.62, 0.35), 0.0)
	_light(Vector3(wx, fy + 2.0, wz), HEATER_WARM, 0.9, 6.0)
	# Fuel drums by the south wall.
	for p in [Vector3(34.0, fy + 0.44, 5.4), Vector3(34.7, fy + 0.44, 5.65), Vector3(35.3, fy + 0.44, 5.3)]:
		cylinder("pipe_red", 0.29, 0.88, p)
		solid(Vector3(0.58, 0.88, 0.58), p)
	# Meltwater gauge on the east wall, with the maximum level marked in red.
	box("stencil", Vector3(0.03, 2.3, 0.26), Vector3(43.82, fy + 1.35, -3.5), 0.0, false)
	for i in 10:
		box("cap", Vector3(0.012, 0.02, 0.22 if i % 2 == 0 else 0.14), Vector3(43.8, fy + 0.2 + 0.22 * float(i), -3.52), 0.0, false)
	box("pipe_red", Vector3(0.012, 0.035, 0.5), Vector3(43.79, fy + 0.62, -3.5), 0.0, false)
	stencil("NIVEL MÁX.", Vector3(43.8, fy + 0.8, -2.8), 28, "south", Color(0.85, 0.25, 0.2), -90.0)
	# Marked slot for the future lift: hazard outline on the floor and a stencil, no collider.
	box("hazard", Vector3(3.0, 0.01, 0.12), Vector3(38.0, fy + 0.006, 2.5), 0.0, false)
	box("hazard", Vector3(3.0, 0.01, 0.12), Vector3(38.0, fy + 0.006, 5.5), 0.0, false)
	box("hazard", Vector3(0.12, 0.01, 3.0), Vector3(36.5, fy + 0.006, 4.0), 0.0, false)
	box("hazard", Vector3(0.12, 0.01, 3.0), Vector3(39.5, fy + 0.006, 4.0), 0.0, false)
	stencil("ASCENSOR — NO INSTALADO", Vector3(38.0, fy + 0.02, 4.0), 30, "floor", PAINT, 0.0)
	stencil("B-3  BOMBAS", Vector3(41.0, fy + 2.5, -5.82), 56, "south", PAINT, 0.0)


# --- upper catwalk (+3 m) -------------------------------------------------------------------------------------

func _build_catwalk() -> void:
	var fy := 3.0
	var wz := -15.8
	# Services along the north wall.
	box("steel_light", Vector3(34.0, 0.05, 0.32), Vector3(26.0, fy + 2.6, wz), 0.0, false)
	for i in 3:
		cylinder("rubber", 0.032, 34.0, Vector3(26.0, fy + 2.66, wz + 0.1 + 0.09 * float(i)), "x", false)
	cylinder("pipe", 0.1, 34.0, Vector3(26.0, fy + 3.0, wz + 0.05), "x")
	for fx in [11.0, 22.0, 32.0, 41.0]:
		box("steel", Vector3(0.95, 0.14, 0.24), Vector3(float(fx), fy + 2.3, wz + 0.12), 0.0, false)
		box("lamp_cold", Vector3(0.82, 0.05, 0.07), Vector3(float(fx), fy + 2.24, wz + 0.23), 0.0, false)
	# Consoles against the north wall, in front of their position markers: selector, indicators, isolator.
	for cx in [14.0, 20.0]:
		box("steel", Vector3(1.0, 1.3, 0.5), Vector3(float(cx), fy + 0.65, -15.7))
		box("safety_paint", Vector3(0.12, 0.55, 0.12), Vector3(float(cx), fy + 1.45, -15.45))
		solid(Vector3(1.0, 1.3, 0.5), Vector3(float(cx), fy + 0.65, -15.7))
	stencil("SELECTOR", Vector3(14.0, fy + 1.0, -15.44), 28, "south", PAINT, 0.0)
	stencil("AISLADOR", Vector3(20.0, fy + 1.0, -15.44), 28, "south", PAINT, 0.0)
	box("steel", Vector3(3.0, 1.6, 0.3), Vector3(17.0, fy + 1.6, -15.85))
	solid(Vector3(3.0, 1.6, 0.3), Vector3(17.0, fy + 1.6, -15.85))
	indicators["archive"] = glow_box(Color(1.0, 0.7, 0.25), 0.3, Vector3(0.7, 0.1, 0.02), Vector3(17.5, fy + 2.1, -15.68))
	indicators["trial"] = glow_box(Color(1.0, 0.7, 0.25), 0.3, Vector3(0.7, 0.1, 0.02), Vector3(17.5, fy + 1.75, -15.68))
	indicators["protection"] = glow_box(SAFE_GREEN, 0.3, Vector3(0.7, 0.1, 0.02), Vector3(17.5, fy + 1.4, -15.68))
	stencil("ARCHIVO", Vector3(16.4, fy + 2.1, -15.67), 24, "south", PAINT, 0.0)
	stencil("ENSAYO", Vector3(16.4, fy + 1.75, -15.67), 24, "south", PAINT, 0.0)
	stencil("PROTECCIÓN", Vector3(16.3, fy + 1.4, -15.67), 24, "south", PAINT, 0.0)
	# Rail posts along the open south edge (the stair opening is left clear) and a hazard strip on the floor.
	var px := 8.5
	while px < 44.0:
		if px < 35.8 or px > 38.2:
			box("steel", Vector3(0.08, 1.1, 0.08), Vector3(px, fy + 0.55, -12.05), 0.0, false)
		px += 2.0
	box("hazard", Vector3(34.0, 0.008, 0.15), Vector3(26.0, fy + 0.006, -12.3), 0.0, false)
	stencil("B-4  PASARELA DE CONTROL", Vector3(30.0, fy + 3.4, wz + 0.2), 56, "south", PAINT, 0.0)


# --- archive cabin (+3 m) -------------------------------------------------------------------------------------

func _build_cabin() -> void:
	var fy := 3.0
	# Archive desk against the north wall, with the terminal screen kept for the circuit hook-up.
	box("steel", Vector3(2.0, 0.85, 0.7), Vector3(4.0, fy + 0.425, -16.3))
	box("cap", Vector3(2.04, 0.04, 0.74), Vector3(4.0, fy + 0.87, -16.3), 0.0, false)
	solid(Vector3(2.0, 0.9, 0.7), Vector3(4.0, fy + 0.45, -16.3))
	box("steel", Vector3(1.2, 0.75, 0.1), Vector3(4.0, fy + 1.3, -16.5))
	archive_screen = glow_box(ASTER_CYAN, 0.3, Vector3(1.04, 0.6, 0.02), Vector3(4.0, fy + 1.3, -16.43))
	_light(Vector3(4.0, fy + 1.4, -15.6), ASTER_CYAN, 0.5, 5.0)
	# Cabinets along the west wall, and a heavy frame around the door to the catwalk.
	for i in 4:
		box("locker", Vector3(0.45, 1.9, 0.35), Vector3(0.3, fy + 0.95, -14.0 + 0.37 * float(i)))
	box("cap", Vector3(0.47, 0.04, 1.6), Vector3(0.3, fy + 1.92, -13.45), 0.0, false)
	solid(Vector3(0.45, 1.9, 1.6), Vector3(0.3, fy + 0.95, -13.45))
	for zz in [-15.15, -12.85]:
		box("steel", Vector3(0.3, 3.3, 0.3), Vector3(7.85, fy + 1.65, float(zz)), 0.0, false)
	box("steel", Vector3(0.3, 0.3, 2.6), Vector3(7.85, fy + 3.2, -14.0), 0.0, false)
	stencil("ARCHIVO", Vector3(4.0, fy + 2.8, -17.82), 64, "south", PAINT, 0.0)
