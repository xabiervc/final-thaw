extends RefCounted
## Phase 2 set piece: the service yard ("aparcamiento de servicio") behind the P-1 east service mouth.
##
## Built in the same scene as the facility, so Elena runs out of the evacuation gallery straight into it with the
## recovery unit behind her: no scene change, no teleport, no state handoff.
## Layout (world metres, floor Y = -2, the LEVEL_STRUCTURE.md v0.3 concept fitted to the real building edge):
##   yard x 34..76, z -15.5..14; facade (west, x 34) with the 3 m service mouth at z 4.5..7.5;
##   north and south parking rows (covered fleet cars, bays 3 x 5 m) with column rows carrying overhead pipe racks;
##   central apron with cover: O1 service cart, a parked van, a stepped crate stack, the technical cage, O2 rack;
##   route A (south, short, lit, exposed) and route B (north lane, longer, darker, broken sightlines) converge
##   south of the egress enclosure; O3 = the stuck service gate leaving a fixed 1.3 m aperture into the enclosure;
##   the north gate: vehicle lane (boom barrier, closed by Containment) + fail-safe pedestrian emergency lane;
##   beyond it the exit ramp climbs to the street.
## Two facility devices let Elena make noise somewhere else (misdirection): the cage compressor (delayed start)
## and the dock 2 roller shutter (control by the mouth, shutter at the far south-east).
## Light pools define how exposed Elena is (the unit sees less far in the dark).

const Builder := preload("res://scripts/phase1/phase1_builder.gd")

const Y := -2.0
const X0 := 34.0
const X1 := 76.0
const Z0 := -15.5
const Z1 := 14.0
const WALL_H := 2.6
const MOUTH_Z := Vector2(4.5, 7.5)
const GATE_X0 := 69.6
const GATE_X1 := 73.2
const PED_X0 := 72.1  # pedestrian emergency lane x 72.1..73.2; vehicle lane 69.6..72.1 under the boom
const BOOM_BOTTOM := 1.15  # lowered boom: Elena can duck under it, nobody walks through it upright
const ENCLOSURE_X := 69.4
const BARRIER_Z := -0.8
const APERTURE := Vector2(72.3, 73.6)
const EXIT_Z := -16.6  # crossing the north wall line (its thickness included) ends Phase 2
const CAGE := Rect2(58.0, -4.4, 5.6, 3.5)
const COMPRESSOR_PANEL_AT := Vector3(57.7, Y, -2.6)
const COMPRESSOR_NOISE_AT := Vector3(60.8, Y, -2.6)
const DOCK_PANEL_AT := Vector3(34.5, Y, 10.4)
const DOCK_SHUTTER_AT := Vector3(62.5, Y, 13.6)
## The service camera over the mouth: when Elena comes out, Containment telemetry reports THIS place.
const MOUTH_CAMERA_REPORTS := Vector3(36.5, Y, 6.0)
const CAR_SIZE := Vector3(1.8, 1.42, 4.4)
const CAR_PATH := "res://assets/models/parking/covered_car/covered_car_1k.gltf"
const LIGHT_PATH := "res://assets/models/parking/security_light/security_light_1k.gltf"
const UTILITY_PATH := "res://assets/models/parking/utility_box_01/utility_box_01_1k.gltf"
const SHUTTER_PATH := "res://assets/models/parking/rollershutter_door/rollershutter_door_1k.gltf"
## Light pools: [x, z, radius, on_from_start]. The rest switch on when the facility responds (N2-05).
const POOLS := [
	[35.8, 6.0, 4.5, true],    # service mouth spill (cool)
	[47.0, -8.2, 6.0, true],   # north row sodium (dim, original yard lighting)
	[71.4, -14.6, 5.0, true],  # emergency exit lane (the landmark: green-white, always on, fail-safe)
	[41.5, 3.2, 7.0, false],   # floodlight 1: decision point
	[51.0, 5.0, 7.0, false],   # floodlight 2: route A
	[60.0, 5.5, 7.0, false],   # floodlight 3: route A
	[64.5, -7.4, 6.0, false],  # floodlight 4: route B east
	[73.0, -8.5, 6.0, false],  # floodlight 5: egress enclosure
]
const NORTH_CARS := [38.5, 44.5, 47.5, 53.5, 59.5, 62.5, 65.5]
const SOUTH_CARS := [38.5, 41.5, 47.5, 53.5, 56.5, 70.5, 73.5]
const COLUMN_X := [40.0, 46.0, 52.0, 58.0, 64.0]

var b = null
var mats = null
var root: Node3D = null

