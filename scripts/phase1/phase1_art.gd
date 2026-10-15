extends RefCounted
## Environment art layer of Helix Station B (docs/art/ASSET_PRODUCTION_BIBLE.md, "Helix Station B").
##
## phase1_building.gd owns the layout, collision and everything the mission drives; this layer only adds what a player
## sees: the pump hall's volume (clerestory walls, pitched roof on riveted trusses, arched windows, the travelling crane),
## the Aster apparatus, the pit's pumps and pipework, ceilings, wing roofs, props and motivated lighting. Everything static
## is merged into the builder's batches (one draw call per material per 12 m cell per storey band). Nothing here has
## collision unless it says so, and nothing reaches into a walking lane.

const Kit := preload("res://scripts/phase1/kit_library.gd")

const Y_P1 := -2.0
const Y_P0 := 0.0
const Y_M := 3.0
const Y_P2 := 6.0
const TOP := 9.2
const LOW_TOP := 4.5
## Pump hall: the tall nave over the wet well (the old low south block, raised), between the existing tall north block
## (z < -1.5) and the south aisle; aisles (access A to the west, the south band, the east return) keep low roofs.
const HALL_X0 := 6.85
const HALL_X1 := 28.15
const HALL_Z0 := -1.5
const HALL_Z1 := 8.3
const RIDGE := 10.9
const COLUMN := Vector3(14.5, 0.0, -3.0)
## Moonlight through the clerestory: the directional light keeps its shadow so only the window openings let it in.
const MOON_COLOR := Color(0.62, 0.71, 0.86)
const SODIUM := Color(1.0, 0.72, 0.42)
const ASTER_LIGHT := Color(0.79, 0.76, 1.0)

var b = null  # Builder
var mats = null
var kit = null
var root: Node3D
## Lights the scene may drive (the hall's work lamps follow the maintenance circuit).
var hall_lamps: Array[OmniLight3D] = []
var aster_light: OmniLight3D


func _init(builder, materials) -> void:
	b = builder
	mats = materials
	kit = Kit.new(materials)
	root = builder.root


func build() -> void:
	_hall_shell()
	_hall_roof()
	_crane()
	_aster_apparatus()
	_pit_machinery()
	_hall_props()
	_hall_lighting()
	_fixtures()
	_entry_dressing()


# --- helpers ------------------------------------------------------------------------------------------------------

## A kit piece or prop merged into the batches at `pos`, turned `yaw` radians about Y and uniformly scaled.
func place(entry: Dictionary, pos: Vector3, yaw: float = 0.0, scale: float = 1.0, shadow: bool = true) -> void:
	if entry.is_empty():
		return
	var basis := Basis(Vector3.UP, yaw).scaled(Vector3.ONE * scale)
	b.add_mesh_to_batch(entry["mesh"], Transform3D(basis, pos), entry["materials"], shadow)


func box(size: Vector3, center: Vector3, key: String, shadow: bool = true) -> void:
	b.add_box_to_batch(size, Transform3D(Basis.IDENTITY, center), mats.get_material(key), shadow)


## Single-sided ceiling facing down (invisible from above, so the gameplay camera never sees it from behind).
func ceiling(rect: Rect2, y: float, key: String) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x0 := rect.position.x
	var z0 := rect.position.y
	var x1 := rect.end.x
	var z1 := rect.end.y
	st.set_normal(Vector3.DOWN)
	for v in [Vector3(x0, y, z0), Vector3(x1, y, z0), Vector3(x1, y, z1), Vector3(x0, y, z0), Vector3(x1, y, z1), Vector3(x0, y, z1)]:
		st.add_vertex(v)
	var m := st.commit()
	b.add_mesh_to_batch(m, Transform3D.IDENTITY, [mats.get_material(key)], false)


## Straight pipe run through `points` with joints, flanges every ~3 m and at the ends.
func pipe(points: Array, radius: float, key: String, flanges: bool = true) -> void:
	var material: Material = mats.get_material(key)
	var cyl := _cylinder(radius, 10)
	var joint := _sphere(radius * 1.08)
	var flange := _cylinder(radius * 1.45, 12)
	for i in range(points.size() - 1):
		var a: Vector3 = points[i]
		var c: Vector3 = points[i + 1]
		var d := c - a
		var length := d.length()
		if length < 0.01:
			continue
		var y := d / length
		var x := y.cross(Vector3.UP if absf(y.y) < 0.95 else Vector3.RIGHT).normalized()
		var z := x.cross(y).normalized()
		b.add_mesh_to_batch(cyl, Transform3D(Basis(x, y * length, z), (a + c) * 0.5), [material], true)
		if flanges:
			var count := int(floor(length / 3.0))
			for k in range(count + 1):
				var t := 0.0 if count == 0 else float(k) / float(count)
				b.add_mesh_to_batch(flange, Transform3D(Basis(x, y * 0.06, z), a.lerp(c, t)), [material], false)
		if i > 0:
			b.add_mesh_to_batch(joint, Transform3D(Basis.IDENTITY, a), [material], false)


