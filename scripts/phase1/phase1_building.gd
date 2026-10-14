extends RefCounted
## Phase 1 building: every floor, wall, stair, rail and set piece of the facility (FASE1_GREYBOX_SPEC.md v3.0).
##
## Vertical datums (v3.0 decision, see FASE1_GREYBOX_SPEC.md): P-1 = -2, P0 = 0, M = +3, P2 = +6. The earlier
## +1.5/+3 datums stacked M and P2 over occupied rooms with 1.25 m of headroom, which no body can walk.
## Plan footprints, names and the topology of FASE1_SPATIAL_GRAPH.md are kept.
##
## Safety rule: every walkable edge above a drop has a guard rail or a wall; the only openings are the stairs,
## the lift landings (gated) and doorways. Stairs are solid wedges, so there is no space under them.

const Builder := preload("res://scripts/phase1/phase1_builder.gd")

const Y_P1 := -2.0
const Y_P0 := 0.0
const Y_M := 3.0
const Y_P2 := 6.0
const TOP := 9.2        # roof line of the tall north block
const LOW_TOP := 4.5    # roof line of the single-storey south block
const RAIL := 1.1

# Plan rectangles (x, z, width, depth).
const PIT := Rect2(10.0, 1.0, 18.0, 7.0)
const S1_WELL := Rect2(24.0, 8.0, 2.0, 3.0)
const SHAFT := Rect2(24.5, -4.5, 3.0, 3.0)
const BRIDGE_CUT := Rect2(28.0, 3.0, 2.0, 6.0)
const GALLERY := Rect2(28.0, 4.5, 6.0, 3.0)
const APRON := Rect2(34.0, 0.5, 10.0, 11.0)
const MOUTH_X := 34.0
const BRIDGE_DECK := 0.35
## R1 shutter centre heights: raised (open, hidden in the lintel box) and closed (resting on the floor).
const R1_OPEN_Y := 3.5
const R1_CLOSED_Y := 1.15
const R1_CRANK_AT := Vector3(29.4, 0.0, 0.3)

# Interaction anchors used by the scene script.
const MAINTENANCE_AT := Vector3(26.4, -2.0, 2.2)
const SCHEMATIC_AT := Vector3(27.6, -2.0, 6.0)
const BRIDGE_AT := Vector3(21.5, -2.0, 4.2)
const SELECTOR_AT := Vector3(12.0, 6.0, -7.6)
const ISOLATOR_AT := Vector3(19.0, 6.0, -7.6)
const PANEL_AT := Vector3(15.5, 7.55, -8.15)
const REARM_AT := Vector3(17.2, 6.0, -7.6)
const DIAGNOSTIC_AT := Vector3(7.4, 6.0, -5.4)
const ARCHIVE_AT := Vector3(4.6, 6.0, -8.8)
const G_INNER_AT := Vector3(3.0, 6.0, -7.25)
const G_OUTER_AT := Vector3(0.0, 6.0, -7.5)
const LIFT_CALL_P0_AT := Vector3(28.2, 0.0, -1.2)
const LIFT_CALL_M_AT := Vector3(28.2, 3.0, -4.9)

var b = null  # Builder
var mats = null

# Dynamic parts the scene drives.
var lift_gate_lower: StaticBody3D
var lift_gate_upper: StaticBody3D
var g_inner_door: StaticBody3D
var g_outer_door: StaticBody3D
var g_status_lamp: MeshInstance3D
var o1_shelf: StaticBody3D
var o3_tray: StaticBody3D
var o3_tray_hanging: MeshInstance3D
var switch_lamp: MeshInstance3D
var panel_text: Label3D
var archive_text: Label3D
var indicator_text: Label3D
var service_lights: Array[OmniLight3D] = []
var alarm_lights: Array[OmniLight3D] = []
var column_rings: Array[MeshInstance3D] = []
var scan_parts: Array[Node3D] = []
var pump_lamps: Array[MeshInstance3D] = []
var exit_reader: Label3D
var r1_shutter: StaticBody3D
var r1_beacon: MeshInstance3D
var gantry_door: MeshInstance3D


func _init(root: Node3D, materials) -> void:
	mats = materials
	b = Builder.new(root, materials)


func build() -> void:
	_shell()
	_p0()
	_pit()
	_east_bridge_and_gallery()
	_apron()
	_mezzanine()
	_s2()
	_p2()
	_gantry()
	_lift_landings()
	_column()
	_lighting()


# --- shell ------------------------------------------------------------------------------------------------------

