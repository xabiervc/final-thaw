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
const Parking := preload("res://scripts/phase2/phase2_parking.gd")
const Art := preload("res://scripts/phase1/phase1_art.gd")
const Expansion := preload("res://scripts/phase1/phase1_expansion.gd")

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
const MOUTH_X := 34.0
const BRIDGE_DECK := 0.35
## R1 shutter centre heights: raised (open, hidden in the lintel box) and closed (resting on the floor).
const R1_OPEN_Y := 3.5
const R1_CLOSED_Y := 1.15
const R1_CRANK_AT := Vector3(29.4, 0.0, 0.3)

# Concealed entry (v5, 2026-10-15): a walled flood channel west of the station, a breached storm culvert under a
# road grating, the old inspection tunnel. The culvert's last stretch collapses once Elena is through.
const CHANNEL := Rect2(-13.5, -2.0, 4.0, 22.0)  # x -13.5..-9.5, z -2..20
const CHANNEL_FLOOR := -1.0
const BANK_TOP := 1.6
const CULVERT_X0 := -9.5
const CULVERT_X1 := -3.3
const CULVERT_Z := Vector2(5.3, 6.7)
const CULVERT_TOP := 1.25
## Debris zone of the collapse (x range): the culvert's shallow last stretch under the road, next to the tunnel.
const COLLAPSE_X := Vector2(-5.4, -3.35)
## Where play starts after the intro: in the channel, the breached culvert mouth ahead to the north-east.
const ENTRY_START := Vector3(-11.5, CHANNEL_FLOOR, 9.6)
## Crossing this x inside the tunnel means Elena is through the culvert (the collapse fires behind her).
const ENTRY_THROUGH_X := -2.75
## Evacuation gallery egress door (maglock released only by the evacuation alarm, i.e. Containment).
const EGRESS_DOOR_X := 31.2
const EGRESS_PANEL_AT := Vector3(30.6, -2.0, 4.9)

# Interaction anchors used by the scene script.
const MAINTENANCE_AT := Vector3(26.4, -2.0, 2.2)
const SCHEMATIC_AT := Vector3(27.3, -2.0, 2.9)
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
## Environment art layer (scripts/phase1/phase1_art.gd): what the player sees beyond the layout.
var art = null
## The expanded facility (scripts/phase1/phase1_expansion.gd): shift rooms on P0, the stair and the whole of P-2.
var expansion = null

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
## Phase 2 service yard, built in the same pass (same builder, same static batches).
var parking = null
var r1_shutter: StaticBody3D
## Entry collapse: the blocker (collision off until the collapse), the grating section that falls and the debris pieces
## (each with its rest transform; the scene animates them into place).
var entry_blocker: StaticBody3D
var entry_grate_falls: Node3D
var entry_debris: Array[MeshInstance3D] = []
var entry_debris_rest: Array[Transform3D] = []
var entry_dust: CPUParticles3D
## Evacuation egress door (slides open on Containment) and its maglock lamp.
var egress_door: StaticBody3D
var egress_lamp: MeshInstance3D
var r1_beacon: MeshInstance3D
var gantry_door: MeshInstance3D


func _init(root: Node3D, materials) -> void:
	mats = materials
	b = Builder.new(root, materials)


func build() -> void:
	_shell()
	_entry()
	_p0()
	_pit()
	_east_bridge_and_gallery()
	parking = Parking.new(b, mats, b.root)
	parking.build()
	_mezzanine()
	_s2()
	_p2()
	_gantry()
	_lift_landings()
	_column()
	expansion = Expansion.new(b, mats)
	expansion.build()
	_lighting()
	art = Art.new(b, mats)
	art.build()
	b.flush()


# --- shell ------------------------------------------------------------------------------------------------------

func _shell() -> void:
	var wall: Material = mats.get_material("st_wall")
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
	# Exterior skin: roofs and the step between the tall north block and the low south block, seen only from
	# outside (intro establishing shot, the street). Single-sided, no collision, no shadow.
	var roof: Material = mats.get_material("st_roof")
	b.exterior_skin("RoofNorthBlock", Vector2(30.6, 8.8), Vector3(15.0, TOP, -5.9), "+y", roof)
	# Low wings (aisles) around the raised pump hall (x 6.85..28.15, z -1.5..8.3, roofed by phase1_art.gd).
	b.exterior_skin("RoofWestWing", Vector2(7.15, 15.3), Vector3(3.275, LOW_TOP, 6.15), "+y", roof)
	b.exterior_skin("RoofSouthWing", Vector2(23.45, 5.5), Vector3(18.575, LOW_TOP, 11.05), "+y", roof)
	b.exterior_skin("RoofEastWing", Vector2(2.15, 9.8), Vector3(29.225, LOW_TOP, 3.4), "+y", roof)
	b.exterior_skin("RoofStepFaceWest", Vector2(7.15, TOP - LOW_TOP), Vector3(3.275, (TOP + LOW_TOP) * 0.5, -1.5), "+z", mats.get_material("st_brick_outside"))
	b.exterior_skin("RoofStepFaceEast", Vector2(2.15, TOP - LOW_TOP), Vector3(29.225, (TOP + LOW_TOP) * 0.5, -1.5), "+z", mats.get_material("st_brick_outside"))
	b.exterior_skin("WestUpperInfill", Vector2(3.0, TOP - LOW_TOP), Vector3(-0.31, (TOP + LOW_TOP) * 0.5, -3.0), "-x", mats.get_material("st_brick_outside"))
	# Visual roof framing over the tall block (no collision: the camera orbits freely inside).
	for i in 6:
		b.visual("RoofBeam_%02d" % i, Vector3(0.22, 0.35, 10.0), Vector3(2.5 + i * 5.0, TOP - 0.2, -5.0), mats.get_material("steel"), true)


# --- P0: entry, nave, workshop, service gallery, south band --------------------------------------------------

