extends RefCounted
## Phase 1 expansion (docs/design/FASE1_ARCHITECTURAL_LAYOUT.md v3.1, FASE1_SPATIAL_GRAPH.md v3.1): the two P0 rooms that
## hold the drawer clues (shift archive, dispatch office), the walkable stair from the south band down to P-2, and the P-2
## complex itself: cable gallery, auxiliary batteries and pump, spares store with the dry cabinet, service substation, the
## dead workshop with the concealed transfer door, and the technical vestibule of the second, active building behind it.
##
## Measured against the built scene, not the 48 x 34 m concept: the building keeps its coordinate system (P-1 = -2, P0 = 0,
## M = +3, P2 = +6; yard at x >= 34). P-2 = -4.00 m is a new floor under and south of the south band, clear of the pit
## (x 10..28, z 1..8), the S1 well (x 23.7..26.3, z 8..11), the yard facade block (x 30.3..34, z 7.8..14) and the yard
## floor, so nothing else in the building moves. Clear height is 3.4 m (floor -4.0, ceiling underside -0.6).
##
## Everything here is real collision. The stair is a solid wedge (no space under it) and is walkable without electricity.
## Fixtures the mission drives (doors, drawer, lights, terminal, disconnector) are exposed as members; the scene script
## (phase1_transfer_controller.gd) owns their behaviour.

const Builder := preload("res://scripts/phase1/phase1_builder.gd")
const Kit := preload("res://scripts/phase1/kit_library.gd")

const Y_P0 := 0.0
const Y_B2 := -4.0
const CEIL := -0.6          # underside of the P-2 ceiling slab (clear height 3.4 m)
const CEIL_TOP := -0.3
const DOOR_H := 2.3
## P-2 gets its own lighting band so the pit's lights never bleed into it (and its lights stay inside it).
const B2_BAND := 5

# --- plan rectangles (x, z, width, depth): interiors, metres -------------------------------------------------------------
const SHIFT_ARCHIVE := Rect2(0.0, -10.0, 3.35, 4.85)
const DISPATCH := Rect2(3.65, -10.0, 3.2, 4.85)
const STAIR_WELL := Rect2(8.0, 11.4, 6.4, 2.0)
const STAIR_LOW := Vector3(14.4, Y_B2, 12.4)
const STAIR_HIGH := Vector3(8.0, Y_P0, 12.4)
const GALLERY := Rect2(14.4, 11.35, 15.35, 2.1)
const BATTERY := Rect2(15.2, 8.95, 7.4, 2.1)
const SPARES := Rect2(14.7, 13.75, 4.8, 6.5)
const SUBSTATION := Rect2(19.8, 13.75, 4.4, 6.5)
const DEAD_WORKSHOP := Rect2(24.5, 13.75, 5.25, 6.5)
const VESTIBULE := Rect2(30.05, 15.05, 6.45, 4.6)
const BAY := Rect2(30.05, 19.95, 7.9, 6.8)

# --- openings --------------------------------------------------------------------------------------------------------------
const ARCHIVE_DOOR_X := Vector2(1.0, 2.6)
const DISPATCH_DOOR_X := Vector2(4.4, 6.0)
const SHIFT_SOUTH_Z := -5.0
const SHIFT_CEILING := 3.3     # underside, P0
const BATTERY_DOOR_X := Vector2(17.2, 19.0)
const SPARES_DOOR_X := Vector2(16.2, 17.8)
const SUBSTATION_DOOR_X := Vector2(21.2, 22.8)
const DEAD_DOOR_X := Vector2(26.0, 27.8)
const GALLERY_SOUTH_Z := 13.6
const GALLERY_NORTH_Z := 11.2
const TRANSFER_X := 29.9
const TRANSFER_Z := Vector2(16.2, 18.2)
const BAY_DOOR_X := Vector2(30.6, 31.8)
const WINDOW_X := Vector2(32.4, 35.4)

# --- interaction anchors (floor positions in front of the object) ---------------------------------------------------------------
const BOARD_AT := Vector3(1.8, Y_P0, -9.0)
const STRIP_AT := Vector3(1.15, Y_P0, -6.4)
const DRAWER_AT := Vector3(5.3, Y_P0, -8.35)
const DISPATCH_NOTE_AT := Vector3(6.2, Y_P0, -6.6)
const SUBSTATION_DOOR_AT := Vector3(22.0, Y_B2, 12.5)
const TERMINAL_AT := Vector3(21.5, Y_B2, 19.2)
const DISCONNECTOR_AT := Vector3(23.4, Y_B2, 17.6)
const CABINET_AT := Vector3(17.0, Y_B2, 19.2)
const LOCKER_AT := Vector3(15.7, Y_B2, 16.6)
const AUX_PUMP_AT := Vector3(21.6, Y_B2, 10.55)
const SEAM_AT := Vector3(29.1, Y_B2, 17.2)
const NOTE_AT := Vector3(25.3, Y_B2, 16.3)
const WINDOW_AT := Vector3(34.7, Y_B2, 18.9)

const SYMBOL_COLOR := Color(0.98, 0.72, 0.18)

var b = null  # Builder
var mats = null
var kit = null
var root: Node3D = null

# Fixtures the scene drives.
var drawer_front: StaticBody3D
var drawer_items: Node3D
var drawer_lock_text: Label3D
var substation_door: StaticBody3D
var substation_lamp: MeshInstance3D
var terminal_bridge: Node3D
var terminal_lamp: MeshInstance3D
var disconnector_lever: Node3D
var disconnector_lamp: MeshInstance3D
var panel_text: Label3D
var transformer_lamp: MeshInstance3D
var aux_pump: Node3D
var cabinet_door: Node3D
var cabinet_key: Node3D
var hidden_panel: StaticBody3D
var transfer_door: StaticBody3D
var transfer_lamp: MeshInstance3D
var reader_text: Label3D
var reader_parts: Array[Node3D] = []
var seam_airflow: CPUParticles3D
var seam_streamer: Node3D
var bay_door: StaticBody3D
var emergency_lights: Array[OmniLight3D] = []
## {"light": OmniLight3D, "energy": float, "sector": int, "broken": bool}: the auxiliary circuit's lights.
var aux_lights: Array[Dictionary] = []
## The active building's lights and machinery: off until the transfer door opens.
var active_lights: Array[OmniLight3D] = []
var active_lamps: Array[MeshInstance3D] = []
var staff: Array[Node3D] = []
var bay_window: StaticBody3D
## Lamps beside the lift call boxes on P0 and M: red until the lift can run (maintenance AND auxiliary supply).
var lift_lamps: Array[MeshInstance3D] = []


func _init(builder, materials) -> void:
	b = builder
	mats = materials
	kit = Kit.new(materials)
	root = builder.root


func build() -> void:
	_lift_indicators()
	b.force_band = 1  # the shift rooms are taller than the P0 lighting band: one band, no slicing at the M soffit line
	_shift_rooms()
	b.force_band = B2_BAND
	_stair()
	_shell()
	_gallery()
	_battery_room()
	_spares_store()
	_substation()
	_dead_workshop()
	_vestibule()
	_bay()
	_lighting()
	b.force_band = -1


## Holes the P0 floor needs (the building subtracts them from its ground slab).
static func floor_holes() -> Array:
	return [STAIR_WELL]


# --- helpers ---------------------------------------------------------------------------------------------------------------

func _m(key: String) -> Material:
	return mats.get_material(key)


## Non-metallic painted metal for furniture and equipment: the facility's metallic materials render near black in the
## diffuse-only illustrated lighting, which hides the shape of whatever the player must find.
const PAINTS := {
	"grey": [Color(0.5, 0.54, 0.54), 0.8],
	"light": [Color(0.68, 0.7, 0.67), 0.75],
	"machine": [Color(0.34, 0.45, 0.43), 0.8],
	"locker": [Color(0.3, 0.42, 0.52), 0.8],
}


func _paint(key: String) -> Material:
	var spec: Array = PAINTS[key]
	return b.flat(spec[0], float(spec[1]))


## See-through glass for the bay window: the staff behind it are the point of the room (the facility's own dark glass is opaque).
func _clear_glass() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.62, 0.8, 0.92, 0.14)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.roughness = 0.1
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


## Render layer of whatever is being built right now (its lighting band).
func _layer() -> int:
	return Builder.band_layer(b.force_band if b.force_band >= 0 else 1)


func _place(entry: Dictionary, pos: Vector3, yaw: float = 0.0, scale: float = 1.0, shadow: bool = false) -> void:
	if entry.is_empty():
		return
	b.add_mesh_to_batch(entry["mesh"], Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * scale), pos), entry["materials"], shadow)


func _glow(color: Color, energy: float = 1.6) -> StandardMaterial3D:
	return b.flat(color, 0.4, 0.0, energy)


## A wall along X at z, from x0 to x1, with door gaps [[x0, x1], ...] (clear to DOOR_H; a lintel closes the rest).
func _wall_z_gaps(label: String, z: float, x0: float, x1: float, y0: float, y1: float, material: Material, gaps: Array = []) -> void:
	var cursor := x0
	var i := 0
	for g in gaps:
		var gap: Vector2 = g
		b.wall_z("%s_%d" % [label, i], z, cursor, gap.x, y0, y1, material)
		b.wall_z("%sLintel_%d" % [label, i], z, gap.x, gap.y, y0 + DOOR_H, y1, material)
		cursor = gap.y
		i += 1
	b.wall_z("%s_%d" % [label, i], z, cursor, x1, y0, y1, material)