func _shell() -> void:
	var wall: Material = mats.get_material("wall")
	# West wall (outside face at x = -0.3): entry tunnel opening at P0, G outer door at P2.
	b.wall_x("OuterWestNorth", -0.15, -10.3, -8.25, 0.0, TOP, wall)
	b.wall_x("OuterWestGBelow", -0.15, -8.25, -6.75, 0.0, Y_P2, wall)
	b.wall_x("OuterWestGLintel", -0.15, -8.25, -6.75, Y_P2 + 2.2, TOP, wall)
	b.wall_x("OuterWestMid", -0.15, -6.75, -4.5, 0.0, TOP, wall)
	b.wall_x("OuterWestLow", -0.15, -4.5, 4.5, 0.0, LOW_TOP, wall)
	b.wall_x("OuterWestAccessLintel", -0.15, 4.5, 7.5, 2.4, LOW_TOP, wall)
	b.wall_x("OuterWestSouth", -0.15, 7.5, 13.8, 0.0, LOW_TOP, wall)
	b.wall_z("OuterNorth", -10.15, -0.3, 30.3, 0.0, TOP, wall)
	b.wall_z("OuterSouth", 13.65, -0.3, 30.3, 0.0, LOW_TOP, wall)
	b.wall_x("OuterEastNorth", 30.15, -10.3, -1.5, 0.0, TOP, wall)
	b.wall_x("OuterEastMid", 30.15, -1.5, 4.5, 0.0, LOW_TOP, wall)
	b.wall_x("OuterEastOverGallery", 30.15, 4.5, 7.5, 0.23, LOW_TOP, wall)
	b.wall_x("OuterEastSouth", 30.15, 7.5, 13.8, 0.0, LOW_TOP, wall)
	# Visual roof framing over the tall block (no collision: the camera orbits freely inside).
	for i in 6:
		b.visual("RoofBeam_%02d" % i, Vector3(0.22, 0.35, 10.0), Vector3(2.5 + i * 5.0, TOP - 0.2, -5.0), mats.get_material("steel"), true)


# --- P0: entry, nave, workshop, service gallery, south band --------------------------------------------------

func _p0() -> void:
	b.slab_with_holes("GroundFloor", Rect2(0.0, -10.0, 30.0, 23.5), [PIT, S1_WELL, SHAFT, BRIDGE_CUT], Y_P0)
	# Entry tunnel X -3..0: floor, side walls, ceiling and a closed security gate behind the spawn.
	b.slab("AccessTunnelFloor", Rect2(-3.0, 4.5, 3.0, 3.0), Y_P0)
	b.wall_z("AccessTunnelSouth", 4.35, -3.3, 0.0, 0.0, 2.65)
	b.wall_z("AccessTunnelNorth", 7.65, -3.3, 0.0, 0.0, 2.65)
	b.slab("AccessTunnelCeiling", Rect2(-3.3, 4.2, 3.3, 3.6), 2.65, mats.get_material("bulkhead"))
	b.wall_x("AccessTunnelGate", -3.15, 4.5, 7.5, 0.0, 2.4, mats.get_material("steel"))
	b.paint_sign("AccessTunnelSign", "ACCESO TÉCNICO  ·  HELIX B", Vector3(-0.2, 1.9, 6.0), "-x", 36)
	# A/B threshold piers and lintel.
	b.wall_x("AccessNavePierSouth", 7.0, 4.0, 5.6, 0.0, 3.2)
	b.wall_x("AccessNavePierNorth", 7.0, 8.4, 10.0, 0.0, 3.2)
	b.wall_x("AccessNaveLintel", 7.0, 5.6, 8.4, 2.8, 3.2)
	b.paint_sign("AccessLabel", "A  ·  ESCLUSA DE ACCESO", Vector3(3.5, 0.02, 8.6), "floor", 54)
	b.paint_sign("AccessEvacPlan", "PLAN DE EVACUACIÓN\nRUTA ESTE  →  FOSO  →  GALERÍA DE DESCARGA", Vector3(0.05, 1.6, 9.0), "+x", 30)
	# B/C partition under M (2.75 m clear), with a service doorway.
	b.wall_x("NaveWorkshopPierNorth", 20.0, -10.0, -7.2, 0.0, Y_M - 0.25)
	b.wall_x("NaveWorkshopPierSouth", 20.0, -4.8, -2.0, 0.0, Y_M - 0.25)
	b.wall_x("NaveWorkshopLintel", 20.0, -7.2, -4.8, 2.3, Y_M - 0.25)
	b.paint_sign("NaveLabel", "B  ·  NAVE DE ENSAYO ASTER", Vector3(10.5, 0.02, -0.4), "floor", 54)
	b.paint_sign("WorkshopLabel", "C  ·  TALLER", Vector3(22.0, 0.02, -3.0), "floor", 48)
	b.paint_sign("ServiceGalleryLabel", "GALERÍA DE SERVICIO", Vector3(26.0, 0.02, 0.4), "floor", 40)
	# Workshop: bench, cabinet, repaired panel with a fresh tag (context, no key).
	b.body("WorkshopBench", Vector3(2.0, 0.9, 0.8), Vector3(21.6, 0.45, -8.9), mats.get_material("steel"))
	b.body("WorkshopCabinet", Vector3(0.75, 1.8, 0.6), Vector3(23.2, 0.9, -9.5), mats.get_material("steel_light"))
	b.visual("WorkshopPanel", Vector3(0.9, 1.0, 0.08), Vector3(20.25, 1.4, -6.0), mats.get_material("steel"), false).rotation.y = PI * 0.5
	b.paint_sign("WorkshopRepairTag", "PUENTE TEMPORAL A→T\nRETIRAR TRAS ENSAYO\n— firma ilegible —", Vector3(20.3, 1.35, -6.0), "+x", 22, Color(0.95, 0.8, 0.5))
	b.body("WorkshopCableReel", Vector3(0.9, 0.9, 0.9), Vector3(22.8, 0.45, -3.4), mats.get_material("rubber"))
	# Nave: service cabinets along the atrium and crates by the access (mantle-able, optional).
	for i in 3:
		b.body("NaveServiceCabinet_%02d" % i, Vector3(0.75, 1.5, 0.65), Vector3(8.6 + i * 1.9, 0.75, -9.4), mats.get_material("steel_light"))
	b.body("AccessCrateLow", Vector3(1.2, 0.8, 1.0), Vector3(5.2, 0.4, 11.8), mats.get_material("locker"))
	b.body("AccessCrateHigh", Vector3(1.2, 1.5, 1.0), Vector3(6.4, 0.75, 12.4), mats.get_material("locker"))
	# Collapsed direct stair P0 -> P2: the upper flight still hangs from P2 (its foot ends 2.5 m above the floor)
	# and the lower flight lies as rubble. Visible, unmistakably broken, never walkable (FASE1_SPATIAL_GRAPH no-edge).
	var stair: MeshInstance3D = b.visual("BrokenApproachStairVisual", Vector3(2.0, 0.22, 4.95), Vector3(3.0, 4.25, -1.25), mats.get_material("grate"), true)
	stair.rotation.x = atan2(3.5, 3.5)
	b.body("BrokenStairRubble", Vector3(2.2, 0.9, 2.4), Vector3(3.0, 0.45, 1.8), mats.get_material("bulkhead"))
	b.visual("BrokenStairRubbleSlab", Vector3(1.9, 0.18, 2.6), Vector3(3.1, 0.95, 1.6), mats.get_material("grate"), true).rotation = Vector3(0.35, 0.2, 0.1)
	b.paint_sign("BrokenStairSign", "ESCALERA COLAPSADA  ·  NO PASAR", Vector3(3.0, 1.5, 3.02), "+z", 34, Color(1.0, 0.7, 0.3))