var _mesh_cache: Dictionary = {}


func _cylinder(radius: float, segments: int) -> Mesh:
	var key := "cyl%.3f|%d" % [radius, segments]
	if not _mesh_cache.has(key):
		var m := CylinderMesh.new()
		m.top_radius = radius
		m.bottom_radius = radius
		m.height = 1.0
		m.radial_segments = segments
		m.rings = 1
		_mesh_cache[key] = m
	return _mesh_cache[key]


func _sphere(radius: float) -> Mesh:
	var key := "sph%.3f" % radius
	if not _mesh_cache.has(key):
		var m := SphereMesh.new()
		m.radius = radius
		m.height = radius * 2.0
		m.radial_segments = 10
		m.rings = 5
		_mesh_cache[key] = m
	return _mesh_cache[key]


func lamp(label: String, pos: Vector3, color: Color, energy: float, light_range: float, band: int = -1, shadow: bool = false) -> OmniLight3D:
	var l: OmniLight3D = b.light(label, pos, color, energy, light_range, band)
	l.shadow_enabled = shadow
	return l


# --- pump hall volume ---------------------------------------------------------------------------------------------

func _hall_shell() -> void:
	# Clerestory walls above the aisles (visual: nothing walkable reaches 4.5 m here). Window bays are left open.
	var bays := [8.85, 12.35, 15.85, 19.35, 22.85, 26.35]  # south wall window centres (x)
	_wall_with_windows_x(HALL_Z1, HALL_X0, HALL_X1, bays)
	_wall_with_windows_z(HALL_X1, HALL_Z0, HALL_Z1, [1.6, 5.2], 1.0)
	_wall_with_windows_z(HALL_X0, HALL_Z0, HALL_Z1, [1.6, 5.2], -1.0)
	# Wall over the A/B threshold lintel (3.2 m) up to the aisle ceiling, so the aisle roof void never shows.
	box(Vector3(0.3, LOW_TOP - 3.2, 6.0), Vector3(7.0, (3.2 + LOW_TOP) * 0.5, 7.0), "st_wall")
	# Brick pilasters on the hall side of the clerestory, carrying the crane rail corbels.
	for x in [7.6, 10.6, 14.1, 17.6, 21.1, 24.6, 27.4]:
		box(Vector3(0.5, TOP - LOW_TOP + 0.3, 0.22), Vector3(x, (LOW_TOP + TOP) * 0.5 - 0.15, HALL_Z1 - 0.26), "st_brick")
		box(Vector3(0.6, 0.35, 0.5), Vector3(x, 8.25, HALL_Z1 - 0.4), "st_concrete")
		box(Vector3(0.5, 0.22, 0.4), Vector3(x, 8.25, HALL_Z0 + 0.25), "st_concrete")
	# Aisle ceilings (concrete soffits on steel beams) and the north block's roof soffit.
	ceiling(Rect2(-0.3, HALL_Z0, HALL_X0 + 0.3, 13.95 - HALL_Z0), LOW_TOP - 0.05, "st_concrete")
	ceiling(Rect2(HALL_X0, HALL_Z1 + 0.15, 30.3 - HALL_X0, 13.95 - HALL_Z1 - 0.15), LOW_TOP - 0.05, "st_concrete")
	ceiling(Rect2(HALL_X1 + 0.15, HALL_Z0, 30.3 - HALL_X1 - 0.15, HALL_Z1 - HALL_Z0), LOW_TOP - 0.05, "st_concrete")
	ceiling(Rect2(-0.3, -10.3, 30.6, 10.3 + HALL_Z0), TOP - 0.05, "st_roof")
	for z in [0.5, 3.5, 6.5, 9.5, 12.5]:
		box(Vector3(HALL_X0 + 0.3, 0.3, 0.16), Vector3(HALL_X0 * 0.5 - 0.15, LOW_TOP - 0.2, z), "graphite", false)
	for x in [9.0, 12.0, 15.0, 18.0, 21.0, 24.0, 27.0, 29.5]:
		box(Vector3(0.16, 0.3, 13.95 - HALL_Z1), Vector3(x, LOW_TOP - 0.2, (HALL_Z1 + 13.95) * 0.5), "graphite", false)