func _p0() -> void:
	b.slab_with_holes("GroundFloor", Rect2(0.0, -10.0, 30.0, 23.5), [PIT, S1_WELL, SHAFT, BRIDGE_CUT] + Expansion.floor_holes(), Y_P0, mats.get_material("st_floor_painted"))
	# Entry tunnel X -3..0: floor, side walls, ceiling and a closed security gate behind the spawn.
	b.slab("AccessTunnelFloor", Rect2(-3.0, 4.5, 3.0, 3.0), Y_P0, mats.get_material("st_floor_damaged"))
	b.wall_z("AccessTunnelSouth", 4.35, -3.3, 0.0, 0.0, 2.65, mats.get_material("st_concrete"))
	b.wall_z("AccessTunnelNorth", 7.65, -3.3, 0.0, 0.0, 2.65, mats.get_material("st_concrete"))
	b.slab("AccessTunnelCeiling", Rect2(-3.3, 4.2, 3.3, 3.6), 2.65, mats.get_material("st_concrete"))
	# Culvert headwall at the tunnel's west end: the culvert (z 5.3..6.7, 1.25 m high) comes through it.
	b.wall_x("CulvertHeadwallSouth", -3.15, 4.5, CULVERT_Z.x, 0.0, 2.65, mats.get_material("st_concrete"))
	b.wall_x("CulvertHeadwallNorth", -3.15, CULVERT_Z.y, 7.5, 0.0, 2.65, mats.get_material("st_concrete"))
	b.wall_x("CulvertHeadwallLintel", -3.15, CULVERT_Z.x, CULVERT_Z.y, CULVERT_TOP, 2.65, mats.get_material("st_concrete"))
	b.paint_sign("AccessTunnelSign", "CÁMARA DE REGISTRO  ·  COLECTOR C-2", Vector3(-0.2, 1.9, 6.0), "-x", 36)
	b.paint_sign("CulvertPlate", "C-2  ·  ALIVIADERO\nNO ENTRAR SIN PERMISO", Vector3(-2.98, 1.7, 6.0), "+x", 24, Color(0.85, 0.82, 0.7))
	# A/B threshold piers and lintel.
	b.wall_x("AccessNavePierSouth", 7.0, 4.0, 5.6, 0.0, 3.2, mats.get_material("st_wall"))
	b.wall_x("AccessNavePierNorth", 7.0, 8.4, 10.0, 0.0, 3.2, mats.get_material("st_wall"))
	b.wall_x("AccessNaveLintel", 7.0, 5.6, 8.4, 2.8, 3.2, mats.get_material("st_wall"))
	b.paint_sign("AccessLabel", "A  ·  ESCLUSA DE ACCESO", Vector3(3.5, 0.02, 8.6), "floor", 54)
	b.paint_sign("AccessEvacPlan", "PLAN DE EVACUACIÓN\nRUTA ESTE  →  FOSO  →  GALERÍA DE DESCARGA", Vector3(0.05, 1.6, 9.0), "+x", 30)
	# B/C partition under M (2.75 m clear), with a service doorway.
	b.wall_x("NaveWorkshopPierNorth", 20.0, -10.0, -7.2, 0.0, Y_M - 0.25, mats.get_material("st_wall"))
	b.wall_x("NaveWorkshopPierSouth", 20.0, -4.8, -2.0, 0.0, Y_M - 0.25, mats.get_material("st_wall"))
	b.wall_x("NaveWorkshopLintel", 20.0, -7.2, -4.8, 2.3, Y_M - 0.25, mats.get_material("st_wall"))
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
	var stair: MeshInstance3D = b.visual("BrokenApproachStairVisual", Vector3(2.0, 0.22, 4.95), Vector3(3.0, 4.25, -1.25), mats.get_material("st_tread"), true)
	stair.rotation.x = atan2(3.5, 3.5)
	b.body("BrokenStairRubble", Vector3(2.2, 0.9, 2.4), Vector3(3.0, 0.45, 1.8), mats.get_material("st_rubble"))
	b.visual("BrokenStairRubbleSlab", Vector3(1.9, 0.18, 2.6), Vector3(3.1, 0.95, 1.6), mats.get_material("st_tread"), true).rotation = Vector3(0.35, 0.2, 0.1)
	b.paint_sign("BrokenStairSign", "ESCALERA COLAPSADA  ·  NO PASAR", Vector3(3.0, 1.5, 3.02), "+z", 34, Color(1.0, 0.7, 0.3))


# --- P-1: pit, S1, maintenance and the tampered bridge ------------------------------------------------------------

func _pit() -> void:
	b.slab("PitFloor", PIT, Y_P1, mats.get_material("st_floor_damaged"))
	# Retaining walls between the pit floor and the P0 slab (no hidden void under the floor edge).
	b.wall_z("PitWallNorth", 0.85, 9.7, 28.3, Y_P1, -0.25, mats.get_material("st_concrete"))
	b.wall_z("PitWallSouthWest", 8.15, 9.7, 23.85, Y_P1, -0.25, mats.get_material("st_concrete"))
	b.wall_z("PitWallSouthEast", 8.15, 26.15, 28.3, Y_P1, -0.25, mats.get_material("st_concrete"))
	b.wall_x("PitWallWest", 9.85, 1.0, 8.0, Y_P1, -0.25, mats.get_material("st_concrete"))
	b.wall_x("PitWallEastNorth", 28.15, 1.0, 4.35, Y_P1, -0.25, mats.get_material("st_concrete"))
	b.wall_x("PitWallEastSouth", 28.15, 7.65, 8.0, Y_P1, -0.25, mats.get_material("st_concrete"))
	# S1: solid stair P0 (south, z = 11) -> P-1 (north, z = 8), walled well, guard rails on P0 around the well.
	b.wedge("S1Stair", Vector3(25.0, Y_P1, 8.0), Vector3(25.0, Y_P0, 11.0), 2.0, Y_P1 - 0.2, mats.get_material("st_concrete"))
	b.wall_x("S1WellWest", 23.85, 8.0, 11.0, Y_P1, -0.25, mats.get_material("st_concrete"))
	b.wall_x("S1WellEast", 26.15, 8.0, 11.0, Y_P1, -0.25, mats.get_material("st_concrete"))
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
	b.solid("D1PumpA", Vector3(1.0, 2.6, 1.0), Vector3(14.0, Y_P1 + 1.3, 2.0))  # drawn by phase1_art.gd (kit_pump)
	b.solid("D1PumpB", Vector3(1.0, 2.6, 1.0), Vector3(16.5, Y_P1 + 1.3, 2.0))
	b.body("D1Sump", Vector3(1.4, 0.2, 1.1), Vector3(12.2, Y_P1 + 0.1, 6.4), mats.get_material("steel"))
	b.paint_sign("D1Label", "D1  ·  ACHIQUE", Vector3(14.5, Y_P1 + 0.02, 5.0), "floor", 54)
	b.paint_sign("D1TideMark", "NIVEL MÁX. 14/03", Vector3(10.05, Y_P1 + 0.6, 4.0), "+x", 26, Color(0.85, 0.3, 0.25))
	b.paint_sign("D2Label", "D2  ·  DISTRIBUCIÓN", Vector3(23.0, Y_P1 + 0.02, 7.2), "floor", 48)
	# D2: intended-distribution schematic (east pit wall), tampered A->T bridge, maintenance switch.
	# On the east pit wall north of the gallery opening (Z 4.5..7.5 stays clear).
	b.static_visual(Vector3(0.1, 1.5, 2.3), Vector3(27.95, Y_P1 + 1.35, 2.9), mats.get_material("screen_dark"), false)  # SchematicBoard
	b.screen_text("SchematicDiagram", "ESQUEMA DE DISTRIBUCIÓN PREVISTA\n\nFUENTE AUXILIAR\n├ EMERGENCIA → DIAGNÓSTICO\n├ MANTENIMIENTO → LUCES / ELEVADOR\n└ PROTECCIÓN → SELECTOR\n      ├ ENSAYO → T\n      └ ARCHIVO → A", Vector3(27.88, Y_P1 + 1.37, 2.9), "-x", 26, Color(0.75, 0.92, 0.95))
	b.static_visual(Vector3(0.5, 0.7, 0.4), Vector3(20.2, Y_P1 + 0.35, 4.2), mats.get_material("steel_light"), true)  # BridgeTerminalA
	b.static_visual(Vector3(0.5, 0.7, 0.4), Vector3(22.8, Y_P1 + 0.35, 4.2), mats.get_material("steel_light"), true)  # BridgeTerminalT
	b.paint_sign("BridgeLabelA", "A", Vector3(20.2, Y_P1 + 0.8, 4.41), "+z", 64)
	b.paint_sign("BridgeLabelT", "T", Vector3(22.8, Y_P1 + 0.8, 4.41), "+z", 64)
	b.static_visual(Vector3(2.6, 0.09, 0.09), Vector3(21.5, Y_P1 + 0.62, 4.2), b.flat(Color(0.9, 0.42, 0.1), 0.45, 0.3, 0.6), false)  # TamperedBridge
	b.static_visual(Vector3(0.16, 0.16, 0.16), Vector3(20.45, Y_P1 + 0.62, 4.2), mats.get_material("steel"), false)  # TamperedBridgeClampA
	b.static_visual(Vector3(0.16, 0.16, 0.16), Vector3(22.55, Y_P1 + 0.62, 4.2), mats.get_material("steel"), false)  # TamperedBridgeClampT
	b.static_visual(Vector3(1.2, 0.01, 0.8), Vector3(21.5, Y_P1 + 0.01, 4.2), b.flat(Color(0.05, 0.04, 0.035), 0.95), false)  # BridgeScorch
	b.body("MaintenanceHousing", Vector3(0.7, 1.2, 0.4), Vector3(26.4, Y_P1 + 0.6, 1.4), mats.get_material("steel_light"))
	switch_lamp = b.visual("MaintenanceStatusLamp", Vector3(0.22, 0.12, 0.06), Vector3(26.4, Y_P1 + 1.05, 1.62), b.flat(Color(0.9, 0.2, 0.1), 0.35, 0.0, 1.3), false)
	b.paint_sign("MaintenanceLabel", "MANTENIMIENTO", Vector3(26.4, Y_P1 + 1.35, 1.61), "+z", 30)