# --- P-1: pit, S1, maintenance and the tampered bridge ------------------------------------------------------------

func _pit() -> void:
	b.slab("PitFloor", PIT, Y_P1, mats.get_material("grate"))
	# Retaining walls between the pit floor and the P0 slab (no hidden void under the floor edge).
	b.wall_z("PitWallNorth", 0.85, 9.7, 28.3, Y_P1, -0.25)
	b.wall_z("PitWallSouthWest", 8.15, 9.7, 23.85, Y_P1, -0.25)
	b.wall_z("PitWallSouthEast", 8.15, 26.15, 28.3, Y_P1, -0.25)
	b.wall_x("PitWallWest", 9.85, 1.0, 8.0, Y_P1, -0.25)
	b.wall_x("PitWallEastNorth", 28.15, 1.0, 4.35, Y_P1, -0.25)
	b.wall_x("PitWallEastSouth", 28.15, 7.65, 8.0, Y_P1, -0.25)
	# S1: solid stair P0 (south, z = 11) -> P-1 (north, z = 8), walled well, guard rails on P0 around the well.
	b.wedge("S1Stair", Vector3(25.0, Y_P1, 8.0), Vector3(25.0, Y_P0, 11.0), 2.0, Y_P1 - 0.2)
	b.wall_x("S1WellWest", 23.85, 8.0, 11.0, Y_P1, -0.25)
	b.wall_x("S1WellEast", 26.15, 8.0, 11.0, Y_P1, -0.25)
	b.rail_z("S1GuardWest", 8.0, 11.0, 23.9, Y_P0)
	b.rail_z("S1GuardEast", 8.0, 11.0, 26.1, Y_P0)
	b.paint_sign("S1Sign", "S1  ↓  FOSO / D", Vector3(25.0, 0.02, 12.3), "floor", 56)
	# Pit guard rails on P0 (the east side over the bridge zone is built with the bridge).
	b.rail_z("PitRailWest", 1.0, 8.0, 9.95, Y_P0)
	b.rail_x("PitRailNorth", 10.0, 28.0, 0.95, Y_P0)
	b.rail_x("PitRailSouthWest", 10.0, 23.85, 8.05, Y_P0)
	b.rail_x("PitRailSouthEast", 26.15, 28.0, 8.05, Y_P0)
	b.rail_z("PitRailEastNorth", 1.0, 3.0, 28.05, Y_P0)
	# D1: drainage pumps, sump and tide marks.
	b.body("D1PumpA", Vector3(0.9, 1.1, 0.9), Vector3(14.0, Y_P1 + 0.55, 2.0), mats.get_material("machine"))
	b.body("D1PumpB", Vector3(0.9, 1.1, 0.9), Vector3(16.5, Y_P1 + 0.55, 2.0), mats.get_material("machine"))
	b.visual("D1Manifold", Vector3(5.0, 0.18, 0.18), Vector3(15.0, Y_P1 + 1.4, 1.5), mats.get_material("pipe"), true)
	b.body("D1Sump", Vector3(1.4, 0.2, 1.1), Vector3(12.2, Y_P1 + 0.1, 6.4), mats.get_material("steel"))
	b.paint_sign("D1Label", "D1  ·  ACHIQUE", Vector3(14.5, Y_P1 + 0.02, 5.0), "floor", 54)
	b.paint_sign("D1TideMark", "NIVEL MÁX. 14/03", Vector3(10.05, Y_P1 + 0.6, 4.0), "+x", 26, Color(0.85, 0.3, 0.25))
	b.paint_sign("D2Label", "D2  ·  DISTRIBUCIÓN", Vector3(23.0, Y_P1 + 0.02, 7.2), "floor", 48)
	# D2: intended-distribution schematic (east pit wall), tampered A->T bridge, maintenance switch.
	b.visual("SchematicBoard", Vector3(0.1, 1.3, 2.2), Vector3(27.95, Y_P1 + 1.3, 6.0), mats.get_material("screen_dark"), false)
	b.screen_text("SchematicDiagram", "ESQUEMA DE DISTRIBUCIÓN PREVISTA\n\nFUENTE AUXILIAR\n├ EMERGENCIA → DIAGNÓSTICO\n├ MANTENIMIENTO → LUCES / ELEVADOR\n└ PROTECCIÓN → SELECTOR\n      ├ ENSAYO → T\n      └ ARCHIVO → A", Vector3(27.88, Y_P1 + 1.32, 6.0), "-x", 18, Color(0.75, 0.92, 0.95))
	b.visual("BridgeTerminalA", Vector3(0.5, 0.7, 0.4), Vector3(20.2, Y_P1 + 0.35, 4.2), mats.get_material("steel_light"), true)
	b.visual("BridgeTerminalT", Vector3(0.5, 0.7, 0.4), Vector3(22.8, Y_P1 + 0.35, 4.2), mats.get_material("steel_light"), true)
	b.paint_sign("BridgeLabelA", "A", Vector3(20.2, Y_P1 + 0.8, 4.41), "+z", 64)
	b.paint_sign("BridgeLabelT", "T", Vector3(22.8, Y_P1 + 0.8, 4.41), "+z", 64)
	b.visual("TamperedBridge", Vector3(2.6, 0.09, 0.09), Vector3(21.5, Y_P1 + 0.62, 4.2), b.flat(Color(0.9, 0.42, 0.1), 0.45, 0.3, 0.6), false)
	b.visual("TamperedBridgeClampA", Vector3(0.16, 0.16, 0.16), Vector3(20.45, Y_P1 + 0.62, 4.2), mats.get_material("steel"), false)
	b.visual("TamperedBridgeClampT", Vector3(0.16, 0.16, 0.16), Vector3(22.55, Y_P1 + 0.62, 4.2), mats.get_material("steel"), false)
	b.visual("BridgeScorch", Vector3(1.2, 0.01, 0.8), Vector3(21.5, Y_P1 + 0.01, 4.2), b.flat(Color(0.05, 0.04, 0.035), 0.95), false)
	b.body("MaintenanceHousing", Vector3(0.7, 1.2, 0.4), Vector3(26.4, Y_P1 + 0.6, 1.4), mats.get_material("steel_light"))
	switch_lamp = b.visual("MaintenanceStatusLamp", Vector3(0.22, 0.12, 0.06), Vector3(26.4, Y_P1 + 1.05, 1.62), b.flat(Color(0.9, 0.2, 0.1), 0.35, 0.0, 1.3), false)
	b.paint_sign("MaintenanceLabel", "MANTENIMIENTO", Vector3(26.4, Y_P1 + 1.35, 1.61), "+z", 30)