var pool_on: Array = []
var floodlights: Array[OmniLight3D] = []  # the response lights, in switch-on order
var flood_lamps: Array[MeshInstance3D] = []
var boom: StaticBody3D
var reader_mouth: Label3D
var reader_gate: Label3D
var dock_shutter: Node3D
var compressor_lamp: MeshInstance3D
var camera_led: MeshInstance3D
var dock_lamp: MeshInstance3D


func _init(builder, materials, parent: Node3D) -> void:
	b = builder
	mats = materials
	root = parent
	for p in POOLS:
		pool_on.append(bool(p[3]))


func build() -> void:
	b.force_band = Builder.YARD_BAND
	_ground_and_facade()
	_perimeter_and_gate()
	_rows()
	_apron_cover()
	_cage()
	_egress_enclosure()
	_beyond_the_wall()
	_lights()
	b.force_band = -1


# --- ground, facade ----------------------------------------------------------------------------------------------

func _ground_and_facade() -> void:
	b.slab("YardFloor", Rect2(X0, Z0, X1 - X0, Z1 - Z0), Y, mats.get_material("asphalt"))
	var wall: Material = mats.get_material("bulkhead")
	# Facade mass of the plant block between the building's east wall (30.3) and the yard (34); the gallery runs
	# through it at P-1 (z 4.2..7.8, roof at 0.48).
	b.body("YardFacadeNorth", Vector3(3.7, 6.5, 19.7), Vector3(32.15, Y + 3.25, -5.65), wall)
	b.body("YardFacadeSouth", Vector3(3.7, 6.5, 6.2), Vector3(32.15, Y + 3.25, 10.9), wall)
	b.body("YardFacadeOverMouth", Vector3(3.7, 4.02, 3.6), Vector3(32.15, 0.48 + 2.01, 6.0), wall)
	b.static_visual(Vector3(0.3, 0.3, 3.6), Vector3(34.1, 0.4, 6.0), mats.get_material("steel"), true)  # mouth lintel
	b.static_visual(Vector3(0.12, 0.08, 2.6), Vector3(34.12, 0.15, 6.0), b.flat(Color(0.75, 0.88, 1.0), 0.4, 0.0, 2.2), false)  # mouth lamp
	b.paint_sign("YardFacadeName", "HELIX  ·  CENTRO DE INVESTIGACIÓN HIDROLÓGICA B", Vector3(34.03, 2.6, -2.0), "+x", 64, Color(0.78, 0.8, 0.78))
	b.paint_sign("YardMouthSign", "SALIDA DE SERVICIO  ·  GALERÍA DE DESCARGA", Vector3(34.03, 0.9, 6.0), "+x", 30, Color(0.5, 1.0, 0.6))
	# Service camera over the mouth (it is what reports Elena's exit to Containment): housing, lens, status LED.
	b.static_visual(Vector3(0.5, 0.08, 0.08), Vector3(34.25, 0.62, 4.1), mats.get_material("steel"), false)
	b.static_visual(Vector3(0.38, 0.2, 0.22), Vector3(34.5, 0.5, 4.1), mats.get_material("steel_light"), true)
	camera_led = b.visual("MouthCameraLed", Vector3(0.05, 0.05, 0.05), Vector3(34.7, 0.47, 4.1), b.flat(GamePalette.color("ok"), 0.4, 0.0, 2.0), false)
	reader_mouth = b.screen_text("YardReaderMouth", "PROTOCOLO DE CONTENCIÓN: INACTIVO", Vector3(34.04, Y + 2.1, 8.6), "+x", 26, Color(0.6, 0.9, 0.7))
	# Dock 2 control panel on the facade, by the mouth (the shutter it drives is at the far south-east).
	b.static_visual(Vector3(0.18, 0.6, 0.45), DOCK_PANEL_AT + Vector3(-0.38, 1.3, 0.0), mats.get_material("steel_light"), true)
	dock_lamp = b.visual("DockPanelLamp", Vector3(0.05, 0.08, 0.16), DOCK_PANEL_AT + Vector3(-0.28, 1.5, 0.0), b.flat(GamePalette.color("ok"), 0.4, 0.0, 1.6), false)
	b.paint_sign("DockPanelSign", "MUELLE 2\nPERSIANA  ▲", DOCK_PANEL_AT + Vector3(-0.27, 1.85, 0.0), "+x", 22, Color(0.95, 0.82, 0.5))
	# Painted pedestrian walkway: the facility's own route to the emergency exit (north lane), not a game marker.
	for i in 12:
		b.static_visual(Vector3(0.5, 0.012, 1.4), Vector3(39.0 + i * 2.6, Y + 0.008, -6.6), mats.get_material("paint_line"), false)
	b.paint_sign("WalkwayLabel", "RUTA PEATONAL  →  SALIDA DE EMERGENCIA", Vector3(42.5, Y + 0.02, -5.2), "floor", 44, Color(0.85, 0.82, 0.6))
	b.paint_sign("ApronLabel", "ZONA DE MANIOBRA", Vector3(52.0, Y + 0.02, 0.6), "floor", 70, Color(0.7, 0.68, 0.5))