## Wall along X at z (from x0 to x1, y 4.5..TOP) with arched window bays centred at `bays`.
func _wall_with_windows_x(z: float, x0: float, x1: float, bays: Array) -> void:
	var w := 1.7
	var cursor := x0
	for c in bays:
		var left: float = float(c) - w * 0.5
		box(Vector3(left - cursor, TOP - LOW_TOP, 0.3), Vector3((cursor + left) * 0.5, (LOW_TOP + TOP) * 0.5, z), "st_brick")
		box(Vector3(w, 0.5, 0.3), Vector3(float(c), LOW_TOP + 0.25, z), "st_brick")  # under the sill
		box(Vector3(w, TOP - 8.8, 0.3), Vector3(float(c), (8.8 + TOP) * 0.5, z), "st_brick")  # over the crown
		place(kit.kit("kit_window_arch"), Vector3(float(c), 5.0, z), 0.0, 1.0, false)  # no shadow: the moon comes in
		cursor = float(c) + w * 0.5
	box(Vector3(x1 - cursor, TOP - LOW_TOP, 0.3), Vector3((cursor + x1) * 0.5, (LOW_TOP + TOP) * 0.5, z), "st_brick")


func _wall_with_windows_z(x: float, z0: float, z1: float, bays: Array, outward: float) -> void:
	var w := 1.7
	var cursor := z0
	for c in bays:
		var left: float = float(c) - w * 0.5
		box(Vector3(0.3, TOP - LOW_TOP, left - cursor), Vector3(x, (LOW_TOP + TOP) * 0.5, (cursor + left) * 0.5), "st_brick")
		box(Vector3(0.3, 0.5, w), Vector3(x, LOW_TOP + 0.25, float(c)), "st_brick")
		box(Vector3(0.3, TOP - 8.8, w), Vector3(x, (8.8 + TOP) * 0.5, float(c)), "st_brick")
		place(kit.kit("kit_window_arch"), Vector3(x, 5.0, float(c)), PI * 0.5 * outward, 1.0, false)
		cursor = float(c) + w * 0.5
	box(Vector3(0.3, TOP - LOW_TOP, z1 - cursor), Vector3(x, (LOW_TOP + TOP) * 0.5, (cursor + z1) * 0.5), "st_brick")


func _hall_roof() -> void:
	# Pitched roof: two corrugated slopes (thin slabs, so they cast the moon's shadow) on riveted trusses and purlins.
	var mid := (HALL_Z0 + HALL_Z1) * 0.5
	var run := (HALL_Z1 - HALL_Z0) * 0.5 + 0.4
	var rise := RIDGE - TOP
	var slope := atan2(rise, run)
	var length := sqrt(run * run + rise * rise)
	var span_x := HALL_X1 - HALL_X0 + 0.8
	for side in [-1.0, 1.0]:
		var center := Vector3((HALL_X0 + HALL_X1) * 0.5, TOP + rise * 0.5 + 0.05, mid + side * run * 0.5)
		var basis := Basis(Vector3.RIGHT, side * slope)
		b.add_box_to_batch(Vector3(span_x, 0.08, length), Transform3D(basis, center), mats.get_material("st_roof"), true)
	# Gable ends (brick) over the clerestory walls at both ends of the hall.
	for x in [HALL_X0, HALL_X1]:
		_gable(x, mid, run, rise)
	for x in [9.6, 13.1, 16.6, 20.1, 23.6, 26.9]:
		place(kit.kit("kit_truss"), Vector3(x, TOP - 0.02, mid), 0.0)
	for k in [-3.0, -1.5, 0.0, 1.5, 3.0]:
		var t: float = absf(k) / run
		box(Vector3(span_x - 0.6, 0.14, 0.1), Vector3((HALL_X0 + HALL_X1) * 0.5, TOP + rise * (1.0 - t) + 0.1, mid + k), "st_green_steel_flat", false)
	# Ridge ventilator: a raised louvred strip along the ridge (reads on the silhouette from outside).
	box(Vector3(span_x - 2.0, 0.5, 1.0), Vector3((HALL_X0 + HALL_X1) * 0.5, RIDGE + 0.3, mid), "st_roof")