# --- P0 east return, bridge over the evacuation gallery, gallery itself -------------------------------------------

func _east_bridge_and_gallery() -> void:
	# The east return corridor (X 28..30) bridges the gallery: ramps up 0.35 m so the gallery below keeps 2.23 m.
	b.wedge("EastReturnRampNorth", Vector3(29.0, Y_P0, 3.0), Vector3(29.0, BRIDGE_DECK, 4.5), 2.0, -0.25, mats.get_material("grate"), false)
	b.slab("EastReturnBridgeDeck", Rect2(28.0, 4.5, 2.0, 3.0), BRIDGE_DECK, mats.get_material("grate"), 0.12)
	b.wedge("EastReturnRampSouth", Vector3(29.0, Y_P0, 9.0), Vector3(29.0, BRIDGE_DECK, 7.5), 2.0, -0.25, mats.get_material("grate"), false)
	b.rail_z("EastReturnBridgeRail", 3.0, 8.05, 28.05, Y_P0, RAIL + BRIDGE_DECK + 0.1)
	b.paint_sign("EastReturnSign", "RETORNO ESTE", Vector3(29.0, 0.02, 1.7), "floor", 40)
	# R1: sector shutter between the service gallery and the east return. Raised (open) until Containment.
	b.wall_x("R1FrameWest", 28.0, 0.9, 1.2, 0.0, 2.6, mats.get_material("steel"))
	b.body("R1Lintel", Vector3(2.1, 0.3, 0.3), Vector3(29.0, 2.6, 1.05), mats.get_material("steel"))
	r1_shutter = b.body("R1Shutter", Vector3(1.9, 2.3, 0.1), Vector3(29.0, R1_OPEN_Y, 1.05), mats.get_material("steel_light"))
	r1_beacon = b.visual("R1Beacon", Vector3(0.2, 0.12, 0.12), Vector3(29.0, 2.82, 0.88), b.flat(Color(0.2, 0.2, 0.2), 0.4), false)
	b.visual("R1CrankWheel", Vector3(0.08, 0.45, 0.45), Vector3(29.85, 1.1, 0.35), mats.get_material("pipe_red"), false)
	b.paint_sign("R1CrankSign", "DESBLOQUEO\nDE EMERGENCIA", Vector3(29.84, 1.55, 0.35), "-x", 20, Color(1.0, 0.8, 0.4))
	# P-1 evacuation gallery X 28..34, Z 4.5..7.5, floor Y -2, 2.23 m clear, roofed, walled.
	b.slab("EvacGalleryFloor", GALLERY, Y_P1, mats.get_material("floor"))
	b.wall_z("EvacGalleryNorth", 4.35, 28.0, MOUTH_X, Y_P1, 0.23)
	b.wall_z("EvacGallerySouth", 7.65, 28.0, MOUTH_X, Y_P1, 0.23)
	b.slab("EvacGalleryRoof", Rect2(30.0, 4.2, MOUTH_X - 30.0, 3.6), 0.48, mats.get_material("bulkhead"))
	b.paint_sign("EvacGallerySign", "GALERÍA DE DESCARGA  →  SALIDA DE SERVICIO", Vector3(28.4, Y_P1 + 1.7, 4.52), "+z", 26, Color(0.4, 1.0, 0.55))
	b.visual("EvacGalleryStripN", Vector3(5.6, 0.05, 0.05), Vector3(31.0, Y_P1 + 0.3, 4.53), b.flat(Color(0.3, 1.0, 0.45), 0.4, 0.0, 1.4), false)
	b.visual("EvacGalleryStripS", Vector3(5.6, 0.05, 0.05), Vector3(31.0, Y_P1 + 0.3, 7.47), b.flat(Color(0.3, 1.0, 0.45), 0.4, 0.0, 1.4), false)
	b.light("EvacGalleryLight", Vector3(31.0, Y_P1 + 1.9, 6.0), Color(0.9, 0.45, 0.3), 0.9, 5.0)