func _perimeter_and_gate() -> void:
	var wall: Material = mats.get_material("bulkhead")
	# Perimeter walls: 2.6 m, solid to sight, never climbable (no-mantle layer as well as world).
	for w in [
		b.wall_z("YardNorthWallWest", Z0 - 0.15, X0, GATE_X0 - 0.15, Y, Y + WALL_H, wall),
		b.wall_z("YardNorthWallEast", Z0 - 0.15, GATE_X1 + 0.15, X1 + 0.3, Y, Y + WALL_H, wall),
		b.wall_x("YardEastWall", X1 + 0.15, Z0 - 0.3, Z1 + 0.3, Y, Y + WALL_H, wall),
		b.wall_z("YardSouthWallWest", Z1 + 0.15, X0, DOCK_SHUTTER_AT.x - 1.5, Y, Y + WALL_H, wall),
		b.wall_z("YardSouthWallEast", Z1 + 0.15, DOCK_SHUTTER_AT.x + 1.5, X1 + 0.3, Y, Y + WALL_H, wall),
		b.wall_z("DockLintel", Z1 + 0.15, DOCK_SHUTTER_AT.x - 1.5, DOCK_SHUTTER_AT.x + 1.5, Y + 2.42, Y + WALL_H, wall),
	]:
		(w as StaticBody3D).collision_layer = 1 | Builder.LAYER_NO_MANTLE
	b.paint_sign("YardBayNumbers", "N-01        N-02        N-03        N-04        N-05        N-06        N-07        N-08        N-09        N-10", Vector3(53.5, Y + 1.7, Z0 + 0.02), "+z", 30, Color(0.7, 0.68, 0.55))
	# Gate posts, lane divider bollard, boom barrier housing and the boom (raised until Containment reaches the yard).
	b.body("GatePostWest", Vector3(0.4, 3.4, 0.6), Vector3(GATE_X0 - 0.2, Y + 1.7, Z0 - 0.15), mats.get_material("steel"))
	b.body("GatePostEast", Vector3(0.4, 3.4, 0.6), Vector3(GATE_X1 + 0.2, Y + 1.7, Z0 - 0.15), mats.get_material("steel"))
	b.body("GateLaneDivider", Vector3(0.22, 1.1, 0.4), Vector3(PED_X0, Y + 0.55, Z0 - 0.15), mats.get_material("safety_paint"))
	b.body("BoomHousing", Vector3(0.45, 1.1, 0.45), Vector3(GATE_X0 + 0.3, Y + 0.55, Z0 + 0.45), mats.get_material("safety_paint"))
	boom = b.body("BoomArm", Vector3(2.15, 0.1, 0.1), Vector3(GATE_X0 + 0.3 + 1.075, Y + BOOM_BOTTOM + 0.05, Z0 + 0.45), b.flat(Color(0.9, 0.85, 0.8), 0.6), 1, false, false)
	boom.position = Vector3(GATE_X0 + 0.3, Y + BOOM_BOTTOM + 0.05, Z0 + 0.45)
	for c in boom.get_children():
		(c as Node3D).position.x = 1.075  # pivot at the housing
	boom.rotation.z = deg_to_rad(80.0)  # raised
	b.paint_sign("GateVehicleSign", "SALIDA DE VEHÍCULOS", Vector3((GATE_X0 + PED_X0) * 0.5, Y + 3.1, Z0 - 0.48), "+z", 34, Color(0.9, 0.85, 0.6))
	b.paint_sign("GateEmergencySign", "SALIDA DE EMERGENCIA\nAPERTURA LIBRE", Vector3((PED_X0 + GATE_X1) * 0.5, Y + 2.5, Z0 + 0.32), "+z", 26, Color(0.45, 1.0, 0.6))
	b.static_visual(Vector3(0.9, 0.22, 0.06), Vector3((PED_X0 + GATE_X1) * 0.5, Y + 3.05, Z0 + 0.3), b.flat(Color(0.35, 1.0, 0.55), 0.4, 0.0, 2.6), false)
	reader_gate = b.screen_text("YardReaderGate", "", Vector3(GATE_X0 - 0.2, Y + 2.2, Z0 + 0.16), "+z", 22, Color(1.0, 0.45, 0.35))
	# Exit ramp to the street, with its side walls.
	b.wedge("ExitRamp", Vector3((GATE_X0 + GATE_X1) * 0.5, Y, Z0 - 0.3), Vector3((GATE_X0 + GATE_X1) * 0.5, 0.4, -24.0), GATE_X1 - GATE_X0, Y - 0.2, mats.get_material("asphalt"), false)
	b.wall_x("ExitRampWallWest", GATE_X0 - 0.15, -24.0, Z0 - 0.3, Y, 1.4, wall)
	b.wall_x("ExitRampWallEast", GATE_X1 + 0.15, -24.0, Z0 - 0.3, Y, 1.4, wall)