func _wall_x_gaps(label: String, x: float, z0: float, z1: float, y0: float, y1: float, material: Material, gaps: Array = []) -> void:
	var cursor := z0
	var i := 0
	for g in gaps:
		var gap: Vector2 = g
		b.wall_x("%s_%d" % [label, i], x, cursor, gap.x, y0, y1, material)
		b.wall_x("%sLintel_%d" % [label, i], x, gap.x, gap.y, y0 + DOOR_H, y1, material)
		cursor = gap.y
		i += 1
	b.wall_x("%s_%d" % [label, i], x, cursor, z1, y0, y1, material)


## The concealed door's symbol (a ring crossed by a bar, two ticks under it). Geometry, not a font glyph, so it reads in any
## language and without relying on colour alone. `facing` is the wall normal: "+x", "-x", "+z", "-z".
func _symbol(label: String, pos: Vector3, facing: String, size: float = 0.5) -> Node3D:
	var g := Node3D.new()
	g.name = label
	g.position = pos
	match facing:
		"+x":
			g.rotation.y = PI * 0.5
		"-x":
			g.rotation.y = -PI * 0.5
		"-z":
			g.rotation.y = PI
	var paint := _glow(SYMBOL_COLOR, 0.9)
	var ring := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = size * 0.5
	cyl.bottom_radius = size * 0.5
	cyl.height = 0.012
	cyl.radial_segments = 20
	ring.mesh = cyl
	ring.rotation.x = PI * 0.5
	ring.material_override = paint
	g.add_child(ring)
	var hole := MeshInstance3D.new()
	var hm := CylinderMesh.new()
	hm.top_radius = size * 0.34
	hm.bottom_radius = size * 0.34
	hm.height = 0.016
	hm.radial_segments = 20
	hole.mesh = hm
	hole.rotation.x = PI * 0.5
	hole.position.z = 0.002
	hole.material_override = b.flat(Color(0.08, 0.08, 0.07), 0.8)
	g.add_child(hole)
	var bar := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(size * 0.1, size * 1.15, 0.02)
	bar.mesh = bm
	bar.position.z = 0.004
	bar.material_override = paint
	g.add_child(bar)
	for s in [-1.0, 1.0]:
		var tick := MeshInstance3D.new()
		var tm := BoxMesh.new()
		tm.size = Vector3(size * 0.26, size * 0.08, 0.02)
		tick.mesh = tm
		tick.position = Vector3(s * size * 0.2, -size * 0.7, 0.004)
		tick.material_override = paint
		g.add_child(tick)
	for child in g.get_children():
		(child as VisualInstance3D).layers = _layer()
		(child as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(g)
	return g


# --- lift indicators (P0 and M call boxes): the visible half of "the lift needs both circuits" ------------------------------------

func _lift_indicators() -> void:
	for spec in [[Vector3(28.2, 1.2 + 0.55, -1.2 + 0.07), "LiftIndicatorP0"], [Vector3(28.2, 3.0 + 1.2 + 0.55, -4.9 - 0.07), "LiftIndicatorM"]]:
		var lamp: MeshInstance3D = b.visual(spec[1], Vector3(0.14, 0.08, 0.05), spec[0], _glow(Color(0.95, 0.2, 0.1), 1.4), false)
		lift_lamps.append(lamp)


func set_lift_indicator(powered: bool) -> void:
	for lamp in lift_lamps:
		lamp.material_override = _glow(Color(0.3, 0.95, 0.45), 1.6) if powered else _glow(Color(0.95, 0.2, 0.1), 1.4)


# --- P0: shift archive and dispatch office -------------------------------------------------------------------------------------

func _shift_rooms() -> void:
	var wall: Material = _m("st_wall")
	var floor_m: Material = _m("st_floor_painted")
	var y1 := SHIFT_CEILING
	# South wall (both doors), partition and east wall; the west and north faces are the building's own walls.
	_wall_z_gaps("ShiftSouthWall", SHIFT_SOUTH_Z, 0.0, 7.15, Y_P0, y1, wall, [ARCHIVE_DOOR_X, DISPATCH_DOOR_X])
	b.wall_x("ShiftPartition", 3.5, -10.0, SHIFT_SOUTH_Z, Y_P0, y1, wall)
	b.wall_x("ShiftEastWall", 7.0, -10.0, SHIFT_SOUTH_Z, Y_P0, y1, wall)
	b.slab("ShiftCeiling", Rect2(0.0, -10.0, 7.15, 5.15), y1 + 0.25, mats.get_material("st_concrete"))
	b.paint_sign("ShiftArchiveSign", "ARCHIVO DE TURNO", Vector3(1.8, 2.75, SHIFT_SOUTH_Z + 0.17), "+z", 30, Color(0.9, 0.86, 0.72))
	b.paint_sign("DispatchSign", "DESPACHO", Vector3(5.2, 2.75, SHIFT_SOUTH_Z + 0.17), "+z", 30, Color(0.9, 0.86, 0.72))
	# --- shift archive -------------------------------------------------------------------------------------------------------
	# The test-order board on the north wall: the ORDER of the readings, no values.
	b.static_visual(Vector3(1.7, 1.1, 0.05), Vector3(1.75, 1.55, -9.95), b.flat(Color(0.86, 0.86, 0.82), 0.7), false)
	b.paint_sign("ShiftBoardText", "COMPROBACIÓN DE PRESIONES\nTURNO 3  ·  ORDEN DE LECTURA\n\n1 · B     2 · D\n3 · A     4 · C\n\nAnotar siempre en este orden.", Vector3(1.75, 1.55, -9.9), "+z", 22, Color(0.12, 0.13, 0.16))
	# Pressure recorder on the west wall with its printed strip: the last stable reading of each point, by name.
	b.body("PressureRecorder", Vector3(0.55, 1.25, 0.9), Vector3(0.28, 0.625, -6.6), _paint("grey"))
	b.static_visual(Vector3(0.04, 0.85, 0.5), Vector3(0.6, 1.0, -6.6), b.flat(Color(0.88, 0.87, 0.8), 0.9), false)
	b.paint_sign("PressureStripText", "REG. DE PRESIÓN  ·  LECTURAS ESTABLES\n\nA : 3\nB : 0\nC : 7\nD : 4\n\n(sin orden de turno)", Vector3(0.63, 1.0, -6.6), "+x", 16, Color(0.14, 0.14, 0.16))
	# Lockers along the partition (shift changing: personal presence), a work table and a chair.
	for k in 4:
		b.body("ShiftLocker_%d" % k, Vector3(0.5, 1.85, 0.45), Vector3(3.05, 0.925, -9.65 + k * 0.62), _paint("locker"))
	b.body("ShiftTable", Vector3(0.8, 0.76, 2.0), Vector3(0.5, 0.38, -8.7), _paint("grey"))  # against the west wall: the way to the board stays free
	_place(kit.prop("clipboard"), Vector3(0.5, 0.76, -9.2), 1.2)
	_place(kit.prop("office_notepads"), Vector3(0.5, 0.76, -8.3), -0.3)
	_place(kit.prop("schoolchair_01"), Vector3(1.2, 0.0, -8.7), -PI * 0.5)
	_place(kit.prop("hanging_industrial_lamp"), Vector3(1.8, 3.0, -7.7))
	b.light("ShiftArchiveLamp", Vector3(1.8, 2.8, -7.7), Color(1.0, 0.84, 0.62), 0.85, 5.5)
	# --- dispatch office -----------------------------------------------------------------------------------------------------
	b.body("DispatchDesk", Vector3(2.3, 0.95, 0.95), Vector3(5.45, 0.475, -9.5), _paint("light"))
	drawer_front = b.body("DispatchDrawerFront", Vector3(0.95, 0.24, 0.05), Vector3(5.45, 0.55, -9.0), _paint("grey"), 1, true, false)
	# Handle and tray travel with the front (the tray sits inside the desk while the drawer is shut).
	for spec in [[Vector3(0.28, 0.06, 0.04), Vector3(0.0, 0.0, 0.04), "steel_light"], [Vector3(0.9, 0.05, 0.5), Vector3(0.0, -0.1, -0.27), "steel"]]:
		var part := MeshInstance3D.new()
		var pm := BoxMesh.new()
		pm.size = spec[0]
		part.mesh = pm
		part.position = spec[1]
		part.material_override = _m(str(spec[2]))
		part.layers = Builder.band_layer(1)
		drawer_front.add_child(part)
	# The code lock beside the drawer: its display shows four dashes until the drawer is open.
	b.static_visual(Vector3(0.3, 0.38, 0.07), Vector3(4.65, 0.62, -9.0), _m("graphite"), false)
	drawer_lock_text = b.screen_text("DispatchLockText", "CÓDIGO\n- - - -", Vector3(4.65, 0.66, -8.955), "+z", 16, Color(0.55, 0.95, 0.65))
	drawer_items = Node3D.new()
	drawer_items.name = "DispatchDrawerItems"
	drawer_items.position = Vector3(5.45, 0.7, -8.62)
	root.add_child(drawer_items)
	drawer_items.visible = false
	_service_key_visual(drawer_items, Vector3(-0.2, 0.0, 0.0))
	_bridge_visual(drawer_items, Vector3(0.18, 0.02, 0.0), 0.6)
	_place(kit.prop("metal_stool_02"), Vector3(5.4, 0.0, -8.2), 0.4)
	_place(kit.prop("classic_laptop"), Vector3(6.1, 0.95, -9.5), -0.4)
	b.body("DispatchFiling", Vector3(0.55, 1.4, 0.5), Vector3(6.55, 0.7, -9.7), _paint("locker"))
	# Optional reminder pinned on the east wall: points back to the board, never to the values.
	b.static_visual(Vector3(0.04, 0.5, 0.4), Vector3(6.82, 1.45, -6.6), b.flat(Color(0.9, 0.86, 0.6), 0.9), false)
	b.paint_sign("DispatchReminderText", "RECORDATORIO\nLas lecturas se anotan\nen el orden de la pizarra\ndel archivo.", Vector3(6.79, 1.45, -6.6), "-x", 13, Color(0.2, 0.18, 0.12))
	b.light("DispatchLamp", Vector3(5.2, 2.8, -7.4), Color(1.0, 0.86, 0.66), 0.8, 5.5)


# --- the stair down: south band (P0) -> P-2, walkable without power ----------------------------------------------------------------

func _stair() -> void:
	var concrete: Material = _m("st_concrete")
	b.wedge("B2Stair", STAIR_LOW, STAIR_HIGH, STAIR_WELL.size.y, Y_B2 - 0.2, concrete)
	# Well walls (their top meets the P0 slab's underside, like S1's) and guard rails on the P0 side. The top of the stair
	# is the stair's own high end (flush with the floor, open to the west): the rail runs along the whole north edge so the
	# way in is the top, never a step off the side; the foot opens into the gallery.
	b.wall_z("B2WellNorth", STAIR_WELL.position.y - 0.15, STAIR_WELL.position.x, STAIR_WELL.end.x, Y_B2 - 0.2, -0.25, concrete)
	b.wall_z("B2WellSouth", STAIR_WELL.end.y + 0.15, STAIR_WELL.position.x, STAIR_WELL.end.x, Y_B2 - 0.2, -0.25, concrete)
	b.rail_x("B2WellRailNorth", STAIR_WELL.position.x + 0.2, STAIR_WELL.end.x, STAIR_WELL.position.y - 0.1, Y_P0)
	b.rail_z("B2WellRailEast", STAIR_WELL.position.y, STAIR_WELL.end.y, STAIR_WELL.end.x + 0.1, Y_P0)
	b.paint_sign("B2StairSign", "P-2  ↓  SERVICIOS\nSUBESTACIÓN · REPUESTOS", Vector3(STAIR_WELL.position.x - 0.8, Y_P0 + 0.02, STAIR_WELL.position.y + 1.0), "floor", 34, Color(0.95, 0.85, 0.5))
	b.light("B2StairLamp", Vector3(11.2, -1.2, 12.4), Color(1.0, 0.72, 0.45), 0.55, 6.0, B2_BAND)


# --- P-2 shell: floors, ceilings, walls -----------------------------------------------------------------------------------------

func _shell() -> void:
	var concrete: Material = _m("st_concrete")
	var floor_m: Material = _m("st_floor_damaged")
	var clean: Material = _m("helix_panel")
	b.slab("B2FloorMain", Rect2(14.4, 11.05, 15.65, 9.5), Y_B2, floor_m)
	b.slab("B2FloorBattery", Rect2(14.9, 8.65, 8.0, 2.4), Y_B2, floor_m)
	b.slab("B2FloorVestibule", Rect2(30.05, 14.75, 6.75, 5.2), Y_B2, _m("helix_floor"))
	b.slab("B2FloorBay", Rect2(29.9, 19.95, 8.2, 7.0), Y_B2, _m("helix_floor"))
	for spec in [["B2CeilingMain", Rect2(14.4, 11.05, 15.65, 9.5)], ["B2CeilingBattery", Rect2(14.9, 8.65, 8.0, 2.4)],
			["B2CeilingVestibule", Rect2(30.05, 14.75, 6.75, 5.2)], ["B2CeilingBay", Rect2(29.9, 19.95, 8.2, 7.0)]]:
		b.slab(spec[0], spec[1], CEIL_TOP, concrete, CEIL_TOP - CEIL)
	# Gallery (spine), with its door to the batteries on the north side and to the three rooms on the south side.
	_wall_z_gaps("B2GalleryNorth", GALLERY_NORTH_Z, 14.4, 29.9, Y_B2, CEIL_TOP, concrete, [BATTERY_DOOR_X])
	_wall_z_gaps("B2GallerySouth", GALLERY_SOUTH_Z, 14.4, 29.9, Y_B2, CEIL_TOP, concrete, [SPARES_DOOR_X, SUBSTATION_DOOR_X, DEAD_DOOR_X])
	b.wall_z("B2SouthWall", 20.4, 14.4, 29.9, Y_B2, CEIL_TOP, concrete)
	b.wall_x("B2SparesWest", 14.55, 13.45, 20.55, Y_B2, CEIL_TOP, concrete)
	b.wall_x("B2SparesSubstationWall", 19.65, 13.45, 20.55, Y_B2, CEIL_TOP, concrete)
	b.wall_x("B2SubstationDeadWall", 24.35, 13.45, 20.55, Y_B2, CEIL_TOP, concrete)
	# The east wall of the gallery and the dead workshop: the concealed transfer door's opening (closed by the panel).
	_wall_x_gaps("B2EastWall", TRANSFER_X, 11.05, 20.55, Y_B2, CEIL_TOP, concrete, [TRANSFER_Z])
	# Batteries.
	b.wall_z("B2BatteryNorth", 8.8, 14.9, 22.9, Y_B2, CEIL_TOP, concrete)
	b.wall_x("B2BatteryWest", 15.05, 8.8, 11.2, Y_B2, CEIL_TOP, concrete)
	b.wall_x("B2BatteryEast", 22.75, 8.8, 11.2, Y_B2, CEIL_TOP, concrete)
	# Vestibule of the active building: clean panels, a different material world from the abandoned plant.
	b.wall_z("B2VestibuleNorth", 14.9, 29.9, 36.8, Y_B2, CEIL_TOP, clean)
	b.wall_x("B2VestibuleEast", 36.65, 14.75, 19.95, Y_B2, CEIL_TOP, clean)
	var z := 19.8
	b.wall_z("B2VestibuleSouthW", z, 29.9, BAY_DOOR_X.x, Y_B2, CEIL_TOP, clean)
	b.wall_z("B2VestibuleSouthDoorLintel", z, BAY_DOOR_X.x, BAY_DOOR_X.y, Y_B2 + DOOR_H, CEIL_TOP, clean)
	b.wall_z("B2VestibuleSouthMid", z, BAY_DOOR_X.y, WINDOW_X.x, Y_B2, CEIL_TOP, clean)
	b.wall_z("B2VestibuleWindowSill", z, WINDOW_X.x, WINDOW_X.y, Y_B2, Y_B2 + 0.95, clean)
	b.wall_z("B2VestibuleWindowHeader", z, WINDOW_X.x, WINDOW_X.y, Y_B2 + 2.25, CEIL_TOP, clean)
	b.wall_z("B2VestibuleSouthE", z, WINDOW_X.y, 36.8, Y_B2, CEIL_TOP, clean)
	bay_window = b.body("B2BayWindow", Vector3(WINDOW_X.y - WINDOW_X.x, 1.3, 0.08), Vector3((WINDOW_X.x + WINDOW_X.y) * 0.5, Y_B2 + 1.6, z), _clear_glass(), 1, false, false)
	# The bay behind the glass: only what the window shows (no way in without the door).
	b.wall_x("B2BayWest", 29.9, 20.55, 27.05, Y_B2, CEIL_TOP, clean)
	b.wall_x("B2BayEast", 38.1, 19.8, 27.05, Y_B2, CEIL_TOP, clean)
	b.wall_z("B2BaySouth", 26.9, 29.9, 38.25, Y_B2, CEIL_TOP, clean)


# --- cable gallery ------------------------------------------------------------------------------------------------------------

func _gallery() -> void:
	# Cable trays and a water main along the ceiling, door lintel plates, warning stencils, the tide line of the old flood.
	b.static_visual(Vector3(15.0, 0.1, 0.5), Vector3(22.3, CEIL - 0.28, 12.1), _m("graphite"), false)
	b.static_visual(Vector3(15.0, 0.07, 0.34), Vector3(22.3, CEIL - 0.2, 12.1), _m("cable"), false)
	b.static_visual(Vector3(14.8, 0.18, 0.18), Vector3(22.2, CEIL - 0.32, 12.9), _m("pipe_water"), false)
	b.static_visual(Vector3(15.3, 0.04, 0.03), Vector3(22.1, Y_B2 + 1.05, GALLERY_NORTH_Z + 0.17), b.flat(Color(0.2, 0.28, 0.34), 0.7), false)  # tide line
	b.paint_sign("GalleryName", "GALERÍA DE CABLES  ·  P-2", Vector3(19.2, Y_B2 + 2.1, GALLERY_NORTH_Z + 0.17), "+z", 32, Color(0.85, 0.82, 0.7))
	b.paint_sign("GalleryArrows", "←  SALIDA / ESCALERA S-B2", Vector3(16.6, Y_B2 + 1.6, GALLERY_NORTH_Z + 0.17), "+z", 22, Color(0.45, 0.95, 0.6))
	b.paint_sign("GalleryToSubstation", "SUBESTACIÓN AUX.  ↓", Vector3(22.0, Y_B2 + 2.15, GALLERY_SOUTH_Z - 0.17), "-z", 26, Color(1.0, 0.8, 0.4))
	b.paint_sign("GalleryToSpares", "ALMACÉN DE REPUESTOS  ↓", Vector3(17.0, Y_B2 + 2.15, GALLERY_SOUTH_Z - 0.17), "-z", 26, Color(0.9, 0.86, 0.7))
	b.paint_sign("GalleryToWorkshop", "TALLER 2  ·  FUERA DE USO  ↓", Vector3(26.9, Y_B2 + 2.15, GALLERY_SOUTH_Z - 0.17), "-z", 24, Color(0.7, 0.68, 0.6))
	b.paint_sign("GalleryToBatteries", "BATERÍAS / BOMBA AUX.  ↑", Vector3(18.1, Y_B2 + 2.15, GALLERY_NORTH_Z + 0.17), "+z", 22, Color(0.9, 0.86, 0.7))
	# Standing water at the foot of the stair and by the spares door (shallow: no collision), a dropped hose, drums.
	b.static_visual(Vector3(2.2, 0.014, 1.5), Vector3(16.2, Y_B2 + 0.008, 12.3), _m("water_still"), false)
	b.static_visual(Vector3(1.6, 0.014, 1.2), Vector3(24.0, Y_B2 + 0.008, 12.8), _m("water_still"), false)
	_place(kit.prop("barrel_02"), Vector3(29.1, Y_B2, 11.75), 0.4)
	_place(kit.prop("plastic_crate_02"), Vector3(28.6, Y_B2, 12.9), 0.5)
	_place(kit.prop("cardboard_box_01"), Vector3(23.9, Y_B2, 11.7), 0.2)
	# The gallery ends at the east wall: a dead end that reads as a dead end (a pipe, a sealed hatch plate), not a missing door.
	b.paint_sign("GalleryEndPlate", "TABIQUE ESTRUCTURAL\nNO PERFORAR", Vector3(TRANSFER_X - 0.17, Y_B2 + 1.7, 12.3), "-x", 20, Color(0.85, 0.8, 0.6))


# --- auxiliary batteries and pump ----------------------------------------------------------------------------------------------

func _battery_room() -> void:
	for k in 3:
		b.body("BatteryBank_%d" % k, Vector3(1.6, 1.7, 0.7), Vector3(16.3 + k * 1.9, Y_B2 + 0.85, 9.3), _paint("machine"))
		b.static_visual(Vector3(1.3, 0.1, 0.02), Vector3(16.3 + k * 1.9, Y_B2 + 1.35, 9.66), b.flat(Color(0.4, 0.95, 0.55), 0.4, 0.0, 1.2), false)
	b.paint_sign("BatteryLabel", "BATERÍAS AUX.  ·  48 V\nSIN CARGA DE MANTENIMIENTO", Vector3(19.1, Y_B2 + 2.0, 8.97), "+z", 22, Color(0.9, 0.86, 0.7))
	# Auxiliary pump skid at the east end: vibrates when the auxiliary supply is on.
	b.body("AuxPumpSkid", Vector3(1.5, 0.2, 1.1), Vector3(21.6, Y_B2 + 0.1, 9.55), _paint("grey"))
	aux_pump = Node3D.new()
	aux_pump.name = "AuxPump"
	aux_pump.position = Vector3(21.6, Y_B2 + 0.2, 9.55)
	root.add_child(aux_pump)
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.1, 0.8, 0.7)
	body.mesh = bm
	body.position.y = 0.4
	body.material_override = _paint("machine")
	body.layers = Builder.band_layer(B2_BAND)
	aux_pump.add_child(body)
	var motor := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.22
	cm.bottom_radius = 0.22
	cm.height = 0.6
	motor.mesh = cm
	motor.rotation.z = PI * 0.5
	motor.position = Vector3(-0.7, 0.45, 0.0)
	motor.material_override = _m("pipe")
	motor.layers = body.layers
	aux_pump.add_child(motor)
	b.paint_sign("AuxPumpTag", "BOMBA AUX. 2\nLÍNEA DE ACHIQUE", Vector3(21.6, Y_B2 + 1.5, 8.97), "+z", 20, Color(0.9, 0.86, 0.7))
	b.solid("AuxPumpSolid", Vector3(1.3, 1.0, 0.9), Vector3(21.6, Y_B2 + 0.5, 9.55))
	_place(kit.prop("power_box_01"), Vector3(15.6, Y_B2, 10.6), PI * 0.5)