# --- P0 east return, bridge over the evacuation gallery, gallery itself -------------------------------------------

func _east_bridge_and_gallery() -> void:
	# The east return corridor (X 28..30) bridges the gallery: ramps up 0.35 m so the gallery below keeps 2.23 m.
	b.wedge("EastReturnRampNorth", Vector3(29.0, Y_P0, 3.0), Vector3(29.0, BRIDGE_DECK, 4.5), 2.0, -0.25, mats.get_material("st_tread"), false)
	b.slab("EastReturnBridgeDeck", Rect2(28.0, 4.5, 2.0, 3.0), BRIDGE_DECK, mats.get_material("st_tread"), 0.12)
	b.wedge("EastReturnRampSouth", Vector3(29.0, Y_P0, 9.0), Vector3(29.0, BRIDGE_DECK, 7.5), 2.0, -0.25, mats.get_material("st_tread"), false)
	b.rail_z("EastReturnBridgeRail", 3.0, 8.05, 28.05, Y_P0, RAIL + BRIDGE_DECK + 0.1)
	b.paint_sign("EastReturnSign", "RETORNO ESTE", Vector3(29.0, 0.02, 1.7), "floor", 40)
	# R1: sector shutter between the service gallery and the east return. Raised (open) until Containment.
	b.wall_x("R1FrameWest", 28.0, 0.9, 1.2, 0.0, 2.6, mats.get_material("steel"))
	b.body("R1Lintel", Vector3(2.1, 0.3, 0.3), Vector3(29.0, 2.6, 1.05), mats.get_material("steel"))
	r1_shutter = b.body("R1Shutter", Vector3(1.9, 2.3, 0.1), Vector3(29.0, R1_OPEN_Y, 1.05), mats.get_material("steel_light"), 1, true, false)
	r1_beacon = b.visual("R1Beacon", Vector3(0.2, 0.12, 0.12), Vector3(29.0, 2.82, 0.88), b.flat(Color(0.2, 0.2, 0.2), 0.4), false)
	b.static_visual(Vector3(0.08, 0.45, 0.45), Vector3(29.85, 1.1, 0.35), mats.get_material("pipe_red"), false)  # R1CrankWheel
	b.paint_sign("R1CrankSign", "DESBLOQUEO\nDE EMERGENCIA", Vector3(29.84, 1.7, 0.35), "-x", 32, Color(1.0, 0.8, 0.4))
	# P-1 evacuation gallery X 28..34, Z 4.5..7.5, floor Y -2, 2.23 m clear, roofed, walled.
	b.slab("EvacGalleryFloor", GALLERY, Y_P1, mats.get_material("st_floor_damaged"))
	b.wall_z("EvacGalleryNorth", 4.35, 28.0, MOUTH_X, Y_P1, 0.23, mats.get_material("st_concrete"))
	b.wall_z("EvacGallerySouth", 7.65, 28.0, MOUTH_X, Y_P1, 0.23, mats.get_material("st_concrete"))
	b.slab("EvacGalleryRoof", Rect2(30.0, 4.2, MOUTH_X - 30.0, 3.6), 0.48, mats.get_material("st_concrete"))
	b.paint_sign("EvacGallerySign", "GALERÍA DE DESCARGA  →  SALIDA DE SERVICIO", Vector3(28.4, Y_P1 + 1.7, 4.52), "+z", 26, Color(0.4, 1.0, 0.55))
	b.static_visual(Vector3(5.6, 0.05, 0.05), Vector3(31.0, Y_P1 + 0.3, 4.53), b.flat(Color(0.3, 1.0, 0.45), 0.4, 0.0, 1.4), false)  # EvacGalleryStripN
	b.static_visual(Vector3(5.6, 0.05, 0.05), Vector3(31.0, Y_P1 + 0.3, 7.47), b.flat(Color(0.3, 1.0, 0.45), 0.4, 0.0, 1.4), false)  # EvacGalleryStripS
	b.light("EvacGalleryLight", Vector3(31.0, Y_P1 + 1.9, 6.0), Color(0.9, 0.45, 0.3), 0.9, 5.0, 0)
	_egress_door()


# --- M: pump room and observation, over the north block --------------------------------------------------------

func _mezzanine() -> void:
	b.slab("MezzanineFloor", Rect2(7.5, -10.0, 22.35, 5.5), Y_M, mats.get_material("st_tread"))
	# S2 landing (X 7.5..9) in front of the stair foot, plus the slab the solid stair stands on.
	b.slab("S2BaseSlab", Rect2(7.5, -4.5, 6.0, 3.0), Y_M, mats.get_material("st_tread"))
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
	b.static_visual(Vector3(2.1, 0.12, 0.12), Vector3(13.2, Y_M + 1.25, -6.65), mats.get_material("pipe"), true)  # O2PipeA
	# Staff work panels on the north wall and the staff refuge (office door, north-east).
	b.static_visual(Vector3(1.2, 1.4, 0.15), Vector3(16.5, Y_M + 1.1, -9.9), mats.get_material("screen_dark"), true)  # PumpPanelA
	b.static_visual(Vector3(1.2, 1.4, 0.15), Vector3(21.5, Y_M + 1.1, -9.9), mats.get_material("screen_dark"), true)  # PumpPanelB
	b.screen_text("PumpPanelAText", "BOMBEO B-1\nPRESIÓN 2,4 bar", Vector3(16.5, Y_M + 1.3, -9.8), "+z", 30)
	b.screen_text("PumpPanelBText", "BOMBEO B-2\nPRESIÓN 2,1 bar", Vector3(21.5, Y_M + 1.3, -9.8), "+z", 30)
	b.static_visual(Vector3(1.4, 2.3, 0.1), Vector3(28.6, Y_M + 1.15, -9.95), mats.get_material("locker"), true)  # StaffRefugeDoor
	b.paint_sign("StaffRefugeSign", "OFICINA DE TURNO", Vector3(28.6, Y_M + 2.5, -9.88), "+z", 26)


# --- S2: M (+3, west foot) -> P2 walkway (+6, east head) ------------------------------------------------------------