func _rows() -> void:
	# Bay lines (north row against the north wall, south row against the south wall, dock 2 left clear).
	for i in 11:
		b.static_visual(Vector3(0.1, 0.012, 5.0), Vector3(37.0 + i * 3.0, Y + 0.008, Z0 + 2.5), mats.get_material("paint_line"), false)
	for i in 8:
		b.static_visual(Vector3(0.1, 0.012, 5.0), Vector3(37.0 + i * 3.0, Y + 0.008, Z1 - 2.5), mats.get_material("paint_line"), false)
	for i in 3:
		b.static_visual(Vector3(0.1, 0.012, 5.0), Vector3(69.0 + i * 3.0, Y + 0.008, Z1 - 2.5), mats.get_material("paint_line"), false)
	b.static_visual(Vector3(5.6, 0.012, 3.4), Vector3(62.5, Y + 0.009, 12.1), b.flat(Color(0.75, 0.6, 0.18), 0.85), false)  # dock hatch
	b.paint_sign("DockLabel", "MUELLE 2", Vector3(62.5, Y + 0.03, 10.2), "floor", 60, Color(0.12, 0.1, 0.06))
	# Covered fleet cars: one collision box each, the CC0 model drawn as one multimesh (one draw call).
	var xforms: Array[Transform3D] = []
	var k := 0
	for x in NORTH_CARS:
		xforms.append(_car(Vector3(x, Y, Z0 + 2.5), k))
		k += 1
	for x in SOUTH_CARS:
		xforms.append(_car(Vector3(x, Y, Z1 - 2.4), k))
		k += 1
	_multimesh(CAR_PATH, xforms, "FleetCars")
	# Column rows with the overhead service pipe racks (2.8 m clear under the beam).
	for row_z in [-9.6, 8.0]:
		for x in COLUMN_X:
			b.body("RackColumn_%d_%d" % [int(x), int(row_z)], Vector3(0.8, 3.4, 0.8), Vector3(x, Y + 1.7, row_z), mats.get_material("bulkhead"))
		b.static_visual(Vector3(28.0, 0.32, 0.36), Vector3(52.0, Y + 3.0, row_z), mats.get_material("steel"), true)
		for off in [-0.35, 0.0, 0.35]:
			b.static_visual(Vector3(28.0, 0.16, 0.16), Vector3(52.0, Y + 3.3, row_z + off), mats.get_material("pipe"), true)
	# Dock 2 roller shutter (CC0 model) in the south wall, with a dark recess behind it.
	# The shutter closes a real opening in the south wall; behind it, a dark loading bay (closed at the back).
	b.body("DockRecessBack", Vector3(3.4, 2.6, 0.3), Vector3(DOCK_SHUTTER_AT.x, Y + 1.3, Z1 + 1.45), b.flat(Color(0.02, 0.02, 0.025), 0.9))
	b.body("DockRecessWest", Vector3(0.3, 2.6, 1.3), Vector3(DOCK_SHUTTER_AT.x - 1.65, Y + 1.3, Z1 + 0.95), mats.get_material("bulkhead"))
	b.body("DockRecessEast", Vector3(0.3, 2.6, 1.3), Vector3(DOCK_SHUTTER_AT.x + 1.65, Y + 1.3, Z1 + 0.95), mats.get_material("bulkhead"))
	b.static_visual(Vector3(3.0, 0.1, 1.2), Vector3(DOCK_SHUTTER_AT.x, Y + 2.45, Z1 + 0.9), b.flat(Color(0.03, 0.03, 0.035), 0.9), false)
	dock_shutter = _prop(SHUTTER_PATH, Vector3(DOCK_SHUTTER_AT.x + 1.0, Y, Z1 + 0.32), PI)
	b.body("DockShutterCollision", Vector3(3.0, 2.4, 0.2), Vector3(DOCK_SHUTTER_AT.x, Y + 1.2, Z1 + 0.2), b.flat(Color(0, 0, 0), 1.0), 1, false, false).get_child(1).queue_free()
	b.paint_sign("DockShutterSign", "MUELLE 2", Vector3(DOCK_SHUTTER_AT.x, Y + 2.8, Z1 - 0.02), "-z", 40, Color(0.9, 0.85, 0.6))