# --- spares store: wet floor, tide line, decoy lockers and the raised dry cabinet ---------------------------------------------------

func _spares_store() -> void:
	var tide := Color(0.16, 0.22, 0.28)
	# The March flood left its mark: a dark stained band up to 1.05 m on every wall, a line above it, a wet floor.
	var stain: Material = b.flat(Color(0.2, 0.24, 0.26), 0.9)
	b.static_visual(Vector3(0.02, 1.05, 6.5), Vector3(SPARES.position.x + 0.01, Y_B2 + 0.525, 17.0), stain, false)
	b.static_visual(Vector3(0.02, 1.05, 6.5), Vector3(SPARES.end.x - 0.01, Y_B2 + 0.525, 17.0), stain, false)
	b.static_visual(Vector3(4.8, 1.05, 0.02), Vector3(17.1, Y_B2 + 0.525, SPARES.end.y - 0.01), stain, false)
	b.static_visual(Vector3(0.025, 0.05, 6.5), Vector3(SPARES.position.x + 0.015, Y_B2 + 1.05, 17.0), b.flat(tide, 0.7), false)
	b.static_visual(Vector3(0.025, 0.05, 6.5), Vector3(SPARES.end.x - 0.015, Y_B2 + 1.05, 17.0), b.flat(tide, 0.7), false)
	b.static_visual(Vector3(4.8, 0.05, 0.025), Vector3(17.1, Y_B2 + 1.05, SPARES.end.y - 0.015), b.flat(tide, 0.7), false)
	b.paint_sign("TideMark", "NIVEL 14/03", Vector3(SPARES.position.x + 0.03, Y_B2 + 1.18, 14.6), "+x", 18, Color(0.85, 0.3, 0.25))
	b.static_visual(Vector3(3.6, 0.014, 3.2), Vector3(16.4, Y_B2 + 0.008, 17.3), _m("water_still"), false)
	# Decoys: flooded floor lockers (rusted shut, empty) and an east wall rack of spares below the line.
	for k in 3:
		b.body("SparesLocker_%d" % k, Vector3(0.5, 1.9, 0.6), Vector3(15.0, Y_B2 + 0.95, 15.5 + k * 0.72), _m("st_rust"))
	b.paint_sign("LockerTag", "TAQUILLAS 1-3\nANEGADAS", Vector3(15.28, Y_B2 + 1.45, 16.2), "+x", 14, Color(0.9, 0.86, 0.7))
	b.body("SparesRack", Vector3(0.5, 2.0, 3.4), Vector3(19.15, Y_B2 + 1.0, 16.4), _paint("grey"))
	for k in 3:
		_place(kit.prop("wooden_crate_01"), Vector3(19.1, Y_B2 + 0.05 + k * 0.62, 15.3 + k * 1.0), 0.3 * k, 0.8)
	_place(kit.prop("worn_metal_rack"), Vector3(15.2, Y_B2, 19.3), PI * 0.5, 1.0)
	b.paint_sign("SparesName", "ALMACÉN DE REPUESTOS", Vector3(17.1, Y_B2 + 2.6, SPARES.position.y + 0.02), "+z", 26, Color(0.9, 0.86, 0.7))
	# The dry cabinet: bolted to the south wall above the line (bottom edge 1.4 m), the symbol on its door.
	b.static_visual(Vector3(0.1, 1.45, 0.1), Vector3(16.35, Y_B2 + 0.72, 19.95), _paint("grey"), false)  # posts
	b.static_visual(Vector3(0.1, 1.45, 0.1), Vector3(17.65, Y_B2 + 0.72, 19.95), _paint("grey"), false)
	b.body("DryCabinet", Vector3(1.45, 1.0, 0.5), Vector3(17.0, Y_B2 + 1.9, 20.0), _paint("light"))
	b.paint_sign("DryCabinetLabel", "ARMARIO SECO\nNO ABRIR CON HUMEDAD", Vector3(17.0, Y_B2 + 2.62, 19.73), "-z", 16, Color(0.9, 0.86, 0.7))
	cabinet_door = Node3D.new()
	cabinet_door.name = "DryCabinetDoorHinge"
	cabinet_door.position = Vector3(16.3, Y_B2 + 1.9, 19.74)
	root.add_child(cabinet_door)
	var leaf := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(1.4, 0.95, 0.04)
	leaf.mesh = lm
	leaf.position = Vector3(0.7, 0.0, 0.0)
	leaf.material_override = _m("safety_paint")
	leaf.layers = Builder.band_layer(B2_BAND)
	cabinet_door.add_child(leaf)
	var sym := _symbol("DryCabinetSymbol", Vector3(0.7, 0.06, -0.025), "-z", 0.34)
	sym.reparent(cabinet_door, false)
	sym.position = Vector3(0.7, 0.06, -0.025)
	cabinet_key = Node3D.new()
	cabinet_key.name = "DryCabinetKey"
	cabinet_key.position = Vector3(17.0, Y_B2 + 1.62, 19.95)
	root.add_child(cabinet_key)
	_transfer_key_visual(cabinet_key)
	_place(kit.prop("metal_tool_chest"), Vector3(18.5, Y_B2, 19.7), PI)