func _gable(x: float, mid: float, run: float, rise: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for dx in [-0.15, 0.15]:
		var a := Vector3(x + dx, TOP, mid - run)
		var c := Vector3(x + dx, TOP, mid + run)
		var t := Vector3(x + dx, TOP + rise, mid)
		if dx < 0.0:
			st.add_vertex(a)
			st.add_vertex(t)
			st.add_vertex(c)
		else:
			st.add_vertex(a)
			st.add_vertex(c)
			st.add_vertex(t)
	st.generate_normals()
	b.add_mesh_to_batch(st.commit(), Transform3D.IDENTITY, [mats.get_material("st_brick")], true)


func _crane() -> void:
	# Travelling crane on rails along the hall, parked by the Aster column (the hall's landmark from every level).
	for z in [HALL_Z0 + 0.25, HALL_Z1 - 0.4]:
		box(Vector3(HALL_X1 - HALL_X0 - 0.4, 0.22, 0.3), Vector3((HALL_X0 + HALL_X1) * 0.5, 8.53, z), "st_green_steel_flat")
	var crane: Dictionary = kit.prop("overhead_crane")
	if not crane.is_empty():
		var size: Vector3 = (crane["aabb"] as AABB).size
		var scale := (HALL_Z1 - HALL_Z0 - 0.3) / maxf(size.x, 0.1)
		place(crane, Vector3(12.0, 8.75 - size.y * scale, (HALL_Z0 + HALL_Z1) * 0.5 - 0.1), PI * 0.5, scale)


# --- the Aster calibration column ---------------------------------------------------------------------------------

func _aster_apparatus() -> void:
	place(kit.kit("kit_aster_base"), COLUMN, 0.0, 0.85)
	var core := _cylinder(0.3, 16)
	b.add_mesh_to_batch(core, Transform3D(Basis.IDENTITY.scaled(Vector3(1.0, TOP, 1.0)), COLUMN + Vector3(0.0, TOP * 0.5, 0.0)), [mats.get_material("helix_panel")], true)
	for k in 4:  # vertical copper conductors along the core
		var a := PI * 0.25 + k * PI * 0.5
		box(Vector3(0.05, TOP - 1.6, 0.05), COLUMN + Vector3(cos(a) * 0.3, (TOP + 1.6) * 0.5, sin(a) * 0.3), "copper", false)
	for y in [2.4, 3.6, 5.3, 6.6, 8.1]:
		place(kit.kit("kit_aster_ring"), COLUMN + Vector3(0.0, y, 0.0), 0.0)
	place(kit.kit("kit_aster_crown"), COLUMN + Vector3(0.0, TOP - 0.85, 0.0), 0.0)
	# Cable trays from the crown to the control room's floor riser, and from the base to the pit's switchgear.
	place(kit.kit("kit_cable_tray"), COLUMN + Vector3(1.9, TOP - 0.3, -0.2), 0.0, 1.0, false)
	place(kit.kit("kit_cable_tray"), COLUMN + Vector3(4.9, TOP - 0.3, -0.2), 0.0, 1.0, false)
	# Instrument racks around the base (Helix insert), facing the hall.
	place(kit.kit("kit_rack"), COLUMN + Vector3(-1.8, 0.0, 0.6), PI * 0.5)
	place(kit.kit("kit_rack"), COLUMN + Vector3(-1.8, 0.0, -0.2), PI * 0.5)


# --- the wet well (pit P-1) ---------------------------------------------------------------------------------------

func _pit_machinery() -> void:
	# Two vertical drainage pumps (D1) and their discharge: up the north pit wall, along the manifold, east through the
	# evacuation gallery to the yard outfall (the route Elena's escape follows).
	for x in [14.0, 16.5]:
		place(kit.kit("kit_pump"), Vector3(x, Y_P1, 2.0), PI)
		pipe([Vector3(x, Y_P1 + 0.45, 1.15), Vector3(x, Y_P1 + 0.45, 1.35)], 0.14, "pipe_water", false)
		pipe([Vector3(x, Y_P1 + 0.45, 1.25), Vector3(x, -0.6, 1.25)], 0.15, "pipe_water")
		place(kit.kit("kit_valve"), Vector3(x, Y_P1 + 1.15, 1.25), PI * 0.5, 0.6)
	pipe([Vector3(12.5, -0.6, 1.25), Vector3(27.3, -0.6, 1.25), Vector3(27.3, -0.6, 4.75), Vector3(33.8, -0.6, 4.75)], 0.17, "pipe_water")
	# Drain and air lines higher on the wall, conduit along the top of the retaining wall.
	pipe([Vector3(10.4, -0.25, 1.2), Vector3(27.6, -0.25, 1.2)], 0.06, "pipe_air", false)
	pipe([Vector3(10.3, Y_P1 + 0.25, 7.6), Vector3(23.5, Y_P1 + 0.25, 7.6)], 0.1, "pipe_drain")
	pipe([Vector3(10.3, -0.35, 7.75), Vector3(23.6, -0.35, 7.75)], 0.035, "conduit", false)
	# Sump grating and a ladder down the west wall (the old access for the pump fitters).
	box(Vector3(1.6, 0.04, 1.3), Vector3(12.2, Y_P1 + 0.22, 6.4), "st_tread", false)
	for k in 8:
		box(Vector3(0.5, 0.03, 0.03), Vector3(10.15, Y_P1 + 0.25 + k * 0.27, 3.5), "graphite", false)
	box(Vector3(0.04, 2.3, 0.04), Vector3(10.15, Y_P1 + 1.15, 3.25), "graphite", false)
	box(Vector3(0.04, 2.3, 0.04), Vector3(10.15, Y_P1 + 1.15, 3.75), "graphite", false)


func _hall_props() -> void:
	# Fitters' corner by the east pit rail and the hall floor: drums, a cart, spare parts, cement for the repair crew.
	place(kit.prop("barrel_02"), Vector3(22.6, 0.0, -1.0), 0.3)
	place(kit.prop("barrel_02"), Vector3(23.15, 0.0, -0.75), 1.4)
	place(kit.prop("industrial_storage_cart"), Vector3(18.6, 0.0, -0.6), PI * 0.5)
	place(kit.prop("cement_bag"), Vector3(9.0, 0.0, 0.3), 0.2)
	place(kit.prop("cement_bag"), Vector3(9.05, 0.18, 0.35), -0.15)
	place(kit.prop("wooden_crate_01"), Vector3(8.4, 0.0, -0.9), 0.1)
	place(kit.prop("hand_truck"), Vector3(10.3, 0.0, -1.1), 2.6)
	place(kit.prop("portable_generator"), Vector3(26.4, Y_P1, 7.0), PI)
	place(kit.prop("power_box_01"), Vector3(10.05, -0.95, 5.0), PI * 0.5)


## The flood channel and culvert C-2 (layout in phase1_building.gd _entry): a road above with its guard rail and lamp,
## standing water and what the March flood washed down, a fallen fence panel half hiding the pried grate, and the
## inspection chamber's dying amber lamp glowing at the far end of the culvert, the light that draws the player in.
func _entry_dressing() -> void:
	b.force_band = b.YARD_BAND
	var bank := 1.6
	var floor_y := -1.0
	# standing water down the middle of the channel (dark, glossy) and silt along the walls
	box(Vector3(2.2, 0.02, 20.0), Vector3(-11.6, floor_y + 0.012, 9.6), "water_still", false)
	box(Vector3(0.5, 0.12, 20.0), Vector3(-13.25, floor_y + 0.05, 9.6), "st_rubble", false)
	# road guard rail along both banks
	for x in [-13.95, -9.05]:
		for k in 11:
			box(Vector3(0.08, 0.9, 0.08), Vector3(x, bank + 0.45, -1.5 + k * 2.0), "graphite", false)
		box(Vector3(0.06, 0.06, 21.0), Vector3(x, bank + 0.88, 9.0), "steel_light", false)
		box(Vector3(0.05, 0.05, 21.0), Vector3(x, bank + 0.5, 9.0), "steel_light", false)
	# road lamp leaning over the channel near the culvert mouth
	box(Vector3(0.16, 5.2, 0.16), Vector3(-8.6, bank + 2.6, 9.4), "graphite")
	box(Vector3(1.6, 0.1, 0.1), Vector3(-9.35, bank + 5.15, 9.4), "graphite", false)
	box(Vector3(0.55, 0.12, 0.28), Vector3(-10.1, bank + 5.05, 9.4), "lamp_sodium", false)
	var road := lamp("ChannelRoadLamp", Vector3(-10.1, bank + 4.7, 9.2), Color(1.0, 0.7, 0.42), 1.9, 11.0, b.YARD_BAND)
	road.light_cull_mask = 1 | b.band_layer(b.YARD_BAND)
	# what the flood washed down: a blue drum, crates, a cardboard box going soft
	place(kit.prop("barrel_02"), Vector3(-12.6, floor_y, 13.2), 1.1)
	place(kit.prop("plastic_crate_02"), Vector3(-10.4, floor_y, 15.6), 0.6)
	place(kit.prop("wooden_crate_01"), Vector3(-12.9, floor_y, 3.4), 2.0)
	place(kit.prop("cardboard_box_01"), Vector3(-11.9, floor_y, 17.0), 0.4)
	# the fallen fence panel leaning across the culvert mouth's north side (concealment: the breach is behind it)
	var fence: Material = mats.get_material("fence")
	var panel := Transform3D(Basis(Vector3(0, 1, 0), 0.25).rotated(Vector3(0, 0, 1), 0.35), Vector3(-9.9, floor_y + 1.2, 7.6))
	b.add_box_to_batch(Vector3(0.04, 2.2, 2.6), panel, fence, false)
	b.add_box_to_batch(Vector3(0.06, 2.3, 0.06), panel.translated_local(Vector3(0.0, 0.0, 1.3)), mats.get_material("graphite"), false)
	b.add_box_to_batch(Vector3(0.06, 2.3, 0.06), panel.translated_local(Vector3(0.0, 0.0, -1.3)), mats.get_material("graphite"), false)
	b.force_band = -1
	# the far end of the culvert: the inspection chamber's amber bulkhead, dying (inside, P0 band)
	place(kit.kit("kit_bulkhead"), Vector3(-2.2, 2.1, 4.52), 0.0, 1.0, false)
	var glow := lamp("CulvertChamberGlow", Vector3(-2.2, 1.7, 4.9), Color(1.0, 0.66, 0.36), 0.9, 6.0)
	glow.light_cull_mask = 1 | b.band_layer(1) | b.band_layer(b.YARD_BAND)


## Visible sources for the building's practical lights (phase1_building.gd _lighting) and the P2 suspended ceiling.
func _fixtures() -> void:
	place(kit.kit("kit_bulkhead"), Vector3(0.0, 2.5, 7.0), PI * 0.5, 1.0, false)  # access A, on the west wall
	place(kit.kit("kit_bulkhead"), Vector3(29.85, 1.9, -0.6), -PI * 0.5, 1.0, false)  # by R1
	place(kit.kit("kit_bulkhead"), Vector3(30.0, Y_P1 + 1.8, 6.0), -PI * 0.5, 1.0, false)  # gallery mouth
	for x in [16.0, 21.0, 26.0]:  # pump gallery M: caged fluorescent battens under the P2 slab
		place(kit.prop("caged_hanging_light"), Vector3(x, 5.0, -6.2), 0.0, 1.0, false)
	for x in [20.6, 23.4]:
		place(kit.prop("caged_hanging_light"), Vector3(x, 2.0, -6.0), 0.0, 1.0, false)  # workshop C, under M
	for x in [11.0, 15.0, 19.0, 23.0]:  # south band: battens on the aisle soffit
		place(kit.prop("mounted_fluorescent_lights"), Vector3(x, LOW_TOP - 0.1, 11.0), 0.0, 1.0, false)
	# Helix insert: suspended ceiling over E, F and G with recessed fluorescent panels.
	ceiling(Rect2(0.0, -10.0, 24.0, 5.5), 8.75, "helix_panel")
	for x in [3.5, 6.5, 12.0, 16.0, 20.0]:
		place(kit.prop("mounted_fluorescent_lights"), Vector3(x, 8.7, -7.2), 0.0, 1.0, false)


# --- light ----------------------------------------------------------------------------------------------------------

func _hall_lighting() -> void:
	# Sodium high-bay pendants under the trusses (maintenance circuit dims them; the scene drives energy).
	for spec in [[Vector3(11.2, 8.9, 4.2), "HallLampWest"], [Vector3(21.8, 8.9, 4.2), "HallLampEast"]]:
		place(kit.kit("kit_lamp_highbay"), spec[0], 0.0, 1.0, false)
		var l := lamp(spec[1], spec[0] + Vector3(0.0, -1.9, 0.0), SODIUM, 2.3, 13.0, 1)
		l.light_cull_mask = 1 | b.band_layer(0) | b.band_layer(1)
		hall_lamps.append(l)
	aster_light = lamp("AsterColumnGlow", COLUMN + Vector3(0.0, 2.2, 0.0), ASTER_LIGHT, 0.7, 6.0, 1)
	aster_light.light_cull_mask = 1 | b.band_layer(1) | b.band_layer(2)