## A covered car in a bay; returns the model transform for the multimesh. Deterministic small yaw variation.
func _car(at: Vector3, k: int) -> Transform3D:
	var yaw := (PI if k % 3 == 1 else 0.0) + (float((k * 37) % 7) - 3.0) * 0.012
	b.body("FleetCar_%02d" % k, CAR_SIZE, at + Vector3(0.0, CAR_SIZE.y * 0.5, 0.0), mats.get_material("rubber"), 1, false, false).get_child(1).queue_free()
	var basis := Basis(Vector3.UP, yaw)
	return Transform3D(basis, at + basis * Vector3(-0.046, 0.0, -0.02))


func _apron_cover() -> void:
	# O1: abandoned service cart with drums (1.1 m: cover only when crouched; walk around it).
	b.body("O1ServiceCart", Vector3(2.1, 0.75, 1.9), Vector3(42.0, Y + 0.375, -2.4), mats.get_material("steel"))
	b.body("O1Drums", Vector3(1.3, 0.35, 1.2), Vector3(41.8, Y + 0.925, -2.4), mats.get_material("pipe_red"))
	b.paint_sign("O1Tag", "O1", Vector3(42.0, Y + 0.6, -1.43), "+z", 40, Color(0.95, 0.8, 0.4))
	# Parked service van: full cover between the routes.
	b.body("ServiceVan", Vector3(4.1, 2.2, 2.3), Vector3(47.0, Y + 1.1, 0.9), b.flat(Color(0.2, 0.24, 0.27), 0.55, 0.25))
	b.static_visual(Vector3(4.12, 0.5, 2.32), Vector3(47.0, Y + 1.55, 0.9), b.flat(Color(0.05, 0.06, 0.07), 0.15, 0.2), false)  # windows band
	b.static_visual(Vector3(4.12, 0.14, 2.32), Vector3(47.0, Y + 0.95, 0.9), mats.get_material("safety_paint"), false)  # livery stripe
	b.paint_sign("VanLivery", "HELIX · MANTENIMIENTO", Vector3(47.0, Y + 0.7, 2.07), "+z", 34, Color(0.85, 0.85, 0.82))
	# Stepped crate stack: 0.8 m and 1.6 m steps, a climbable vantage point (the unit cannot follow up).
	b.body("CrateStackLow", Vector3(3.7, 0.8, 2.4), Vector3(54.5, Y + 0.4, -3.1), mats.get_material("locker"))
	b.body("CrateStackHigh", Vector3(2.2, 0.8, 2.4), Vector3(55.25, Y + 1.2, -3.1), mats.get_material("locker"))
	b.paint_sign("CrateLabel", "MATERIAL DE MUESTREO", Vector3(54.5, Y + 0.45, -1.88), "+z", 26)
	# O2: displaced service rack near the convergence (1.4 m, partial cover; climbable).
	b.body("O2ServiceRack", Vector3(3.0, 1.4, 2.0), Vector3(65.6, Y + 0.7, 1.2), mats.get_material("steel"))
	for i in 3:
		b.static_visual(Vector3(3.1, 0.14, 0.14), Vector3(65.6, Y + 1.55, 0.5 + i * 0.7), mats.get_material("pipe"), true)
	b.paint_sign("O2Tag", "O2", Vector3(65.6, Y + 0.9, 2.21), "+z", 40, Color(0.95, 0.8, 0.4))