# --- service substation -------------------------------------------------------------------------------------------------------------

func _substation() -> void:
	# The door: a steel leaf in the wall gap, locked until the service key is used.
	substation_door = b.body("SubstationDoor", Vector3(SUBSTATION_DOOR_X.y - SUBSTATION_DOOR_X.x, DOOR_H, 0.16), Vector3((SUBSTATION_DOOR_X.x + SUBSTATION_DOOR_X.y) * 0.5, Y_B2 + DOOR_H * 0.5, GALLERY_SOUTH_Z), _m("st_green_steel_flat"), 1, true, false)
	b.paint_sign("SubstationDoorSign", "SUBESTACIÓN AUX.\nSOLO PERSONAL CON LLAVE", Vector3(22.0, Y_B2 + 1.65, GALLERY_SOUTH_Z - 0.09), "-z", 20, Color(1.0, 0.8, 0.4))
	substation_lamp = b.visual("SubstationDoorLamp", Vector3(0.16, 0.1, 0.05), Vector3(21.45, Y_B2 + 1.2, GALLERY_SOUTH_Z - 0.1), _glow(Color(0.95, 0.2, 0.1)), false)
	b.static_visual(Vector3(0.14, 0.2, 0.06), Vector3(22.55, Y_B2 + 1.1, GALLERY_SOUTH_Z - 0.1), _m("graphite"), false)  # key slot housing
	# Switchgear cabinet on the south wall with the four terminals; LIFT AUX is the one with the bridge missing.
	b.body("SwitchgearCabinet", Vector3(3.3, 2.1, 0.5), Vector3(21.9, Y_B2 + 1.05, 20.0), _paint("machine"))
	var face_z := 19.73
	b.paint_sign("SwitchgearTitle", "CUADRO AUXILIAR  ·  B-2", Vector3(21.9, Y_B2 + 1.95, face_z), "-z", 22, Color(0.9, 0.86, 0.7))
	var xs := [20.75, 21.45, 22.15, 22.85]
	var names := ["SERVICIO", "BOMBAS", "LIFT AUX", "RESERVA"]
	for i in 4:
		var x: float = xs[i]
		b.paint_sign("TerminalName_%d" % i, names[i], Vector3(x, Y_B2 + 1.62, face_z), "-z", 12, Color(0.9, 0.86, 0.7))
		if i == 2:
			continue
		# Covered terminals: a plate screwed over the clamps (shapes differ from the bridge, and the plate is marked CUBIERTO).
		b.static_visual(Vector3(0.5, 0.42, 0.06), Vector3(x, Y_B2 + 1.28, face_z - 0.02), _m("graphite"), false)
		b.paint_sign("TerminalCover_%d" % i, "CUBIERTO", Vector3(x, Y_B2 + 1.28, face_z - 0.055), "-z", 9, Color(0.7, 0.7, 0.66))
	# LIFT AUX: two bare copper clamps with a bridge-sized gap between them, a marked slot, a status lamp.
	b.static_visual(Vector3(0.12, 0.3, 0.1), Vector3(21.82, Y_B2 + 1.28, face_z - 0.03), _m("copper"), false)
	b.static_visual(Vector3(0.12, 0.3, 0.1), Vector3(22.48, Y_B2 + 1.28, face_z - 0.03), _m("copper"), false)
	b.static_visual(Vector3(0.75, 0.05, 0.03), Vector3(22.15, Y_B2 + 1.08, face_z - 0.015), b.flat(Color(0.95, 0.7, 0.2), 0.5, 0.0, 0.5), false)  # outline of the missing bridge
	terminal_bridge = Node3D.new()
	terminal_bridge.name = "TerminalBridge"
	terminal_bridge.position = Vector3(22.15, Y_B2 + 1.28, face_z - 0.06)
	root.add_child(terminal_bridge)
	_bridge_visual(terminal_bridge, Vector3.ZERO, 0.7)
	terminal_bridge.visible = false
	terminal_lamp = b.visual("TerminalLamp", Vector3(0.14, 0.09, 0.05), Vector3(22.15, Y_B2 + 1.8, face_z - 0.03), _glow(Color(0.95, 0.2, 0.1)), false)
	panel_text = b.screen_text("SwitchgearText", "", Vector3(22.15, Y_B2 + 0.75, face_z - 0.01), "-z", 12, Color(0.7, 0.95, 0.85))
	# The disconnector: a lever on the east wall; it stays up while the circuit is open.
	b.body("DisconnectorBase", Vector3(0.2, 1.1, 0.7), Vector3(24.08, Y_B2 + 1.2, 17.6), _paint("grey"))
	disconnector_lever = Node3D.new()
	disconnector_lever.name = "DisconnectorLever"
	disconnector_lever.position = Vector3(23.9, Y_B2 + 1.2, 17.6)
	root.add_child(disconnector_lever)
	var arm := MeshInstance3D.new()
	var am := BoxMesh.new()
	am.size = Vector3(0.1, 0.1, 0.9)
	arm.mesh = am
	arm.position = Vector3(0.0, 0.0, 0.0)
	arm.material_override = _m("safety_paint")
	arm.layers = Builder.band_layer(B2_BAND)
	disconnector_lever.add_child(arm)
	disconnector_lever.rotation.x = -0.9  # up: open
	disconnector_lamp = b.visual("DisconnectorLamp", Vector3(0.05, 0.1, 0.14), Vector3(24.02, Y_B2 + 1.95, 17.6), _glow(Color(0.95, 0.2, 0.1)), false)
	b.paint_sign("DisconnectorLabel", "SECCIONADOR\nPRINCIPAL AUX.", Vector3(24.17, Y_B2 + 2.25, 17.6), "-x", 14, Color(0.9, 0.86, 0.7))
	# The transformer in the north-west corner: it hums when the supply is on.
	b.body("AuxTransformer", Vector3(1.3, 1.7, 1.0), Vector3(20.7, Y_B2 + 0.85, 14.45), _paint("machine"))
	transformer_lamp = b.visual("TransformerLamp", Vector3(0.12, 0.08, 0.05), Vector3(20.7, Y_B2 + 1.6, 14.95), _glow(Color(0.3, 0.3, 0.3), 0.0), false)
	b.paint_sign("TransformerTag", "TRAFO AUX 400/48", Vector3(20.7, Y_B2 + 1.25, 14.96), "+z", 12, Color(0.9, 0.86, 0.7))
	b.static_visual(Vector3(0.45, 1.7, 0.2), Vector3(22.15, Y_B2 + 2.9 - 0.8 + 0.0, 19.6), _m("cable"), false)  # cable riser
	_place(kit.prop("utility_box_02"), Vector3(24.0, Y_B2, 15.6), PI * 0.5)
	b.paint_sign("SubstationName", "SUBESTACIÓN AUXILIAR", Vector3(22.0, Y_B2 + 2.7, SUBSTATION.position.y + 0.02), "+z", 24, Color(1.0, 0.8, 0.4))