func _s2() -> void:
	b.wedge("S2Stair", Vector3(9.0, Y_M, -3.0), Vector3(13.5, Y_P2, -3.0), 3.0, Y_M, mats.get_material("st_tread"))
	b.sloped_rail("S2RailSouth", Vector3(9.0, Y_M, -1.55), Vector3(13.5, Y_P2, -1.55))
	b.paint_sign("S2Sign", "S2  ↑  CONTROL", Vector3(8.25, Y_M + 0.02, -5.4), "floor", 40)


# --- P2: archive F, control E, airlock G, observation walkway ------------------------------------------------------

func _p2() -> void:
	b.slab("UpperFloorFG", Rect2(0.0, -10.0, 9.0, 5.5), Y_P2, mats.get_material("helix_floor"))
	b.slab("ControlRoomFloor", Rect2(9.0, -10.0, 15.0, 5.5), Y_P2, mats.get_material("helix_floor"))
	b.slab("ObservationWalkway", Rect2(13.5, -4.5, 11.0, 3.0), Y_P2, mats.get_material("st_tread"))
	# Walls of the upper rooms.
	b.wall_z("UpperSouthWallFG", -4.65, 0.0, 9.0, Y_P2, TOP, mats.get_material("helix_panel"))
	b.wall_x("ArchiveControlPierNorth", 9.0, -10.0, -8.0, Y_P2, TOP, mats.get_material("helix_panel"))
	b.wall_x("ArchiveControlPierSouth", 9.0, -5.6, -4.5, Y_P2, TOP, mats.get_material("helix_panel"))
	b.wall_x("ArchiveControlLintel", 9.0, -8.0, -5.6, Y_P2 + 2.3, TOP, mats.get_material("helix_panel"))
	b.wall_x("AirlockArchivePierNorth", 3.0, -10.0, -8.0, Y_P2, TOP, mats.get_material("helix_panel"))
	b.wall_x("AirlockArchivePierSouth", 3.0, -6.5, -4.5, Y_P2, TOP, mats.get_material("helix_panel"))
	b.wall_x("AirlockArchiveLintel", 3.0, -8.0, -6.5, Y_P2 + 2.2, TOP, mats.get_material("helix_panel"))
	b.wall_z("ControlNorthWall", -8.5, 9.0, 24.0, Y_P2, TOP, mats.get_material("helix_panel"))
	# Rails: E over S2, E east edge, walkway south and shaft edges.
	b.rail_x("ControlRailOverS2", 9.0, 13.5, -4.45, Y_P2)
	b.rail_z("ControlRailEast", -8.35, -4.5, 24.05, Y_P2)
	b.rail_x("WalkwayRailSouth", 13.5, 24.5, -1.55, Y_P2)
	b.rail_z("WalkwayRailShaft", -4.5, -1.5, 24.55, Y_P2)
	b.paint_sign("ControlLabel", "E  ·  CONTROL Y DIAGNÓSTICO", Vector3(16.0, Y_P2 + 0.02, -5.4), "floor", 44)
	b.paint_sign("ArchiveLabel", "F  ·  ARCHIVO RESTRINGIDO", Vector3(6.0, Y_P2 + 0.02, -5.4), "floor", 40)
	b.paint_sign("AirlockLabel", "G  ·  ESCLUSA", Vector3(1.5, Y_P2 + 0.02, -5.4), "floor", 44)
	# E controls (contract centres shifted by the +3 m datum change): selector, isolator, panel, rearm.
	b.static_visual(Vector3(0.6, 1.1, 0.4), SELECTOR_AT + Vector3(0.0, 0.55, -0.45), mats.get_material("steel_light"), true)  # SelectorBody
	b.paint_sign("SelectorLabel", "SELECTOR\nENSAYO · ARCHIVO", SELECTOR_AT + Vector3(0.0, 1.4, -0.24), "+z", 40, Color(0.95, 0.75, 0.35))
	b.static_visual(Vector3(0.6, 1.1, 0.4), ISOLATOR_AT + Vector3(0.0, 0.55, -0.45), mats.get_material("steel_light"), true)  # IsolatorBody
	b.paint_sign("IsolatorLabel", "AISLADOR\nRAMA ENSAYO", ISOLATOR_AT + Vector3(0.0, 1.4, -0.24), "+z", 40, Color(0.95, 0.75, 0.35))
	b.static_visual(Vector3(2.8, 1.3, 0.12), PANEL_AT, mats.get_material("screen_dark"), false)  # EStatusPanelBoard
	panel_text = b.screen_text("EStatusPanelText", "", PANEL_AT + Vector3(0.0, 0.0, 0.08), "+z", 34)
	b.static_visual(Vector3(0.5, 0.9, 0.3), REARM_AT + Vector3(0.0, 0.45, -0.5), b.flat(Color(0.2, 0.42, 0.28), 0.5), true)  # RearmButtonBody
	b.paint_sign("RearmLabel", "REARME\nPROTECCIÓN", REARM_AT + Vector3(0.0, 1.15, -0.34), "+z", 36)
	indicator_text = b.screen_text("IndicatorText", "", Vector3(15.5, Y_P2 + 0.75, -8.3), "+z", 30, Color(0.9, 0.8, 0.5))
	# F: archive console and diagnostic terminal (always on emergency supply).
	b.static_visual(Vector3(1.0, 1.0, 0.5), ARCHIVE_AT + Vector3(0.0, 0.5, -0.55), mats.get_material("steel"), true)  # ArchiveConsole
	archive_text = b.screen_text("ArchiveStatusText", "", ARCHIVE_AT + Vector3(0.0, 1.25, -0.28), "+z", 32)
	b.static_visual(Vector3(0.4, 1.1, 0.7), DIAGNOSTIC_AT + Vector3(-0.55, 0.55, 0.0), mats.get_material("steel_light"), true)  # DiagnosticTerminal
	b.paint_sign("DiagnosticLabel", "DIAGNÓSTICO\n(EMERGENCIA)", DIAGNOSTIC_AT + Vector3(-0.33, 1.3, 0.0), "+x", 34)
	# The official test report, printed and left on the control desk: the claim the evidence contradicts.
	b.body("OfficialReportDesk", Vector3(1.2, 0.9, 0.6), Vector3(13.6, Y_P2 + 0.45, -8.1), mats.get_material("steel"))
	b.static_visual(Vector3(0.42, 0.012, 0.3), Vector3(13.5, Y_P2 + 0.906, -8.0), b.flat(Color(0.86, 0.85, 0.8), 0.9), false)  # report pages
	b.paint_sign("OfficialReportTitle", "INFORME OFICIAL
ENSAYO ASTER", Vector3(13.6, Y_P2 + 1.25, -8.38), "+z", 26, Color(0.9, 0.88, 0.8))
	# O1: archive shelving, upright against the north wall until Containment knocks it over.
	o1_shelf = b.body("O1ArchiveShelf", Vector3(1.0, 2.2, 0.45), Vector3(8.0, Y_P2 + 1.1, -9.6), mats.get_material("locker"), 1, true, false)
	# G airlock: inner leaf (to F) and outer leaf (to the exterior gantry).
	g_inner_door = b.body("GInnerDoor", Vector3(0.12, 2.2, 1.5), Vector3(3.0, Y_P2 + 1.1, -7.25), mats.get_material("safety_paint"), 1, true, false)
	g_outer_door = b.body("GOuterDoor", Vector3(0.12, 2.2, 1.5), Vector3(-0.15, Y_P2 + 1.1, -7.5), mats.get_material("steel_light"), 1, true, false)
	g_status_lamp = b.visual("GStatusLamp", Vector3(0.08, 0.12, 0.6), Vector3(0.05, Y_P2 + 2.45, -7.5), b.flat(Color(0.95, 0.2, 0.1), 0.4, 0.0, 1.6), false)
	b.paint_sign("GOuterSign", "COMPUERTA EXTERIOR\nSOLO PERSONAL AUTORIZADO", Vector3(0.05, Y_P2 + 2.6, -7.5), "+x", 30, Color(1.0, 0.8, 0.4))


# --- exterior gantry beyond G (where the recovery unit approaches) -------------------------------------------------

func _gantry() -> void:
	# Exterior ground west of the building (seen in the intro and from the gantry); the tunnel stays enclosed.
	# (The exterior ground west of the building is the embankment built in _entry.)
	for z in [-24.0, -12.0, 0.0, 12.0, 24.0]:
		b.static_visual(Vector3(0.08, 2.2, 12.0), Vector3(-30.0, BANK_TOP + 1.1, z), mats.get_material("fence"), false)
	b.static_visual(Vector3(0.15, 4.0, 0.15), Vector3(-6.0, BANK_TOP + 2.0, 9.4), mats.get_material("steel"), true)  # road lamp post
	b.static_visual(Vector3(0.7, 0.1, 0.3), Vector3(-5.7, BANK_TOP + 3.95, 9.4), b.flat(Color(1.0, 0.72, 0.42), 0.4, 0.0, 3.0), false)
	b.light("TunnelExteriorSodium", Vector3(-5.7, BANK_TOP + 3.7, 9.0), Color(1.0, 0.72, 0.42), 1.4, 7.5, Builder.YARD_BAND)
	b.light("GantryTowerLamp", Vector3(-11.6, Y_P2 + 2.6, -7.5), Color(0.8, 0.9, 1.0), 1.2, 9.0, 3)
	b.slab("ExteriorGantry", Rect2(-12.0, -8.5, 12.0, 2.0), Y_P2, mats.get_material("st_tread"), 0.3)
	b.rail_x("GantryRailNorth", -12.0, -0.3, -8.55, Y_P2)
	b.rail_x("GantryRailSouth", -12.0, -0.3, -6.45, Y_P2)
	b.body("ServiceTower", Vector3(3.0, 9.4, 6.0), Vector3(-13.5, 4.7, -7.5), mats.get_material("st_brick_outside"))
	gantry_door = b.visual("ServiceTowerDoor", Vector3(0.1, 2.3, 1.6), Vector3(-11.97, Y_P2 + 1.15, -7.5), mats.get_material("steel_light"), false)
	for x in [-10.0, -5.0]:
		b.visual("GantryColumn_%d" % int(-x), Vector3(0.3, Y_P2, 0.3), Vector3(x, Y_P2 * 0.5, -7.5), mats.get_material("steel"), true)


# --- concealed entry: flood channel, breached storm culvert, the collapse --------------------------------------------

func _entry() -> void:
	# Outdoors: built on the yard band, so the moon lights it on every graphics preset and interior lights never do.
	b.force_band = Builder.YARD_BAND
	var bank: Material = mats.get_material("asphalt")
	var lining: Material = mats.get_material("st_concrete_outside")
	var top := BANK_TOP
	var base := CHANNEL_FLOOR
	var cx0 := CHANNEL.position.x
	var cx1 := CHANNEL.end.x
	var cz0 := CHANNEL.position.y
	var cz1 := CHANNEL.end.y
	# Embankment (road level 1.6 m above the channel floor... 2.6 m of wall: nothing here can be climbed).
	_bank("BankWest", Rect2(-40.0, -30.0, cx0 - 0.4 + 40.0, 60.0), top, base, bank)
	_bank("BankNorthEnd", Rect2(cx0 - 0.4, -30.0, cx1 - cx0 + 0.8, cz0 + 30.0), top, base, bank)
	_bank("BankSouthEnd", Rect2(cx0 - 0.4, cz1, cx1 - cx0 + 0.8, 30.0 - cz1), top, base, bank)
	_bank("BankEastNorth", Rect2(cx1 + 0.4, -30.0, CULVERT_X1 - cx1 - 0.4, CULVERT_Z.x - 0.15 + 30.0), top, base, bank)
	_bank("BankEastSouth", Rect2(cx1 + 0.4, CULVERT_Z.y + 0.15, CULVERT_X1 - cx1 - 0.4, 30.0 - CULVERT_Z.y - 0.15), top, base, bank)
	_bank("BankTunnelNorth", Rect2(CULVERT_X1, -30.0, -0.3 - CULVERT_X1, 34.2), top, base, bank)
	_bank("BankTunnelSouth", Rect2(CULVERT_X1, 7.8, -0.3 - CULVERT_X1, 22.2), top, base, bank)
	# Channel: floor, concrete linings (west, and east around the culvert mouth), a weir with a trash rack at the north
	# end and a crushed pipe at the south end.
	b.slab("ChannelFloor", Rect2(cx0, cz0, cx1 - cx0, cz1 - cz0), base, mats.get_material("st_floor_damaged"), 0.5)
	b.body("ChannelLiningWest", Vector3(0.4, top - base, cz1 - cz0), Vector3(cx0 - 0.2, (top + base) * 0.5, (cz0 + cz1) * 0.5), lining)
	b.body("ChannelLiningEastSouth", Vector3(0.4, top - base, CULVERT_Z.x - cz0), Vector3(cx1 + 0.2, (top + base) * 0.5, (cz0 + CULVERT_Z.x) * 0.5), lining)
	b.body("ChannelLiningEastNorth", Vector3(0.4, top - base, cz1 - CULVERT_Z.y), Vector3(cx1 + 0.2, (top + base) * 0.5, (CULVERT_Z.y + cz1) * 0.5), lining)
	b.body("CulvertMouthLintel", Vector3(0.4, top - CULVERT_TOP, CULVERT_Z.y - CULVERT_Z.x), Vector3(cx1 + 0.2, (top + CULVERT_TOP) * 0.5, (CULVERT_Z.x + CULVERT_Z.y) * 0.5), lining)
	b.body("CulvertMouthSill", Vector3(0.4, -base, CULVERT_Z.y - CULVERT_Z.x), Vector3(cx1 + 0.2, base * 0.5, (CULVERT_Z.x + CULVERT_Z.y) * 0.5), lining)
	b.body("ChannelWeir", Vector3(cx1 - cx0, top - base, 0.5), Vector3((cx0 + cx1) * 0.5, (top + base) * 0.5, cz0 - 0.25), lining)
	for k in 9:  # trash rack bars in front of the weir
		b.static_visual(Vector3(0.04, top - base - 0.2, 0.04), Vector3(cx0 + 0.3 + k * 0.42, (top + base) * 0.5 - 0.1, cz0 + 0.25), mats.get_material("st_rust"), true)
	b.static_visual(Vector3(cx1 - cx0, 0.08, 0.08), Vector3((cx0 + cx1) * 0.5, top - 0.3, cz0 + 0.25), mats.get_material("st_rust"), false)
	b.body("ChannelSouthEnd", Vector3(cx1 - cx0, top - base, 0.5), Vector3((cx0 + cx1) * 0.5, (top + base) * 0.5, cz1 + 0.25), lining)
	b.static_visual(Vector3(cx1 - cx0 - 0.4, 1.4, 1.6), Vector3((cx0 + cx1) * 0.5, base + 0.5, cz1 - 0.6), mats.get_material("st_rubble"), true)  # silt and rubble
	# Rubble mound up to the culvert mouth (its floor is 1 m above the channel's): slopes on every side, so it can be
	# walked onto from anywhere (a wedge's vertical sides snag the player like a kerb).
	_rubble_mound(Vector3(cx1, 0.0, 6.0), base)
	# Storm culvert C-2 (x -9.1..-3.3): floor, walls to road level, a road grating as its roof (the grating stops Elena
	# from standing up but neither the camera nor sight lines: it sits on the no-mantle layer 5).
	b.slab("CulvertFloor", Rect2(cx1 + 0.4, CULVERT_Z.x - 0.15, CULVERT_X1 - cx1 - 0.4, CULVERT_Z.y - CULVERT_Z.x + 0.3), 0.0, mats.get_material("st_floor_damaged"), 1.0)
	b.body("CulvertWallSouth", Vector3(CULVERT_X1 - cx1 - 0.4, top, 0.15), Vector3((cx1 + 0.4 + CULVERT_X1) * 0.5, top * 0.5, CULVERT_Z.x - 0.075), lining)
	b.body("CulvertWallNorth", Vector3(CULVERT_X1 - cx1 - 0.4, top, 0.15), Vector3((cx1 + 0.4 + CULVERT_X1) * 0.5, top * 0.5, CULVERT_Z.y + 0.075), lining)
	var grate: Material = mats.get_material("fence")
	var standing := COLLAPSE_X.x - (cx1 + 0.4)
	b.body("CulvertGrating", Vector3(standing, 0.05, CULVERT_Z.y - CULVERT_Z.x), Vector3(cx1 + 0.4 + standing * 0.5, CULVERT_TOP + 0.025, (CULVERT_Z.x + CULVERT_Z.y) * 0.5), grate, Builder.LAYER_NO_MANTLE, false)
	for k in int(standing / 1.0) + 1:  # grating bearers
		b.static_visual(Vector3(0.06, 0.12, CULVERT_Z.y - CULVERT_Z.x + 0.3), Vector3(cx1 + 0.45 + k * 1.0, CULVERT_TOP - 0.03, (CULVERT_Z.x + CULVERT_Z.y) * 0.5), mats.get_material("st_rust"), false)
	# The grating section over the collapse zone: its own body, removed when it falls in.
	entry_grate_falls = b.body("CulvertGratingFalls", Vector3(COLLAPSE_X.y - COLLAPSE_X.x, 0.05, CULVERT_Z.y - CULVERT_Z.x), Vector3((COLLAPSE_X.x + COLLAPSE_X.y) * 0.5, CULVERT_TOP + 0.025, (CULVERT_Z.x + CULVERT_Z.y) * 0.5), grate, Builder.LAYER_NO_MANTLE, false, false)
	# The breach: the inspection grate at the culvert mouth, pried open and bent aside (it was locked).
	var bent: MeshInstance3D = b.visual("CulvertBreachGrate", Vector3(0.05, 1.15, 1.35), Vector3(cx1 + 0.55, 0.6, CULVERT_Z.x + 0.2), mats.get_material("st_rust"), true)
	bent.rotation = Vector3(0.12, -1.15, 0.08)
	b.static_visual(Vector3(0.1, 0.18, 0.1), Vector3(cx1 + 0.45, 0.55, CULVERT_Z.y - 0.05), mats.get_material("graphite"), false)  # sheared hasp
	b.paint_sign("CulvertMouthSign", "C-2", Vector3(cx1 + 0.02, 1.42, 6.0), "-x", 40, Color(0.8, 0.78, 0.7))
	_collapse_parts()
	b.force_band = -1


## The culvert's last stretch caves in behind Elena. `animate`: the debris drops in a staggered fall and the dust bursts
## (the scene adds the sound and the camera shake); otherwise the end state is applied at once (tests, skipped entry).
## Either way the blocker's collision is on and the fallen grating section is gone: the way in no longer exists.
func collapse_entry(animate: bool, host: Node) -> void:
	(entry_blocker.get_child(0) as CollisionShape3D).disabled = false
	entry_grate_falls.visible = false
	for child in entry_grate_falls.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).disabled = true
	for i in entry_debris.size():
		var m: MeshInstance3D = entry_debris[i]
		var rest: Transform3D = entry_debris_rest[i]
		m.visible = true
		if not animate:
			m.transform = rest
			continue
		var start := rest
		start.origin += Vector3(0.0, 1.7 + 0.35 * float(i % 3), 0.0)
		start.basis = rest.basis.rotated(Vector3(0.3, 1.0, 0.2).normalized(), 0.6 + 0.2 * float(i))
		m.transform = start
		var tw := host.create_tween()
		tw.tween_interval(0.07 * float(i))
		tw.tween_property(m, "transform", rest, 0.42 + 0.05 * float(i % 4)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if animate:
		entry_dust.restart()
		entry_dust.emitting = true


## Containment's evacuation alarm releases the maglock: the lamp turns green and the door swings open toward the yard.
func release_egress(host: Node, instant: bool = false) -> void:
	egress_lamp.material_override = b.flat(Color(0.3, 0.95, 0.45), 0.4, 0.0, 2.0)
	if egress_door.get_parent() == b.root:
		var hinge := Node3D.new()
		hinge.name = "EgressHinge"
		b.root.add_child(hinge)
		hinge.position = Vector3(EGRESS_DOOR_X, Y_P1, GALLERY.position.y + 0.4)
		egress_door.reparent(hinge, true)
	var hinge_node := egress_door.get_parent() as Node3D
	if instant:
		hinge_node.rotation.y = 1.75
	else:
		host.create_tween().tween_property(hinge_node, "rotation:y", 1.75, 1.2).set_delay(0.6).set_trans(Tween.TRANS_SINE)


## A rubble heap against the wall at x = mouth.x whose flat top meets the culvert sill: convex collision and the same
## triangles drawn in rubble. Slopes are ~30 degrees at most (walkable).
func _rubble_mound(mouth: Vector3, base: float) -> void:
	var t1 := Vector3(mouth.x, mouth.y, mouth.z - 0.6)
	var t2 := Vector3(mouth.x, mouth.y, mouth.z + 0.6)
	var t3 := Vector3(mouth.x - 0.7, mouth.y - 0.05, mouth.z)
	var ring := [Vector3(mouth.x, base, mouth.z - 2.3), Vector3(mouth.x - 1.1, base, mouth.z - 2.0), Vector3(mouth.x - 2.5, base, mouth.z - 1.2),
		Vector3(mouth.x - 3.2, base, mouth.z), Vector3(mouth.x - 2.5, base, mouth.z + 1.2), Vector3(mouth.x - 1.1, base, mouth.z + 2.0),
		Vector3(mouth.x, base, mouth.z + 2.3)]
	var body := StaticBody3D.new()
	body.name = "CulvertRubbleMound"
	body.collision_layer = Builder.LAYER_WORLD
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var hull := ConvexPolygonShape3D.new()
	hull.points = PackedVector3Array([t1, t2, t3] + ring)
	shape.shape = hull
	body.add_child(shape)
	b.root.add_child(body)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# top: t1 - t3 - t2; sides: fan from the top edge down to the ring
	for tri in [[t1, t3, t2]]:
		for v in tri:
			st.add_vertex(v)
	var tops := [t1, t1, t3, t3, t3, t2, t2]
	for i in range(ring.size() - 1):
		var a: Vector3 = ring[i]
		var c: Vector3 = ring[i + 1]
		var top: Vector3 = tops[i] if i < tops.size() else t2
		st.add_vertex(top)
		st.add_vertex(a)
		st.add_vertex(c)
		if i in [1, 4]:
			st.add_vertex(top)
			st.add_vertex(c)
			st.add_vertex(tops[i + 1])
	st.generate_normals()
	b.add_mesh_to_batch(st.commit(), Transform3D.IDENTITY, [mats.get_material("st_rubble")], true)


func _bank(label: String, rect: Rect2, top: float, base: float, material: Material) -> void:
	if rect.size.x <= 0.01 or rect.size.y <= 0.01:
		return
	b.body(label, Vector3(rect.size.x, top - base, rect.size.y), Vector3(rect.position.x + rect.size.x * 0.5, (top + base) * 0.5, rect.position.y + rect.size.y * 0.5), material)


## The collapse's end state, built now and hidden: a blocker that fills the culvert's last stretch (collision off until it
## falls), concrete and soil debris, the bent grating section, a sinkhole in the road and a dust burst. Deterministic: the
## same pieces land in the same places every time; the scene animates them falling from above.
func _collapse_parts() -> void:
	var zx := (COLLAPSE_X.x + COLLAPSE_X.y) * 0.5
	var zz := (CULVERT_Z.x + CULVERT_Z.y) * 0.5
	entry_blocker = b.solid("EntryCollapseBlocker", Vector3(COLLAPSE_X.y - COLLAPSE_X.x, BANK_TOP, CULVERT_Z.y - CULVERT_Z.x + 0.3), Vector3(zx, BANK_TOP * 0.5, zz))
	(entry_blocker.get_child(0) as CollisionShape3D).disabled = true
	var rubble: Material = mats.get_material("st_rubble")
	var concrete: Material = mats.get_material("st_concrete_outside")
	var soil: Material = mats.get_material("asphalt")
	var specs := [
		# size, rest position, rest rotation, material
		[Vector3(2.1, 0.9, 1.5), Vector3(zx, 0.42, zz), Vector3(0.05, 0.0, 0.08), rubble],
		[Vector3(1.4, 0.7, 1.2), Vector3(zx - 0.6, 0.95, zz + 0.1), Vector3(0.3, 0.4, -0.2), rubble],
		[Vector3(1.2, 0.18, 1.5), Vector3(zx + 0.3, 1.2, zz - 0.1), Vector3(0.0, 0.3, 0.55), concrete],
		[Vector3(0.9, 0.16, 1.1), Vector3(zx - 0.7, 1.35, zz - 0.2), Vector3(-0.4, -0.2, 0.3), concrete],
		[Vector3(0.6, 0.5, 0.6), Vector3(zx + 0.75, 0.3, zz + 0.45), Vector3(0.6, 0.2, 0.4), rubble],
		[Vector3(0.5, 0.4, 0.5), Vector3(COLLAPSE_X.y + 0.25, 0.2, zz - 0.4), Vector3(0.3, 0.9, 0.2), rubble],
		[Vector3(0.45, 0.35, 0.4), Vector3(COLLAPSE_X.y + 0.45, 0.17, zz + 0.35), Vector3(-0.5, 0.4, 0.1), rubble],
		[Vector3(2.0, 0.5, 1.9), Vector3(zx, 1.45, zz), Vector3(0.0, 0.0, 0.0), soil],
	]
	for i in specs.size():
		var spec: Array = specs[i]
		var m: MeshInstance3D = b.visual("EntryDebris_%02d" % i, spec[0], spec[1], spec[3], true)
		m.rotation = spec[2]
		entry_debris_rest.append(m.transform)
		m.visible = false
		entry_debris.append(m)
	# the fallen grating section, hanging into the hole at an angle
	var g: MeshInstance3D = b.visual("EntryDebrisGrate", Vector3(COLLAPSE_X.y - COLLAPSE_X.x, 0.05, CULVERT_Z.y - CULVERT_Z.x), Vector3(zx + 0.2, 1.05, zz), mats.get_material("fence"), false)
	g.rotation = Vector3(0.2, 0.1, 0.62)
	entry_debris_rest.append(g.transform)
	g.visible = false
	entry_debris.append(g)
	entry_dust = CPUParticles3D.new()
	entry_dust.name = "EntryCollapseDust"
	entry_dust.position = Vector3(COLLAPSE_X.y + 0.3, 0.9, zz)
	entry_dust.emitting = false
	entry_dust.one_shot = true
	entry_dust.amount = 36
	entry_dust.lifetime = 2.6
	entry_dust.explosiveness = 0.85
	entry_dust.direction = Vector3(1.0, 0.2, 0.0)
	entry_dust.spread = 55.0
	entry_dust.initial_velocity_min = 0.8
	entry_dust.initial_velocity_max = 2.6
	entry_dust.gravity = Vector3(0.0, -0.4, 0.0)
	entry_dust.damping_min = 0.6
	entry_dust.damping_max = 1.2
	entry_dust.scale_amount_min = 0.5
	entry_dust.scale_amount_max = 1.4
	var quad := QuadMesh.new()
	quad.size = Vector2(0.6, 0.6)
	var dust_mat := StandardMaterial3D.new()
	dust_mat.albedo_color = Color(0.55, 0.52, 0.48, 0.22)
	dust_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dust_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dust_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	dust_mat.vertex_color_use_as_albedo = true
	quad.material = dust_mat
	entry_dust.mesh = quad
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0.9))
	fade.set_color(1, Color(1, 1, 1, 0.0))
	entry_dust.color_ramp = fade
	b.root.add_child(entry_dust)