# --- exterior apron at the east mouth (start of the parking area) -------------------------------------------------

func _apron() -> void:
	b.slab("ServiceApronFloor", APRON, Y_P1, mats.get_material("floor"))
	b.wall_x("ApronWestNorth", MOUTH_X + 0.15, APRON.position.y, 4.5, Y_P1, 0.48, mats.get_material("bulkhead"))
	b.wall_x("ApronWestSouth", MOUTH_X + 0.15, 7.5, APRON.end.y, Y_P1, 0.48, mats.get_material("bulkhead"))
	b.wall_z("ApronNorthRetaining", APRON.position.y - 0.15, MOUTH_X, APRON.end.x, Y_P1, 0.4, mats.get_material("bulkhead"))
	b.wall_z("ApronSouthRetaining", APRON.end.y + 0.15, MOUTH_X, APRON.end.x, Y_P1, 0.4, mats.get_material("bulkhead"))
	# Parking language continues past the mouth: bay lines, a column, a lamp mast and a parked service van.
	for i in 4:
		b.visual("ApronBayLine_%02d" % i, Vector3(0.1, 0.02, 3.2), Vector3(37.0 + i * 2.6, Y_P1 + 0.012, 2.4), b.flat(Color(0.75, 0.7, 0.45), 0.9), false)
	b.body("ApronColumn", Vector3(0.8, 4.0, 0.8), Vector3(40.0, Y_P1 + 2.0, 8.6), mats.get_material("bulkhead"))
	b.body("ApronVan", Vector3(4.2, 1.9, 1.9), Vector3(40.5, Y_P1 + 0.95, 2.4), b.flat(Color(0.2, 0.24, 0.27), 0.6, 0.2))
	b.visual("ApronLampMast", Vector3(0.15, 4.5, 0.15), Vector3(36.0, Y_P1 + 2.25, 10.8), mats.get_material("steel"), true)
	b.light("ApronSodiumLight", Vector3(36.5, Y_P1 + 4.2, 9.5), Color(1.0, 0.72, 0.42), 1.6, 12.0)
	exit_reader = b.screen_text("ApronContainmentReader", "PROTOCOLO DE CONTENCIÓN: INACTIVO", Vector3(MOUTH_X + 0.32, Y_P1 + 2.0, 9.0), "+x", 24, Color(0.6, 0.9, 0.7))
	b.paint_sign("ApronParkingSign", "APARCAMIENTO DE SERVICIO", Vector3(MOUTH_X + 0.32, Y_P1 + 2.6, 2.5), "+x", 40, Color(0.9, 0.85, 0.6))
	b.wall_x("ApronEastFence", APRON.end.x + 0.15, APRON.position.y, APRON.end.y, Y_P1, Y_P1 + 2.4, mats.get_material("steel"))


# --- M: pump room and observation, over the north block --------------------------------------------------------