# --- dead workshop: dust, a clean strip, drag marks, a draught, a note, and the concealed door --------------------------------------

func _dead_workshop() -> void:
	var dust: Material = b.flat(Color(0.46, 0.42, 0.36), 0.98)
	var strip: Array = [Rect2(26.35, 13.75, 1.1, 3.95), Rect2(26.35, 16.65, 3.4, 1.1)]
	var pieces: Array = [DEAD_WORKSHOP]
	for hole in strip:
		var next: Array = []
		for r in pieces:
			next.append_array(Builder.subtract(r, hole))
		pieces = next
	for r in pieces:
		var rr: Rect2 = r
		if rr.size.x > 0.05 and rr.size.y > 0.05:
			b.static_visual(Vector3(rr.size.x, 0.012, rr.size.y), Vector3(rr.position.x + rr.size.x * 0.5, Y_B2 + 0.007, rr.position.y + rr.size.y * 0.5), dust, false)
	# Dust on the benches and a few forgotten items; drag marks on the clean strip (two scuffed pairs) lead to the east wall.
	var scuff: Material = b.flat(Color(0.12, 0.11, 0.1), 0.95)
	for k in 4:
		var off := -0.28 + (k % 2) * 0.56
		b.add_box_to_batch(Vector3(0.9 + 0.12 * k, 0.006, 0.06), Transform3D(Basis(Vector3.UP, 0.04 * (k - 1.5)), Vector3(27.9 + k * 0.45, Y_B2 + 0.014, 17.2 + off)), scuff, false)
	b.add_box_to_batch(Vector3(0.06, 0.006, 1.0), Transform3D(Basis.IDENTITY, Vector3(26.7, Y_B2 + 0.014, 15.4)), scuff, false)
	b.add_box_to_batch(Vector3(0.06, 0.006, 1.0), Transform3D(Basis.IDENTITY, Vector3(27.1, Y_B2 + 0.014, 15.9)), scuff, false)
	b.body("DeadBench", Vector3(0.7, 0.9, 2.3), Vector3(24.95, Y_B2 + 0.45, 18.9), _paint("grey"))
	_place(kit.prop("tool_cart"), Vector3(25.5, Y_B2, 14.6), 0.5)
	_place(kit.prop("metal_stool_02"), Vector3(26.0, Y_B2, 19.4), 0.9)
	b.body("DeadShelf", Vector3(2.0, 1.9, 0.45), Vector3(27.8, Y_B2 + 0.95, 20.0), _paint("light"))
	for k in 3:
		_place(kit.prop("cardboard_box_01"), Vector3(27.1 + k * 0.7, Y_B2 + 1.9, 20.0), 0.3 * k, 0.8)
	b.paint_sign("DeadWorkshopSign", "TALLER 2  ·  FUERA DE USO\nNO CONECTAR", Vector3(27.0, Y_B2 + 2.55, DEAD_WORKSHOP.position.y + 0.02), "+z", 22, Color(0.7, 0.68, 0.6))
	# The maintenance note pinned on the west wall, with the symbol drawn beside it.
	b.static_visual(Vector3(0.03, 0.62, 0.46), Vector3(24.53, Y_B2 + 1.45, 16.3), b.flat(Color(0.9, 0.86, 0.62), 0.9), false)
	b.paint_sign("MaintenanceNoteText", "MANT. 14/03\nTras la fuga, la llave de\ntransferencia se guardó en el\nARMARIO SECO del almacén de\nrepuestos. Mismo símbolo que\nla puerta.", Vector3(24.56, Y_B2 + 1.45, 16.3), "+x", 11, Color(0.2, 0.17, 0.1))
	_symbol("MaintenanceNoteSymbol", Vector3(24.57, Y_B2 + 1.12, 16.3), "+x", 0.18)
	# The door frame in the east wall: dark joint lines around the opening, slightly proud of the wall.
	var joint: Material = b.flat(Color(0.04, 0.04, 0.045), 0.9)
	var fx := TRANSFER_X - 0.17
	b.static_visual(Vector3(0.02, DOOR_H, 0.05), Vector3(fx, Y_B2 + DOOR_H * 0.5, TRANSFER_Z.x), joint, false)
	b.static_visual(Vector3(0.02, DOOR_H, 0.05), Vector3(fx, Y_B2 + DOOR_H * 0.5, TRANSFER_Z.y), joint, false)
	b.static_visual(Vector3(0.02, 0.05, TRANSFER_Z.y - TRANSFER_Z.x), Vector3(fx, Y_B2 + DOOR_H, (TRANSFER_Z.x + TRANSFER_Z.y) * 0.5), joint, false)
	# The cover panel (same material as the wall) hides the door until the anomaly is inspected, then slides along the wall.
	hidden_panel = b.body("HiddenPanel", Vector3(0.12, DOOR_H, TRANSFER_Z.y - TRANSFER_Z.x - 0.04), Vector3(TRANSFER_X - 0.21, Y_B2 + DOOR_H * 0.5, (TRANSFER_Z.x + TRANSFER_Z.y) * 0.5), _m("st_concrete"), 1, true, false)
	# The door leaf behind it: heavy steel, the symbol, a lamp and a reader beside it (all hidden by the panel until then).
	transfer_door = b.body("TransferDoor", Vector3(0.2, DOOR_H, TRANSFER_Z.y - TRANSFER_Z.x), Vector3(TRANSFER_X, Y_B2 + DOOR_H * 0.5, (TRANSFER_Z.x + TRANSFER_Z.y) * 0.5), _paint("light"), 1, true, false)
	var door_sym := _symbol("TransferDoorSymbol", Vector3(0.0, 0.25, 0.0), "-x", 0.62)
	door_sym.reparent(transfer_door, false)
	door_sym.position = Vector3(-0.11, 0.25, 0.0)
	door_sym.rotation = Vector3(0.0, -PI * 0.5, 0.0)
	transfer_lamp = b.visual("TransferDoorLamp", Vector3(0.05, 0.1, 0.5), Vector3(TRANSFER_X - 0.12, Y_B2 + DOOR_H - 0.12, (TRANSFER_Z.x + TRANSFER_Z.y) * 0.5), _glow(Color(0.95, 0.2, 0.1), 1.8), false)
	# The reader beside the door (hidden with the door until the panel slides away).
	reader_parts.append(b.visual("TransferReaderHousing", Vector3(0.1, 0.5, 0.32), Vector3(TRANSFER_X - 0.2, Y_B2 + 1.3, 18.75), _m("graphite"), false))
	reader_text = b.screen_text("TransferReaderText", "", Vector3(TRANSFER_X - 0.255, Y_B2 + 1.32, 18.75), "-x", 8, Color(0.7, 0.95, 0.85))
	reader_parts.append(reader_text)
	reader_parts.append(transfer_lamp)
	for part in reader_parts:
		part.visible = false
	# A draught from the joint (dust motes drifting out of it) and a streamer on a hook that sways in it.
	seam_airflow = CPUParticles3D.new()
	seam_airflow.name = "SeamAirflow"
	seam_airflow.position = Vector3(TRANSFER_X - 0.3, Y_B2 + 0.9, TRANSFER_Z.x + 0.05)
	seam_airflow.amount = 10
	seam_airflow.lifetime = 2.4
	seam_airflow.direction = Vector3(-1.0, 0.05, 0.0)
	seam_airflow.spread = 12.0
	seam_airflow.initial_velocity_min = 0.12
	seam_airflow.initial_velocity_max = 0.22
	seam_airflow.gravity = Vector3.ZERO
	var mote := QuadMesh.new()
	mote.size = Vector2(0.035, 0.035)
	var mote_mat := StandardMaterial3D.new()
	mote_mat.albedo_color = Color(0.85, 0.82, 0.75, 0.55)
	mote_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mote_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mote_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mote.material = mote_mat
	seam_airflow.mesh = mote
	seam_airflow.layers = Builder.band_layer(B2_BAND)
	root.add_child(seam_airflow)
	seam_streamer = Node3D.new()
	seam_streamer.name = "SeamStreamer"
	seam_streamer.position = Vector3(TRANSFER_X - 0.55, CEIL - 0.1, 15.55)
	root.add_child(seam_streamer)
	var ribbon := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(0.05, 0.9, 0.012)
	ribbon.mesh = rm
	ribbon.position.y = -0.45
	ribbon.material_override = b.flat(Color(0.9, 0.5, 0.2), 0.8)
	ribbon.layers = Builder.band_layer(B2_BAND)
	seam_streamer.add_child(ribbon)
	b.light("DeadWorkshopGlow", Vector3(27.0, CEIL - 0.7, 16.8), Color(0.62, 0.7, 0.88), 0.5, 7.0, B2_BAND)