# --- evacuation egress: maglocked door in the gallery (released only by the evacuation alarm) --------------------------

func _egress_door() -> void:
	# A steel door with a wired-glass vision panel across the evacuation gallery: before the alarm it is held by a
	# magnetic lock (the yard and the way out are visible through the glass); Containment's alarm releases it.
	var x := EGRESS_DOOR_X
	b.wall_x("EgressFrameSouth", x, GALLERY.position.y, GALLERY.position.y + 0.4, Y_P1, 0.23, mats.get_material("st_concrete"))
	b.wall_x("EgressFrameNorth", x, GALLERY.end.y - 0.4, GALLERY.end.y, Y_P1, 0.23, mats.get_material("st_concrete"))
	b.static_visual(Vector3(0.3, 0.23 - (Y_P1 + 2.1), 2.2), Vector3(x, (0.23 + Y_P1 + 2.1) * 0.5, 6.0), mats.get_material("st_concrete"), true)
	egress_door = b.body("EgressDoor", Vector3(0.1, 2.1, 2.2), Vector3(x, Y_P1 + 1.05, 6.0), mats.get_material("st_green_steel_flat"), 1, true, false)
	var panel: MeshInstance3D = b.visual("EgressDoorWindow", Vector3(0.12, 0.6, 0.5), Vector3(0.0, 0.35, 0.0), mats.get_material("window_moon"), false)
	panel.reparent(egress_door, false)
	panel.position = Vector3(0.0, 0.35, 0.3)
	var bar: MeshInstance3D = b.visual("EgressDoorPushBar", Vector3(0.16, 0.06, 1.6), Vector3.ZERO, mats.get_material("steel_light"), false)
	bar.reparent(egress_door, false)
	bar.position = Vector3(-0.08, -0.05, 0.0)
	b.static_visual(Vector3(0.12, 0.12, 0.4), Vector3(x - 0.12, Y_P1 + 2.0, 6.0), mats.get_material("graphite"), false)  # maglock
	egress_lamp = b.visual("EgressMaglockLamp", Vector3(0.05, 0.06, 0.12), Vector3(x - 0.19, Y_P1 + 2.0, 6.0), b.flat(Color(0.95, 0.2, 0.1), 0.4, 0.0, 1.8), false)
	b.static_visual(Vector3(0.3, 0.4, 0.06), EGRESS_PANEL_AT + Vector3(0.0, 1.3, -0.35), mats.get_material("graphite"), false)
	b.paint_sign("EgressSign", "SALIDA DE EMERGENCIA\nDESBLOQUEO AUTOMÁTICO CON ALARMA", Vector3(x - 0.07, Y_P1 + 2.15, 6.0), "-x", 20, Color(0.45, 0.95, 0.6))