func _mezzanine() -> void:
	b.slab("MezzanineFloor", Rect2(7.5, -10.0, 22.35, 5.5), Y_M, mats.get_material("grate"))
	# S2 landing (X 7.5..9) in front of the stair foot, plus the slab the solid stair stands on.
	b.slab("S2BaseSlab", Rect2(7.5, -4.5, 6.0, 3.0), Y_M, mats.get_material("grate"))
	# Guard rails: west edge (open to the P0 west area), S2 landing, atrium edge, east of the shaft.
	b.rail_z("MezzanineRailWest", -10.0, -1.5, 7.45, Y_M)
	b.rail_x("S2LandingRailSouth", 7.5, 9.0, -1.55, Y_M)
	b.rail_x("MezzanineRailAtrium", 13.5, 24.5, -4.45, Y_M)
	b.rail_x("MezzanineRailEastOfShaft", 27.5, 29.85, -4.45, Y_M)
	b.paint_sign("PumpRoomLabel", "M  ·  SALA DE BOMBAS", Vector3(18.5, Y_M + 0.02, -5.2), "floor", 48)
	# C1: the pump bank, opaque cover between the staff work lane (north) and the bypass lane (south).
	b.body("PumpBank", Vector3(7.0, 1.7, 1.2), Vector3(18.5, Y_M + 0.85, -7.0), mats.get_material("machine"))
	for i in 4:
		b.visual("PumpMotor_%02d" % i, Vector3(0.9, 0.5, 0.9), Vector3(15.8 + i * 1.8, Y_M + 1.95, -7.0), mats.get_material("pipe"), true)
		pump_lamps.append(b.visual("PumpLamp_%02d" % i, Vector3(0.14, 0.08, 0.04), Vector3(15.8 + i * 1.8, Y_M + 1.2, -6.38), b.flat(Color(0.2, 0.2, 0.2), 0.4), false))
	# O2: displaced pipe rack near S2 (low, 1.2 m): obstacle and partial cover.
	b.body("O2PipeRack", Vector3(2.0, 1.2, 0.8), Vector3(13.2, Y_M + 0.6, -6.8), mats.get_material("steel"))
	b.visual("O2PipeA", Vector3(2.1, 0.12, 0.12), Vector3(13.2, Y_M + 1.25, -6.65), mats.get_material("pipe"), true)
	# Staff work panels on the north wall and the staff refuge (office door, north-east).
	b.visual("PumpPanelA", Vector3(1.2, 1.4, 0.15), Vector3(16.5, Y_M + 1.1, -9.9), mats.get_material("screen_dark"), true)
	b.visual("PumpPanelB", Vector3(1.2, 1.4, 0.15), Vector3(21.5, Y_M + 1.1, -9.9), mats.get_material("screen_dark"), true)
	b.screen_text("PumpPanelAText", "BOMBEO B-1\nPRESIÓN 2,4 bar", Vector3(16.5, Y_M + 1.3, -9.8), "+z", 18)
	b.screen_text("PumpPanelBText", "BOMBEO B-2\nPRESIÓN 2,1 bar", Vector3(21.5, Y_M + 1.3, -9.8), "+z", 18)
	b.visual("StaffRefugeDoor", Vector3(1.4, 2.3, 0.1), Vector3(28.6, Y_M + 1.15, -9.95), mats.get_material("locker"), true)
	b.paint_sign("StaffRefugeSign", "OFICINA DE TURNO", Vector3(28.6, Y_M + 2.5, -9.88), "+z", 26)


# --- S2: M (+3, west foot) -> P2 walkway (+6, east head) ------------------------------------------------------------

func _s2() -> void:
	b.wedge("S2Stair", Vector3(9.0, Y_M, -3.0), Vector3(13.5, Y_P2, -3.0), 3.0, Y_M)
	b.sloped_rail("S2RailSouth", Vector3(9.0, Y_M, -1.55), Vector3(13.5, Y_P2, -1.55))
	b.paint_sign("S2Sign", "S2  ↑  CONTROL", Vector3(8.25, Y_M + 0.02, -5.4), "floor", 40)


# --- P2: archive F, control E, airlock G, observation walkway ------------------------------------------------------