# --- vestibule of the second building ---------------------------------------------------------------------------------------------

func _vestibule() -> void:
	var crate_label := "ASTER  ·  LOTE A-7\n→  ESTACIÓN FINAL THAW"
	# A line of server racks on the north wall, blinking LEDs, a cable trunk; crates on pallets; a hand truck; a camera.
	for k in 3:
		b.body("VestibuleRack_%d" % k, Vector3(0.9, 2.1, 0.7), Vector3(31.4 + k * 1.2, Y_B2 + 1.05, 15.45), _m("helix_panel"))
		for led in 3:
			var lamp: MeshInstance3D = b.visual("VestibuleLed_%d_%d" % [k, led], Vector3(0.05, 0.05, 0.03), Vector3(31.15 + k * 1.2 + led * 0.2, Y_B2 + 1.6, 15.78), _glow(Color(0.3, 1.0, 0.55), 0.0), false)
			active_lamps.append(lamp)
	b.static_visual(Vector3(5.0, 0.14, 0.4), Vector3(33.0, CEIL - 0.25, 15.4), _m("cable"), false)
	for k in 2:
		b.body("VestibuleCrate_%d" % k, Vector3(1.0, 0.9, 1.0), Vector3(35.6, Y_B2 + 0.45, 16.6 + k * 1.3), _m("st_rust"))
		b.paint_sign("VestibuleCrateLabel_%d" % k, crate_label, Vector3(35.09, Y_B2 + 0.6, 16.6 + k * 1.3), "-x", 12, Color(0.95, 0.93, 0.85))
	_place(kit.prop("hand_truck"), Vector3(34.6, Y_B2, 18.9), 2.6)
	_place(kit.prop("security_camera_01"), Vector3(30.4, CEIL - 0.25, 17.6), -PI * 0.5)
	_place(kit.prop("mounted_fluorescent_lights"), Vector3(33.0, CEIL - 0.05, 17.4), 0.0)
	_place(kit.prop("mounted_fluorescent_lights"), Vector3(33.0, CEIL - 0.05, 16.3), 0.0)
	b.paint_sign("VestibuleName", "SECTOR H  ·  ACCESO RESTRINGIDO\nSOLO PERSONAL HELIX", Vector3(36.49, Y_B2 + 2.1, 17.3), "-x", 20, Color(0.9, 0.9, 0.85))
	# Recent use: a yellow lane painted to the transfer door, fresh boot marks on it, a coffee ring on a crate lid.
	b.static_visual(Vector3(5.8, 0.008, 0.18), Vector3(33.0, Y_B2 + 0.009, 17.2), b.flat(Color(0.95, 0.8, 0.2), 0.7), false)
	for k in 5:
		b.add_box_to_batch(Vector3(0.28, 0.006, 0.12), Transform3D(Basis(Vector3.UP, 0.15 * k), Vector3(31.0 + k * 0.9, Y_B2 + 0.016, 17.45 - (k % 2) * 0.35)), b.flat(Color(0.08, 0.08, 0.09), 0.9), false)
	# The bay door (into the room behind the glass): a hinged leaf, locked until the staff come through it.
	var hinge := Node3D.new()
	hinge.name = "BayDoorHinge"
	hinge.position = Vector3(BAY_DOOR_X.x, Y_B2, 19.8)
	root.add_child(hinge)
	bay_door = StaticBody3D.new()
	bay_door.name = "BayDoor"
	bay_door.collision_layer = 1
	bay_door.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(BAY_DOOR_X.y - BAY_DOOR_X.x, DOOR_H, 0.1)
	shape.shape = box
	shape.position = Vector3(box.size.x * 0.5, DOOR_H * 0.5, 0.0)
	bay_door.add_child(shape)
	var dm := MeshInstance3D.new()
	var dbm := BoxMesh.new()
	dbm.size = box.size
	dm.mesh = dbm
	dm.position = shape.position
	dm.material_override = _m("safety_paint")
	dm.layers = Builder.band_layer(B2_BAND)
	bay_door.add_child(dm)
	hinge.add_child(bay_door)
	b.paint_sign("BayDoorSign", "MUELLE DE CARGA", Vector3(31.2, Y_B2 + 2.5, 19.7), "-z", 18, Color(0.9, 0.9, 0.85))
	# Lights of the active building: work lights, off until the transfer door opens.
	for spec in [["VestibuleWork_0", Vector3(32.0, CEIL - 0.5, 16.8), 1.3], ["VestibuleWork_1", Vector3(34.6, CEIL - 0.5, 17.8), 1.2], ["VestibuleWork_2", Vector3(31.0, CEIL - 0.5, 18.6), 1.0]]:
		var l: OmniLight3D = b.light(spec[0], spec[1], Color(0.86, 0.94, 1.0), float(spec[2]), 6.0, B2_BAND)
		l.visible = false
		active_lights.append(l)