# --- lift landings (the lift component brings its own deck, deck gates and rails) -----------------------------------

func _lift_landings() -> void:
	b.slab("LiftPitFloor", SHAFT, -0.6, mats.get_material("steel"))
	b.wall_z("LiftPitWallNorth", -4.65, 24.2, 27.8, -0.85, -0.25, mats.get_material("st_concrete"))
	b.wall_z("LiftPitWallSouth", -1.35, 24.2, 27.8, -0.85, -0.25, mats.get_material("st_concrete"))
	b.wall_x("LiftPitWallWest", 24.35, -4.5, -1.5, -0.85, -0.25, mats.get_material("st_concrete"))
	b.wall_x("LiftPitWallEast", 27.65, -4.5, -1.5, -0.85, -0.25, mats.get_material("st_concrete"))
	lift_gate_lower = b.body("LiftSafetyGateLower", Vector3(3.0, RAIL, 0.12), Vector3(26.0, Y_P0 + RAIL * 0.5, -1.44), mats.get_material("safety_paint"), Builder.LAYER_NO_MANTLE, true, false)
	lift_gate_upper = b.body("LiftSafetyGateUpper", Vector3(3.0, RAIL, 0.12), Vector3(26.0, Y_M + RAIL * 0.5, -4.56), mats.get_material("safety_paint"), Builder.LAYER_NO_MANTLE, true, false)
	for side in [24.45, 27.55]:
		b.rail_z("LiftShaftRailP0_%d" % int(side * 10), -4.5, -1.5, side, Y_P0)
		b.rail_z("LiftShaftRailM_%d" % int(side * 10), -4.5, -1.5, side, Y_M)
	b.static_visual(Vector3(0.3, 0.45, 0.12), LIFT_CALL_P0_AT + Vector3(0.0, 1.2, 0.0), mats.get_material("steel_light"), false)  # LiftCallP0Box
	b.static_visual(Vector3(0.3, 0.45, 0.12), LIFT_CALL_M_AT + Vector3(0.0, 1.2, 0.0), mats.get_material("steel_light"), false)  # LiftCallMBox
	b.paint_sign("LiftSignP0", "ELEVADOR  P0 ↔ M", Vector3(26.0, Y_P0 + 2.3, -1.38), "+z", 36)
	b.paint_sign("LiftSignM", "ELEVADOR  M ↔ P0", Vector3(26.0, Y_M + 2.3, -4.62), "-z", 36)