func _p2() -> void:
	b.slab("UpperFloorFG", Rect2(0.0, -10.0, 9.0, 5.5), Y_P2)
	b.slab("ControlRoomFloor", Rect2(9.0, -10.0, 15.0, 5.5), Y_P2)
	b.slab("ObservationWalkway", Rect2(13.5, -4.5, 11.0, 3.0), Y_P2, mats.get_material("grate"))
	# Walls of the upper rooms.
	b.wall_z("UpperSouthWallFG", -4.65, 0.0, 9.0, Y_P2, TOP)
	b.wall_x("ArchiveControlPierNorth", 9.0, -10.0, -8.0, Y_P2, TOP)
	b.wall_x("ArchiveControlPierSouth", 9.0, -5.6, -4.5, Y_P2, TOP)
	b.wall_x("ArchiveControlLintel", 9.0, -8.0, -5.6, Y_P2 + 2.3, TOP)
	b.wall_x("AirlockArchivePierNorth", 3.0, -10.0, -8.0, Y_P2, TOP)
	b.wall_x("AirlockArchivePierSouth", 3.0, -6.5, -4.5, Y_P2, TOP)
	b.wall_x("AirlockArchiveLintel", 3.0, -8.0, -6.5, Y_P2 + 2.2, TOP)
	b.wall_z("ControlNorthWall", -8.5, 9.0, 24.0, Y_P2, TOP)
	# Rails: E over S2, E east edge, walkway south and shaft edges.
	b.rail_x("ControlRailOverS2", 9.0, 13.5, -4.45, Y_P2)
	b.rail_z("ControlRailEast", -8.35, -4.5, 24.05, Y_P2)
	b.rail_x("WalkwayRailSouth", 13.5, 24.5, -1.55, Y_P2)
	b.rail_z("WalkwayRailShaft", -4.5, -1.5, 24.55, Y_P2)
	b.paint_sign("ControlLabel", "E  ·  CONTROL Y DIAGNÓSTICO", Vector3(16.0, Y_P2 + 0.02, -5.4), "floor", 44)
	b.paint_sign("ArchiveLabel", "F  ·  ARCHIVO RESTRINGIDO", Vector3(6.0, Y_P2 + 0.02, -5.4), "floor", 40)
	b.paint_sign("AirlockLabel", "G  ·  ESCLUSA", Vector3(1.5, Y_P2 + 0.02, -5.4), "floor", 44)
	# E controls (contract centres shifted by the +3 m datum change): selector, isolator, panel, rearm.
	b.visual("SelectorBody", Vector3(0.6, 1.1, 0.4), SELECTOR_AT + Vector3(0.0, 0.55, -0.45), mats.get_material("steel_light"), true)
	b.paint_sign("SelectorLabel", "SELECTOR DE RECUPERACIÓN\nENSAYO · ARCHIVO", SELECTOR_AT + Vector3(0.0, 1.35, -0.24), "+z", 22, Color(0.95, 0.75, 0.35))
	b.visual("IsolatorBody", Vector3(0.6, 1.1, 0.4), ISOLATOR_AT + Vector3(0.0, 0.55, -0.45), mats.get_material("steel_light"), true)
	b.paint_sign("IsolatorLabel", "AISLADOR  ·  RAMA ENSAYO", ISOLATOR_AT + Vector3(0.0, 1.35, -0.24), "+z", 22, Color(0.95, 0.75, 0.35))
	b.visual("EStatusPanelBoard", Vector3(2.8, 1.3, 0.12), PANEL_AT, mats.get_material("screen_dark"), false)
	panel_text = b.screen_text("EStatusPanelText", "", PANEL_AT + Vector3(0.0, 0.0, 0.08), "+z", 20)
	b.visual("RearmButtonBody", Vector3(0.5, 0.9, 0.3), REARM_AT + Vector3(0.0, 0.45, -0.5), b.flat(Color(0.2, 0.42, 0.28), 0.5), true)
	b.paint_sign("RearmLabel", "REARME DE PROTECCIÓN", REARM_AT + Vector3(0.0, 1.05, -0.34), "+z", 20)
	indicator_text = b.screen_text("IndicatorText", "", Vector3(15.5, Y_P2 + 0.95, -7.25), "+z", 18, Color(0.9, 0.8, 0.5))
	# F: archive console and diagnostic terminal (always on emergency supply).
	b.visual("ArchiveConsole", Vector3(1.0, 1.0, 0.5), ARCHIVE_AT + Vector3(0.0, 0.5, -0.55), mats.get_material("steel"), true)
	archive_text = b.screen_text("ArchiveStatusText", "", ARCHIVE_AT + Vector3(0.0, 1.25, -0.28), "+z", 20)
	b.visual("DiagnosticTerminal", Vector3(0.4, 1.1, 0.7), DIAGNOSTIC_AT + Vector3(-0.55, 0.55, 0.0), mats.get_material("steel_light"), true)
	b.paint_sign("DiagnosticLabel", "DIAGNÓSTICO\n(EMERGENCIA)", DIAGNOSTIC_AT + Vector3(-0.33, 1.3, 0.0), "+x", 20)
	# O1: archive shelving, upright against the north wall until Containment knocks it over.
	o1_shelf = b.body("O1ArchiveShelf", Vector3(1.0, 2.2, 0.45), Vector3(8.0, Y_P2 + 1.1, -9.6), mats.get_material("locker"))
	# G airlock: inner leaf (to F) and outer leaf (to the exterior gantry).
	g_inner_door = b.body("GInnerDoor", Vector3(0.12, 2.2, 1.5), Vector3(3.0, Y_P2 + 1.1, -7.25), mats.get_material("safety_paint"))
	g_outer_door = b.body("GOuterDoor", Vector3(0.12, 2.2, 1.5), Vector3(-0.15, Y_P2 + 1.1, -7.5), mats.get_material("steel_light"))
	g_status_lamp = b.visual("GStatusLamp", Vector3(0.08, 0.12, 0.6), Vector3(0.05, Y_P2 + 2.45, -7.5), b.flat(Color(0.95, 0.2, 0.1), 0.4, 0.0, 1.6), false)
	b.paint_sign("GOuterSign", "COMPUERTA EXTERIOR\nSOLO PERSONAL AUTORIZADO", Vector3(0.05, Y_P2 + 2.9, -7.5), "+x", 20, Color(1.0, 0.8, 0.4))


# --- exterior gantry beyond G (where the recovery unit approaches) -------------------------------------------------

func _gantry() -> void:
	b.slab("ExteriorGantry", Rect2(-12.0, -8.5, 12.0, 2.0), Y_P2, mats.get_material("grate"), 0.3)
	b.rail_x("GantryRailNorth", -12.0, -0.3, -8.55, Y_P2)
	b.rail_x("GantryRailSouth", -12.0, -0.3, -6.45, Y_P2)
	b.body("ServiceTower", Vector3(3.0, 9.4, 6.0), Vector3(-13.5, 4.7, -7.5), mats.get_material("bulkhead"))
	gantry_door = b.visual("ServiceTowerDoor", Vector3(0.1, 2.3, 1.6), Vector3(-11.97, Y_P2 + 1.15, -7.5), mats.get_material("steel_light"), false)
	for x in [-10.0, -5.0]:
		b.visual("GantryColumn_%d" % int(-x), Vector3(0.3, Y_P2, 0.3), Vector3(x, Y_P2 * 0.5, -7.5), mats.get_material("steel"), true)


# --- lift landings (the lift component brings its own deck, deck gates and rails) -----------------------------------