# --- the bay: what the window shows -----------------------------------------------------------------------------------------------------

func _bay() -> void:
	var panel: Material = _m("helix_panel")
	for k in 2:
		b.body("BayBench_%d" % k, Vector3(3.2, 0.92, 1.0), Vector3(35.2, Y_B2 + 0.46, 22.4 + k * 2.2), _paint("light"))
		for c in 3:
			var case := MeshInstance3D.new()
			var cm := BoxMesh.new()
			cm.size = Vector3(0.5, 0.3, 0.36)
			case.mesh = cm
			case.position = Vector3(34.2 + c * 0.85, Y_B2 + 1.07, 22.4 + k * 2.2)
			case.material_override = panel
			case.layers = Builder.band_layer(B2_BAND)
			root.add_child(case)
	for k in 3:
		b.body("BayCrate_%d" % k, Vector3(1.0, 0.9, 1.0), Vector3(37.45, Y_B2 + 0.45, 21.0 + k * 1.3), _m("st_rust"))
	b.paint_sign("BayName", "H  ·  LOGÍSTICA DE MUESTRAS", Vector3(34.0, Y_B2 + 2.5, 26.78), "-z", 26, Color(0.9, 0.9, 0.85))
	_place(kit.prop("hanging_industrial_lamp"), Vector3(33.5, CEIL - 0.1, 23.5))
	var l: OmniLight3D = b.light("BayWorkLamp", Vector3(33.5, CEIL - 0.7, 23.5), Color(1.0, 0.9, 0.72), 1.7, 8.0, B2_BAND)
	l.visible = false
	active_lights.append(l)
	var l2: OmniLight3D = b.light("BayWindowGlow", Vector3(33.9, CEIL - 0.6, 21.2), Color(0.86, 0.94, 1.0), 1.1, 5.0, B2_BAND)
	l2.visible = false
	active_lights.append(l2)
	# Two staff members on a fixed beat between the benches (silhouettes behind the glass; no collision, no script of their own).
	for spec in [["StaffA", Vector3(32.6, Y_B2, 21.0), Vector3(32.6, Y_B2, 25.4), Color(0.9, 0.5, 0.15)], ["StaffB", Vector3(33.0, Y_B2, 23.2), Vector3(33.0, Y_B2, 25.0), Color(0.2, 0.55, 0.85)]]:
		var figure := _staff_figure(str(spec[0]), spec[1], spec[3])
		figure.set_meta("beat", [spec[1], spec[2]])
		staff.append(figure)


func _staff_figure(label: String, pos: Vector3, vest: Color) -> Node3D:
	var n := Node3D.new()
	n.name = label
	n.position = pos
	var body := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.24
	cm.height = 1.45
	body.mesh = cm
	body.position.y = 0.78
	body.material_override = b.flat(Color(0.16, 0.18, 0.22), 0.9)
	body.layers = Builder.band_layer(B2_BAND)
	n.add_child(body)
	var stripe := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(0.5, 0.2, 0.5)
	stripe.mesh = sm
	stripe.position.y = 1.0
	stripe.material_override = b.flat(vest, 0.7, 0.0, 0.4)
	stripe.layers = body.layers
	n.add_child(stripe)
	var head := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.15
	hm.height = 0.3
	head.mesh = hm
	head.position.y = 1.62
	head.material_override = b.flat(Color(0.75, 0.6, 0.5), 0.8)
	head.layers = body.layers
	n.add_child(head)
	root.add_child(n)
	return n


# --- key, bridge and transfer key models ----------------------------------------------------------------------------------------------------

func _key_mesh(parent: Node3D, offset: Vector3, color: Color, tag: Color) -> void:
	var shaft := MeshInstance3D.new()
	var sm := BoxMesh.new()
	sm.size = Vector3(0.22, 0.03, 0.03)
	shaft.mesh = sm
	shaft.position = offset + Vector3(0.1, 0.0, 0.0)
	shaft.material_override = b.flat(color, 0.35, 0.8)
	parent.add_child(shaft)
	var bow := MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.top_radius = 0.05
	bm.bottom_radius = 0.05
	bm.height = 0.02
	bow.mesh = bm
	bow.rotation.x = PI * 0.5
	bow.position = offset + Vector3(-0.04, 0.0, 0.0)
	bow.material_override = shaft.material_override
	parent.add_child(bow)
	var teeth := MeshInstance3D.new()
	var tm := BoxMesh.new()
	tm.size = Vector3(0.05, 0.05, 0.03)
	teeth.mesh = tm
	teeth.position = offset + Vector3(0.18, -0.03, 0.0)
	teeth.material_override = shaft.material_override
	parent.add_child(teeth)
	var tg := MeshInstance3D.new()
	var tgm := BoxMesh.new()
	tgm.size = Vector3(0.08, 0.1, 0.01)
	tg.mesh = tgm
	tg.position = offset + Vector3(-0.1, -0.08, 0.0)
	tg.material_override = b.flat(tag, 0.6, 0.0, 0.6)
	parent.add_child(tg)
	for child in parent.get_children():
		if child is VisualInstance3D:
			(child as VisualInstance3D).layers = _layer()


## The service key: brass, a red tag (the substation's colour), no symbol.
func _service_key_visual(parent: Node3D, offset: Vector3) -> void:
	_key_mesh(parent, offset, Color(0.85, 0.65, 0.25), Color(0.9, 0.2, 0.15))


## The transfer key: steel, an amber tag carrying the door's symbol.
func _transfer_key_visual(parent: Node3D) -> void:
	_key_mesh(parent, Vector3.ZERO, Color(0.75, 0.78, 0.82), SYMBOL_COLOR)


## The insulated bridge: a copper bar with two black insulating blocks, the length of the LIFT AUX gap.
func _bridge_visual(parent: Node3D, offset: Vector3, length: float) -> void:
	var bar := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(length, 0.05, 0.05)
	bar.mesh = bm
	bar.position = offset
	bar.material_override = b.flat(Color(0.9, 0.42, 0.1), 0.45, 0.3, 0.3)
	parent.add_child(bar)
	for s in [-1.0, 1.0]:
		var ins := MeshInstance3D.new()
		var im := BoxMesh.new()
		im.size = Vector3(length * 0.2, 0.11, 0.1)
		ins.mesh = im
		ins.position = offset + Vector3(s * length * 0.4, 0.0, 0.0)
		ins.material_override = b.flat(Color(0.05, 0.05, 0.06), 0.7)
		parent.add_child(ins)
	for child in parent.get_children():
		if child is VisualInstance3D:
			(child as VisualInstance3D).layers = _layer()