func _cage() -> void:
	# Technical cage: chain-link (blocks movement, not sight), condensing units and the compressor inside.
	var fence: Material = mats.get_material("fence")
	var r := CAGE
	for seg in [[r.position.x, r.position.y, r.end.x, r.position.y], [r.position.x, r.end.y, r.end.x, r.end.y],
			[r.position.x, r.position.y, r.position.x, r.end.y], [r.end.x, r.position.y, r.end.x, r.end.y]]:
		_fence(seg[0], seg[1], seg[2], seg[3], 2.4, fence)
	b.body("CageCondenserA", Vector3(1.3, 1.4, 1.0), Vector3(59.3, Y + 0.7, -3.4), mats.get_material("machine"))
	b.body("CageCondenserB", Vector3(1.3, 1.4, 1.0), Vector3(61.0, Y + 0.7, -3.4), mats.get_material("machine"))
	b.body("CageCompressor", Vector3(1.4, 1.1, 0.9), Vector3(62.4, Y + 0.55, -1.8), mats.get_material("machine"))
	# Compressor start panel on the outside of the west fence.
	b.static_visual(Vector3(0.2, 0.55, 0.5), COMPRESSOR_PANEL_AT + Vector3(0.12, 1.25, 0.0), mats.get_material("steel_light"), true)
	compressor_lamp = b.visual("CompressorLamp", Vector3(0.05, 0.08, 0.16), COMPRESSOR_PANEL_AT + Vector3(0.0, 1.45, 0.0), b.flat(GamePalette.color("ok"), 0.4, 0.0, 1.6), false)
	b.paint_sign("CompressorSign", "COMPRESOR C-3\nARRANQUE MANUAL", COMPRESSOR_PANEL_AT + Vector3(0.0, 1.85, 0.0), "-x", 22, Color(0.95, 0.82, 0.5))
	b.paint_sign("CageSign", "JAULA TÉCNICA  ·  ALTA PRESIÓN", Vector3(60.8, Y + 2.2, r.end.y + 0.06), "+z", 28, Color(0.95, 0.8, 0.4))


## A straight chain-link fence panel run with posts. Layer: no-mantle only (sight and the camera pass through).
func _fence(x0: float, z0: float, x1: float, z1: float, h: float, fence: Material) -> void:
	var along_x := absf(x1 - x0) > absf(z1 - z0)
	var length := absf(x1 - x0) if along_x else absf(z1 - z0)
	var size := Vector3(length, h, 0.06) if along_x else Vector3(0.06, h, length)
	var center := Vector3((x0 + x1) * 0.5, Y + h * 0.5, (z0 + z1) * 0.5)
	var body: StaticBody3D = b.body("Fence_%d_%d" % [int(center.x * 10), int(center.z * 10)], size, center, fence, Builder.LAYER_NO_MANTLE, false, true)
	body.collision_layer = Builder.LAYER_NO_MANTLE
	var posts := int(ceil(length / 2.4))
	for i in posts + 1:
		var t := float(i) / posts
		var p := Vector3(lerpf(x0, x1, t), Y + h * 0.5, lerpf(z0, z1, t))
		b.static_visual(Vector3(0.07, h + 0.05, 0.07), p, mats.get_material("steel"), true)
	b.static_visual(Vector3(size.x + 0.02 if along_x else 0.05, 0.05, size.z + 0.02 if not along_x else 0.05), center + Vector3(0.0, h * 0.5, 0.0), mats.get_material("steel"), false)


func _egress_enclosure() -> void:
	var fence: Material = mats.get_material("fence")
	# West side of the enclosure (see-through): the exit lane is visible from the whole yard.
	_fence(ENCLOSURE_X, Z0, ENCLOSURE_X, BARRIER_Z, 2.4, fence)
	# South side: fence, O3 stuck service gate leaves (solid steel) with the fixed 1.3 m aperture, fence.
	_fence(ENCLOSURE_X, BARRIER_Z, 70.8, BARRIER_Z, 2.4, fence)
	_fence(75.1, BARRIER_Z, X1, BARRIER_Z, 2.4, fence)
	b.body("O3LeafWest", Vector3(1.5, 2.2, 0.12), Vector3((70.8 + APERTURE.x) * 0.5, Y + 1.1, BARRIER_Z), mats.get_material("steel_light"))
	b.body("O3LeafEast", Vector3(1.5, 2.2, 0.12), Vector3((APERTURE.y + 75.1) * 0.5, Y + 1.1, BARRIER_Z), mats.get_material("steel_light"))
	b.static_visual(Vector3(4.5, 0.06, 0.18), Vector3(72.95, Y + 0.03, BARRIER_Z), mats.get_material("steel"), false)  # gate rail
	for side in [APERTURE.x - 0.06, APERTURE.y + 0.06]:
		b.static_visual(Vector3(0.05, 2.0, 0.14), Vector3(side, Y + 1.0, BARRIER_Z), mats.get_material("safety_paint"), false)
	b.paint_sign("O3Sign", "BARRERA DE SERVICIO O3\nATASCADA  ·  PASO 1,3 m", Vector3(72.95, Y + 2.45, BARRIER_Z + 0.08), "+z", 24, Color(0.95, 0.8, 0.4))
	# Inside: utility boxes against the north wall (CC0 model), sign of the emergency lane.
	_prop(UTILITY_PATH, Vector3(75.2, Y, Z0 + 0.4), 0.0)
	_prop(UTILITY_PATH, Vector3(74.5, Y, Z0 + 0.4), 0.0)
	b.body("UtilityBoxes", Vector3(1.4, 1.12, 0.5), Vector3(74.85, Y + 0.56, Z0 + 0.4), b.flat(Color(0, 0, 0), 1.0), 1, false, false).get_child(1).queue_free()