# --- the Aster calibration column: landmark through all levels; its rings show circuit state --------------------

func _column() -> void:
	# Collision of the core and its plinth; the apparatus is drawn by phase1_art.gd.
	b.solid("AsterVerticalColumn", Vector3(0.62, TOP, 0.62), Vector3(14.5, TOP * 0.5, -3.0))
	b.solid("AsterColumnFooting", Vector3(1.5, 0.5, 1.5), Vector3(14.5, 0.25, -3.0))
	for i in 3:
		column_rings.append(b.visual("AsterRing_%d" % i, Vector3(0.75, 0.12, 0.75), Vector3(14.5, 1.6 + i * 3.0, -3.0), b.flat(Color(0.15, 0.17, 0.18), 0.4, 0.3), false))
	b.paint_sign("AsterColumnLabel", "ASTER  ·  COLUMNA DE CALIBRACIÓN", Vector3(14.5, 2.4, -2.68), "+z", 30, Color(0.5, 0.9, 0.88))


# --- lighting: dim emergency base, maintenance circuit, alarm lights (off until Containment) ------------------------

func _lighting() -> void:
	# Practical lights (fixtures drawn by phase1_art.gd): warm bulkheads and sodium on the old station, cool
	# fluorescent on the Helix insert and the pump gallery (docs/art/ASSET_PRODUCTION_BIBLE.md, "Lighting").
	b.light("NaveLight", Vector3(12.0, 4.2, -2.0), Color(1.0, 0.76, 0.5), 0.75, 9.0)
	b.light("AccessLight", Vector3(1.2, 2.5, 7.0), Color(1.0, 0.8, 0.56), 0.95, 7.5)
	b.light("WorkshopLight", Vector3(22.0, 2.4, -6.0), Color(0.96, 0.86, 0.68), 0.85, 6.5)
	b.light("SouthBandLight", Vector3(20.0, 3.9, 11.0), Color(0.85, 0.9, 0.95), 0.65, 8.0)
	b.light("ControlLight", Vector3(16.0, Y_P2 + 2.4, -6.5), Color(0.8, 0.9, 1.0), 0.85, 10.0)
	b.light("ArchiveLight", Vector3(5.0, Y_P2 + 2.3, -7.0), Color(0.72, 0.92, 0.9), 0.6, 6.0)
	b.light("PumpRoomEmergency", Vector3(18.0, Y_M + 2.3, -5.5), Color(0.82, 0.9, 0.98), 0.75, 10.0)
	b.light("PitEmergency", Vector3(20.0, -0.6, 4.5), Color(1.0, 0.68, 0.38), 0.8, 9.0)
	for spec in [["PitServiceLight", Vector3(15.0, -0.4, 4.5), 10.0], ["D2ServiceLight", Vector3(24.0, -0.4, 4.0), 7.0], ["PumpServiceLight", Vector3(22.0, Y_M + 2.3, -6.5), 9.0], ["LiftServiceLight", Vector3(26.0, 2.4, 0.0), 6.0]]:
		var l: OmniLight3D = b.light(spec[0], spec[1], Color(0.8, 0.9, 1.0), 0.0, spec[2])
		l.visible = false  # maintenance circuit: off until the switch is thrown
		service_lights.append(l)
	for spec in [["AlarmG", Vector3(1.5, Y_P2 + 2.5, -7.0)], ["AlarmM", Vector3(20.0, Y_M + 2.4, -8.5)], ["AlarmP0", Vector3(27.0, 2.4, 0.5)], ["AlarmPit", Vector3(20.0, -0.5, 7.0)]]:
		var a: OmniLight3D = b.light(spec[0], spec[1], Color(1.0, 0.15, 0.1), 0.0, 9.0)
		a.visible = false
		alarm_lights.append(a)