# --- lighting ---------------------------------------------------------------------------------------------------------------------------------

func _lighting() -> void:
	# Emergency lamps: always on, dim and warm: enough to walk by, not enough to read the rooms.
	for spec in [["B2EmergencyStair", Vector3(15.0, CEIL - 0.6, 12.4), 1.0], ["B2EmergencyGallery", Vector3(22.5, CEIL - 0.6, 12.4), 0.85],
			["B2EmergencyGalleryEast", Vector3(28.0, CEIL - 0.6, 12.4), 0.8], ["B2EmergencySpares", Vector3(17.1, CEIL - 0.6, 17.0), 0.75],
			["B2EmergencySubstation", Vector3(22.0, CEIL - 0.6, 17.0), 0.75], ["B2EmergencyBattery", Vector3(19.0, CEIL - 0.6, 10.0), 0.6]]:
		var l: OmniLight3D = b.light(spec[0], spec[1], Color(1.0, 0.66, 0.38), float(spec[2]), 6.5, B2_BAND)
		emergency_lights.append(l)
	# The auxiliary circuit: cold white, dark until the disconnector is thrown. Sector 0 gallery, 1 rooms. Some stay dead.
	for spec in [["B2AuxGallery0", Vector3(17.5, CEIL - 0.5, 12.4), 1.0, 0, false], ["B2AuxGallery1", Vector3(22.5, CEIL - 0.5, 12.4), 1.0, 0, true],
			["B2AuxGallery2", Vector3(27.5, CEIL - 0.5, 12.4), 1.0, 0, false], ["B2AuxBattery", Vector3(19.0, CEIL - 0.5, 10.0), 0.9, 1, false],
			["B2AuxSpares", Vector3(17.1, CEIL - 0.5, 17.0), 0.9, 1, false], ["B2AuxSubstation", Vector3(22.0, CEIL - 0.5, 17.0), 0.95, 1, false]]:
		var l: OmniLight3D = b.light(spec[0], spec[1], Color(0.82, 0.92, 1.0), 0.0, 6.5, B2_BAND)
		l.visible = false
		aux_lights.append({"light": l, "energy": float(spec[2]) * Builder.LIGHT_GAIN, "sector": int(spec[3]), "broken": bool(spec[4])})


# --- state changes the scene drives (each takes the node that owns the tweens; `instant` applies the end state at once) -----------------

func open_drawer(host: Node, instant: bool = false) -> void:
	drawer_items.visible = true
	drawer_lock_text.text = "CÓDIGO\nABIERTO"
	var to := Vector3(5.45, 0.55, -8.55)
	if instant:
		drawer_front.position = to
	else:
		host.create_tween().tween_property(drawer_front, "position", to, 0.6).set_trans(Tween.TRANS_SINE)
	# The drawer's mesh child follows the body; the open drawer also has no collision (it must not trap Elena at the desk).
	for c in drawer_front.get_children():
		if c is CollisionShape3D:
			(c as CollisionShape3D).set_deferred("disabled", true)


func empty_drawer() -> void:
	drawer_items.visible = false


func open_substation_door(host: Node, instant: bool = false) -> void:
	substation_lamp.material_override = _glow(Color(0.3, 0.95, 0.45))
	var to := substation_door.position + Vector3(1.75, 0.0, 0.0)
	if instant:
		substation_door.position = to
	else:
		host.create_tween().tween_property(substation_door, "position", to, 1.0).set_trans(Tween.TRANS_SINE)
	for c in substation_door.get_children():
		if c is CollisionShape3D:
			(c as CollisionShape3D).set_deferred("disabled", true)


func insert_bridge() -> void:
	terminal_bridge.visible = true
	terminal_lamp.material_override = _glow(Color(0.98, 0.72, 0.2))
	panel_text.text = "LIFT AUX\nBORNE CERRADO\nSECCIONADOR: ABIERTO"


func throw_disconnector(host: Node, instant: bool = false) -> void:
	disconnector_lamp.material_override = _glow(Color(0.3, 0.95, 0.45))
	terminal_lamp.material_override = _glow(Color(0.3, 0.95, 0.45))
	transformer_lamp.material_override = _glow(Color(0.3, 0.95, 0.45), 1.6)
	panel_text.text = "LIFT AUX\nALIMENTACIÓN AUX.: ON\nSECCIONADOR: CERRADO"
	if instant:
		disconnector_lever.rotation.x = 0.9
	else:
		host.create_tween().tween_property(disconnector_lever, "rotation:x", 0.9, 0.5).set_trans(Tween.TRANS_BACK)


## The auxiliary circuit comes on by sectors; one gallery lamp stays dead and the workshop never gets light (tension).
func energize_lights(host: Node, instant: bool = false) -> void:
	for entry in aux_lights:
		var l: OmniLight3D = entry["light"]
		var energy: float = entry["energy"]
		if bool(entry["broken"]):
			l.visible = true
			if instant:
				l.light_energy = energy * 0.25
			else:
				var tw := host.create_tween().set_loops()
				tw.tween_property(l, "light_energy", energy * 0.55, 0.11)
				tw.tween_property(l, "light_energy", 0.0, 0.07)
				tw.tween_interval(1.4)
				tw.tween_property(l, "light_energy", energy * 0.3, 0.05)
				tw.tween_interval(0.5)
			continue
		l.visible = true
		if instant:
			l.light_energy = energy
		else:
			var tw2 := host.create_tween()
			tw2.tween_interval(0.5 + 0.9 * float(entry["sector"]))
			tw2.tween_property(l, "light_energy", energy, 0.8)


func start_pump_vibration(host: Node) -> void:
	var tw := host.create_tween().set_loops()
	tw.tween_property(aux_pump, "position:y", Y_B2 + 0.2 + 0.012, 0.045)
	tw.tween_property(aux_pump, "position:y", Y_B2 + 0.2 - 0.008, 0.045)


func start_streamer(host: Node) -> void:
	var tw := host.create_tween().set_loops()
	tw.tween_property(seam_streamer, "rotation:z", 0.28, 1.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(seam_streamer, "rotation:z", -0.12, 1.7).set_trans(Tween.TRANS_SINE)


func reveal_hidden_door(host: Node, instant: bool = false) -> void:
	for part in reader_parts:
		part.visible = true
	var to := hidden_panel.position + Vector3(0.0, 0.0, -2.06)
	if instant:
		hidden_panel.position = to
	else:
		host.create_tween().tween_property(hidden_panel, "position", to, 1.1).set_trans(Tween.TRANS_SINE)
	for c in hidden_panel.get_children():
		if c is CollisionShape3D:
			(c as CollisionShape3D).set_deferred("disabled", true)


func open_cabinet(host: Node, instant: bool = false) -> void:
	if instant:
		cabinet_door.rotation.y = -1.9
	else:
		host.create_tween().tween_property(cabinet_door, "rotation:y", -1.9, 0.6).set_trans(Tween.TRANS_SINE)
	cabinet_key.visible = true


func take_cabinet_key() -> void:
	cabinet_key.visible = false


func set_reader(lines: Array, lamp_color: Color) -> void:
	reader_text.text = "\n".join(PackedStringArray(lines))
	transfer_lamp.material_override = _glow(lamp_color, 1.8)


func open_transfer_door(host: Node, instant: bool = false) -> void:
	var to := transfer_door.position + Vector3(0.0, 0.0, 2.1)
	if instant:
		transfer_door.position = to
	else:
		host.create_tween().tween_property(transfer_door, "position", to, 1.4).set_trans(Tween.TRANS_SINE)
	for c in transfer_door.get_children():
		if c is CollisionShape3D:
			(c as CollisionShape3D).set_deferred("disabled", true)
	transfer_lamp.material_override = _glow(Color(0.3, 0.95, 0.45), 1.8)


## The active building shows itself: work lights fade in, rack LEDs light, the staff start their beat.
func light_active_building(host: Node, instant: bool = false) -> void:
	for l in active_lights:
		var target := l.light_energy
		l.visible = true
		if instant:
			continue
		l.light_energy = 0.0
		host.create_tween().tween_property(l, "light_energy", target, 1.2)
	for i in active_lamps.size():
		active_lamps[i].material_override = _glow(Color(0.3, 1.0, 0.55), 1.4 if i % 2 == 0 else 0.5)
	var k := 0
	for s in staff:
		var beat: Array = s.get_meta("beat")
		var start: Vector3 = beat[0]
		var stop: Vector3 = beat[1]
		var tw2 := host.create_tween().set_loops()
		tw2.tween_property(s, "position", stop, 5.0 + float(k)).set_trans(Tween.TRANS_SINE)
		tw2.tween_property(s, "position", start, 5.0 + float(k)).set_trans(Tween.TRANS_SINE)
		k += 1


func open_bay_door(host: Node, instant: bool = false) -> void:
	var hinge := bay_door.get_parent() as Node3D
	if instant:
		hinge.rotation.y = -1.75
	else:
		host.create_tween().tween_property(hinge, "rotation:y", -1.75, 0.5).set_trans(Tween.TRANS_QUAD)
	for c in bay_door.get_children():
		if c is CollisionShape3D:
			(c as CollisionShape3D).set_deferred("disabled", true)