func _beyond_the_wall() -> void:
	# Street at the top of the ramp, its kerb wall, lamp posts and the city beyond (silhouettes, lit windows).
	b.slab("Street", Rect2(28.0, -34.0, 67.0, 10.0), 0.4, mats.get_material("asphalt"), 0.4)
	b.wall_z("StreetFarKerb", -34.15, 28.0, 95.0, 0.4, 1.4, mats.get_material("bulkhead"))
	b.wall_x("StreetWestEnd", 27.85, -34.0, -24.0, 0.4, 1.4, mats.get_material("bulkhead"))
	b.wall_x("StreetEastEnd", 95.15, -34.0, -24.0, 0.4, 1.4, mats.get_material("bulkhead"))
	# Street-level ground around the sunken yard (seen over the walls and from the street).
	var verge: Material = mats.get_material("asphalt")
	b.slab("VergeNorthWest", Rect2(28.0, -24.0, GATE_X0 - 0.3 - 28.0, 8.2), 0.4, verge, 0.3)
	b.slab("VergeNorthEast", Rect2(GATE_X1 + 0.3, -24.0, 95.0 - GATE_X1 - 0.3, 8.2), 0.4, verge, 0.3)
	b.slab("GroundEast", Rect2(X1 + 0.3, Z0 - 0.3, 34.0, Z1 - Z0 + 0.6), 0.4, verge, 0.3)
	b.slab("GroundSouth", Rect2(28.0, Z1 + 0.3, 82.0, 30.0), 0.4, verge, 0.3)
	for x in [40.0, 50.0, 58.0, 66.0, 76.0, 84.0]:
		b.static_visual(Vector3(0.14, 5.0, 0.14), Vector3(x, 0.4 + 2.5, -25.0), mats.get_material("steel"), true)
		b.static_visual(Vector3(0.9, 0.12, 0.35), Vector3(x + 0.35, 0.4 + 4.95, -25.0), b.flat(Color(1.0, 0.72, 0.4), 0.4, 0.0, 3.0), false)
	var window: Material = b.flat(Color(1.0, 0.8, 0.5), 0.5, 0.0, 1.8)
	var dark: Material = b.flat(Color(0.05, 0.06, 0.08), 0.9)
	var window_dim: Material = b.flat(Color(0.55, 0.62, 0.75), 0.5, 0.0, 0.7)
	# City blocks beyond the perimeter: [x, z, width, height]. Window grids on the faces that look at the yard and
	# the street; roughly a third lit, a deterministic pattern (no randomness), a few cold-lit offices.
	for spec in [[46.0, -48.0, 14.0, 22.0], [64.0, -54.0, 18.0, 31.0], [84.0, -47.0, 12.0, 18.0], [30.0, -52.0, 10.0, 14.0],
			[104.0, -20.0, 10.0, 26.0], [104.0, 10.0, 14.0, 16.0], [96.0, 34.0, 16.0, 20.0]]:
		var bx: float = spec[0]
		var bz: float = spec[1]
		var bw: float = spec[2]
		var bh: float = spec[3]
		b.static_visual(Vector3(bw, bh, 8.0), Vector3(bx, bh * 0.5, bz), dark, false)
		var facing_z := bz < -10.0  # northern blocks show their south face, eastern ones their west face
		var cols := int(bw / 1.6)
		var rows := int((bh - 2.0) / 2.2)
		for r in rows:
			for c in cols:
				var code := (r * 7 + c * 13 + int(bx)) % 10
				if code > 3:
					continue
				var mat: Material = window if code < 3 else window_dim
				var along := -bw * 0.5 + 0.8 + c * 1.6
				var up := 2.0 + r * 2.2
				if facing_z:
					b.static_visual(Vector3(0.9, 1.1, 0.1), Vector3(bx + along, up, bz + 4.06), mat, false)
				else:
					b.static_visual(Vector3(0.1, 1.1, 0.9), Vector3(bx - 4.06, up, bz + along), mat, false)