func _lift_landings() -> void:
	b.slab("LiftPitFloor", SHAFT, -0.6, mats.get_material("steel"))
	b.wall_z("LiftPitWallNorth", -4.65, 24.2, 27.8, -0.85, -0.25)
	b.wall_z("LiftPitWallSouth", -1.35, 24.2, 27.8, -0.85, -0.25)
	b.wall_x("LiftPitWallWest", 24.35, -4.5, -1.5, -0.85, -0.25)
	b.wall_x("LiftPitWallEast", 27.65, -4.5, -1.5, -0.85, -0.25)
	lift_gate_lower = b.body("LiftSafetyGateLower", Vector3(3.0, RAIL, 0.12), Vector3(26.0, Y_P0 + RAIL * 0.5, -1.44), mats.get_material("safety_paint"), Builder.LAYER_NO_MANTLE)
	lift_gate_upper = b.body("LiftSafetyGateUpper", Vector3(3.0, RAIL, 0.12), Vector3(26.0, Y_M + RAIL * 0.5, -4.56), mats.get_material("safety_paint"), Builder.LAYER_NO_MANTLE)
	for side in [24.45, 27.55]:
		b.rail_z("LiftShaftRailP0_%d" % int(side * 10), -4.5, -1.5, side, Y_P0)
		b.rail_z("LiftShaftRailM_%d" % int(side * 10), -4.5, -1.5, side, Y_M)
	b.visual("LiftCallP0Box", Vector3(0.3, 0.45, 0.12), LIFT_CALL_P0_AT + Vector3(0.0, 1.2, 0.0), mats.get_material("steel_light"), false)
	b.visual("LiftCallMBox", Vector3(0.3, 0.45, 0.12), LIFT_CALL_M_AT + Vector3(0.0, 1.2, 0.0), mats.get_material("steel_light"), false)
	b.paint_sign("LiftSignP0", "ELEVADOR  P0 ↔ M", Vector3(26.0, Y_P0 + 2.3, -1.38), "+z", 36)
	b.paint_sign("LiftSignM", "ELEVADOR  M ↔ P0", Vector3(26.0, Y_M + 2.3, -4.62), "-z", 36)


# --- the Aster calibration column: landmark through all levels; its rings show circuit state --------------------

func _column() -> void:
	b.body("AsterVerticalColumn", Vector3(0.58, TOP, 0.58), Vector3(14.5, TOP * 0.5, -3.0), mats.get_material("steel_light"))
	b.body("AsterColumnFooting", Vector3(1.2, 0.3, 1.2), Vector3(14.5, 0.15, -3.0), mats.get_material("steel"))
	for i in 3:
		column_rings.append(b.visual("AsterRing_%d" % i, Vector3(0.75, 0.12, 0.75), Vector3(14.5, 1.6 + i * 3.0, -3.0), b.flat(Color(0.15, 0.17, 0.18), 0.4, 0.3), false))
	b.paint_sign("AsterColumnLabel", "ASTER  ·  COLUMNA DE CALIBRACIÓN", Vector3(14.5, 2.4, -2.68), "+z", 30, Color(0.5, 0.9, 0.88))


# --- lighting: dim emergency base, maintenance circuit, alarm lights (off until Containment) ------------------------

func _lighting() -> void:
	b.light("NaveLight", Vector3(12.0, 4.2, -2.0), Color(0.72, 0.84, 0.95), 0.9, 12.0)
	b.light("AccessLight", Vector3(3.5, 2.4, 7.0), Color(1.0, 0.82, 0.62), 0.8, 7.0)
	b.light("WorkshopLight", Vector3(22.0, 2.3, -6.0), Color(0.9, 0.85, 0.7), 0.7, 6.0)
	b.light("SouthBandLight", Vector3(20.0, 2.6, 11.0), Color(0.72, 0.84, 0.95), 0.6, 9.0)
	b.light("ControlLight", Vector3(16.0, Y_P2 + 2.4, -6.5), Color(0.75, 0.88, 1.0), 0.9, 10.0)
	b.light("ArchiveLight", Vector3(5.0, Y_P2 + 2.3, -7.0), Color(0.75, 0.95, 0.9), 0.7, 6.0)
	b.light("PumpRoomEmergency", Vector3(18.0, Y_M + 2.3, -5.5), Color(0.75, 0.85, 1.0), 0.45, 9.0)
	for spec in [["PitServiceLight", Vector3(15.0, -0.4, 4.5), 10.0], ["D2ServiceLight", Vector3(24.0, -0.4, 4.0), 7.0], ["PumpServiceLight", Vector3(22.0, Y_M + 2.3, -6.5), 9.0], ["LiftServiceLight", Vector3(26.0, 2.4, 0.0), 6.0]]:
		var l: OmniLight3D = b.light(spec[0], spec[1], Color(0.8, 0.9, 1.0), 0.12, spec[2])
		service_lights.append(l)
	for spec in [["AlarmG", Vector3(1.5, Y_P2 + 2.5, -7.0)], ["AlarmM", Vector3(20.0, Y_M + 2.4, -8.5)], ["AlarmP0", Vector3(27.0, 2.4, 0.5)], ["AlarmPit", Vector3(20.0, -0.5, 7.0)]]:
		var a: OmniLight3D = b.light(spec[0], spec[1], Color(1.0, 0.15, 0.1), 0.0, 9.0)
		a.visible = false
		alarm_lights.append(a)