func _lights() -> void:
	var cool := Color(0.78, 0.88, 1.0)
	var sodium := Color(1.0, 0.72, 0.42)
	var flood := Color(0.92, 0.95, 1.0)
	b.light("YardMouthLight", Vector3(35.0, Y + 2.0, 6.0), cool, 1.1, 6.0)
	b.light("YardNorthSodium", Vector3(47.0, Y + 3.2, -9.0), sodium, 1.2, 9.0)
	b.light("YardEmergencyLane", Vector3(72.6, Y + 2.8, -15.0), Color(0.6, 1.0, 0.75), 1.4, 7.0)
	b.light("StreetGlow", Vector3(71.4, 3.5, -25.0), sodium, 1.6, 12.0)
	var fixtures: Array[Transform3D] = []
	for i in range(3, POOLS.size()):
		var p: Array = POOLS[i]
		var mount := Vector3(float(p[0]), Y + 3.2, float(p[1]))
		var l: OmniLight3D = b.light("YardFloodlight_%d" % (i - 2), mount, flood, 0.0, float(p[2]) * 1.35)
		l.visible = false
		floodlights.append(l)
		flood_lamps.append(b.visual("FloodLamp_%d" % (i - 2), Vector3(0.36, 0.08, 0.3), mount + Vector3(0.0, 0.1, 0.0), b.flat(Color(0.2, 0.2, 0.22), 0.4), false))
		fixtures.append(Transform3D(Basis(Vector3.RIGHT, PI), mount + Vector3(0.0, 0.4, 0.0)))
	_multimesh(LIGHT_PATH, fixtures, "FloodlightFixtures")


# --- runtime -------------------------------------------------------------------------------------------------------

## 0 (dark) .. 1 (inside a lit pool): how exposed a point in the yard is. Outside the yard it returns 1 (the
## interior uses its own fixed lighting and the unit sees normally there).
func exposure_at(p: Vector3) -> float:
	if p.x < X0 - 0.5 or p.y > Y + 1.8 or p.y < Y - 1.0:
		return 1.0
	var e := 0.0
	for i in POOLS.size():
		if not bool(pool_on[i]):
			continue
		var pool: Array = POOLS[i]
		var d := Vector2(p.x - float(pool[0]), p.z - float(pool[1])).length()
		var r := float(pool[2])
		e = maxf(e, 1.0 - smoothstep(r * 0.55, r, d))
	return e


func set_floodlight(index: int, on: bool) -> void:
	pool_on[index + 3] = on
	var l := floodlights[index]
	l.visible = on
	l.light_energy = 1.5 if on else 0.0
	flood_lamps[index].material_override = b.flat(Color(0.95, 0.97, 1.0), 0.3, 0.0, 3.0) if on else b.flat(Color(0.2, 0.2, 0.22), 0.4)


## True once Elena has crossed the north gate line (inside the gate posts, past the wall thickness).
func crossed_exit(p: Vector3) -> bool:
	return p.z < EXIT_Z and p.x > GATE_X0 - 0.5 and p.x < GATE_X1 + 0.5


func in_yard(p: Vector3) -> bool:
	return p.x > X0 + 0.6 and p.y < Y + 1.0


# --- helpers -------------------------------------------------------------------------------------------------------

func _prop(path: String, at: Vector3, yaw: float) -> Node3D:
	var scene := load(path) as PackedScene
	if scene == null:
		push_warning("Parking: missing prop %s" % path)
		return null
	var n := scene.instantiate() as Node3D
	n.position = at
	n.rotation.y = yaw
	root.add_child(n)
	for m in n.find_children("*", "MeshInstance3D", true, false):
		(m as MeshInstance3D).layers = Builder.band_layer(Builder.YARD_BAND)
	return n


## Draws many copies of a CC0 model's first mesh in one call.
func _multimesh(path: String, xforms: Array[Transform3D], label: String) -> void:
	var scene := load(path) as PackedScene
	if scene == null or xforms.is_empty():
		return
	var tmp := scene.instantiate() as Node3D
	var meshes := tmp.find_children("*", "MeshInstance3D", true, false)
	for m in meshes:
		var mi := m as MeshInstance3D
		var local := _local_xf(mi, tmp)
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mi.mesh
		mm.instance_count = xforms.size()
		for i in xforms.size():
			mm.set_instance_transform(i, xforms[i] * local)
		var mmi := MultiMeshInstance3D.new()
		mmi.name = "%s_%s" % [label, mi.name]
		mmi.multimesh = mm
		mmi.layers = Builder.band_layer(Builder.YARD_BAND)
		root.add_child(mmi)
	tmp.free()


func _local_xf(n: Node, top: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	var c := n
	while c != null and c != top:
		if c is Node3D:
			t = (c as Node3D).transform * t
		c = c.get_parent()
	return t
