extends Node3D
## Visual-only art dressing (decision D1, docs/art/LAB_KIT_PLAN.md).
##
## Overlays the Batch 1/2 lab art on a greybox level WITHOUT touching the level scene or its script:
## floor, walls and dividers are instanced from the art kit (batched with MultiMesh) with photographic PBR
## textures, plus a few static set pieces. No colliders, no scripts, no input. Interactive components keep
## their greybox visuals until their emissive states are mapped.
##
## Profiles: "lab" = Abandoned Lab (phase 2, x 0..86), "phase1" = the Elena test room (phase 1, 24 x 16 m).

const ART_DIR := "res://assets/models/lab/"
const PhotoMaterial := preload("res://scripts/levels/lab_photo_material.gd")
const USE_PHOTO_TEXTURES := true  # photographic CC0 textures (docs/art/PROVENANCE.md) instead of the kit's flat colours
const FLOOR_LIFT := 0.006  # lifts art tiles above the greybox floor to avoid z-fighting
const PANEL_OFFSET := 0.03  # art panel front relief sits this far past its pivot
const PANEL_LENGTH := 2.0  # length of the 2 m kit panels

## Ambient brightening applied to the level's environment (visual only), so the textures can be seen.
const AMBIENT_ENERGY := 0.75
const SUN_ENERGY := 0.6
const FOG_DENSITY := 0.006
## Lighting pass (all visual-only; gl_compatibility has no SSAO/SDFGI/volumetric fog, so the look comes from
## colour grading, glow, soft fixture lights and a cool sun/warm accent contrast).
const GLOW_INTENSITY := 0.5
const GLOW_THRESHOLD := 1.0
const CONTRAST := 1.06
const SATURATION := 0.92
const FIXTURE_ENERGY := 1.1
const FIXTURE_RANGE := 7.5
const FIXTURE_HEIGHT := 2.3
const FIXTURE_DEPTH := 1.6  # metres in front of the wall
const COLD_LIGHT := Color(0.72, 0.88, 1.0)
const WARM_LIGHT := Color(1.0, 0.8, 0.55)

@export var profile: String = "lab"

var _mesh_cache: Dictionary = {}
var _materials: Dictionary = {}


func _ready() -> void:
	name = "LabArtDressing"
	var layout := _layout()
	_dress_floor(layout)
	_dress_walls(layout)
	_dress_dividers(layout["dividers"])
	_dress_set_pieces(layout)
	_brighten()
	_fixture_lights(layout)


## Rectangles are Rect2(x0, z0, width, depth) in metres.
func _layout() -> Dictionary:
	if profile == "phase1":
		return {
			"floors": [Rect2(-12, -8, 24, 16)],
			"x0": -12.0, "x1": 12.0, "half": 8.0,
			# dividers: [x, z_from, z_to]
			"dividers": [[-8.0, -8.0, -1.4], [-8.0, 1.4, 8.0], [3.9, -8.0, -1.4], [3.9, 1.4, 8.0], [8.5, -8.0, -1.4], [8.5, 1.4, 8.0]],
			"consoles": [[-3.0, -7.55, 0.0], [1.0, 7.5, 180.0]],
			"containers": [[-11.2, -7.2, 0.0], [11.0, -7.2, 0.0], [-1.0, 7.2, 180.0]],
			"lights": [-10.0, -3.0, 6.0, 10.5],
		}
	return {
		"floors": [Rect2(0, -6, 40, 12), Rect2(46, -6, 6, 12), Rect2(58, -6, 28, 12)],
		"x0": 0.0, "x1": 86.0, "half": 6.0,
		"dividers": [[16.0, -6.0, -1.4], [16.0, 1.4, 6.0], [34.0, -6.0, -1.4], [34.0, 1.4, 6.0], [60.0, -6.0, -1.4], [60.0, 1.4, 6.0],
			[25.0, -6.0, -2.0], [25.0, 2.0, 6.0]],
		"consoles": [[8.0, -5.55, 0.0], [29.5, -5.55, 0.0], [19.5, 5.5, 180.0], [37.0, -5.55, 0.0], [49.0, -5.55, 0.0], [63.5, -5.55, 0.0],
			[83.5, -5.55, 0.0]],
		"containers": [[1.3, 5.2, 180.0], [32.6, -5.2, 0.0], [14.6, 5.3, 180.0], [38.8, 5.2, 180.0], [50.6, 5.2, 180.0], [60.8, -5.2, 0.0],
			[84.5, 5.2, 180.0], [66.0, -5.2, 0.0]],
		"lights": [4.0, 11.0, 20.0, 29.0, 38.0, 47.0, 56.0, 64.0, 72.0, 80.0],
	}


## First mesh of a lab GLB with the transform it has relative to the GLB root.
func _source(file: String) -> Dictionary:
	if _mesh_cache.has(file):
		return _mesh_cache[file]
	var packed := load(ART_DIR + file) as PackedScene
	var result := {"mesh": null, "offset": Transform3D.IDENTITY}
	if packed != null:
		var root := packed.instantiate()
		var found := root.find_children("*", "MeshInstance3D", true, false)
		if not found.is_empty():
			var mi := found[0] as MeshInstance3D
			var xf := mi.transform
			var parent := mi.get_parent()
			while parent != null and parent != root:
				xf = (parent as Node3D).transform * xf
				parent = parent.get_parent()
			result = {"mesh": mi.mesh, "offset": xf}
		root.free()
	_mesh_cache[file] = result
	return result


## One MultiMeshInstance3D for many placements of the same art mesh.
func _batch(file: String, placements: Array[Transform3D], label: String, material: Material = null) -> void:
	var src := _source(file)
	if src["mesh"] == null or placements.is_empty():
		push_warning("LabArtDressing: missing art %s" % file)
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = src["mesh"]
	mm.instance_count = placements.size()
	for i in placements.size():
		mm.set_instance_transform(i, placements[i] * (src["offset"] as Transform3D))
	var inst := MultiMeshInstance3D.new()
	inst.name = label
	inst.multimesh = mm
	if material != null and USE_PHOTO_TEXTURES:
		inst.material_override = material
	add_child(inst)


## Photographic PBR material mapped with world-space triplanar projection (the kit meshes do not need usable UVs).
## tint multiplies the albedo to keep the lab's cool palette; tile_m is the real-world size of one texture repeat.
func _photo(texture_name: String, tint: Color, tile_m: float) -> StandardMaterial3D:
	var key := "%s|%s|%s" % [texture_name, tint, tile_m]
	if _materials.has(key):
		return _materials[key]
	var m := PhotoMaterial.make(texture_name, tint, tile_m)
	_materials[key] = m
	return m


## length_scale stretches the panel along its own long axis (local X) so segments can be fitted exactly.
func _place(pos: Vector3, yaw_degrees: float = 0.0, length_scale: float = 1.0) -> Transform3D:
	var basis := Basis(Vector3.UP, deg_to_rad(yaw_degrees)) * Basis.from_scale(Vector3(length_scale, 1.0, 1.0))
	return Transform3D(basis, pos)


func _dress_floor(layout: Dictionary) -> void:
	var a: Array[Transform3D] = []
	var b: Array[Transform3D] = []
	var edges: Array[Transform3D] = []
	var back_z: float = -float(layout["half"]) + 0.08
	for r in layout["floors"]:
		var rect := r as Rect2
		var cols := int(round(rect.size.x / 2.0))
		var rows := int(round(rect.size.y / 2.0))
		for i in cols:
			for j in rows:
				var pos := Vector3(rect.position.x + 1.0 + 2.0 * i, FLOOR_LIFT, rect.position.y + 1.0 + 2.0 * j)
				if (i + j) % 2 == 0:
					a.append(_place(pos))
				else:
					b.append(_place(pos))
			edges.append(_place(Vector3(rect.position.x + 1.0 + 2.0 * i, FLOOR_LIFT, back_z)))
	var floor_mat := _photo("concrete_floor_worn_001", Color(0.62, 0.68, 0.72), 3.0)
	_batch("lab_floor_2x2_a.glb", a, "FloorA", floor_mat)
	_batch("lab_floor_2x2_b.glb", b, "FloorB", floor_mat)
	_batch("lab_floor_edge_2m_a.glb", edges, "FloorEdgeBack", _photo("metal_plate_02", Color(0.7, 0.75, 0.78), 1.0))


func _dress_walls(layout: Dictionary) -> void:
	var x0: float = layout["x0"]
	var x1: float = layout["x1"]
	var half: float = layout["half"]
	var wall_mat := _photo("painted_plaster_wall", Color(0.80, 0.90, 0.95), 3.0)
	var back_a: Array[Transform3D] = []
	var back_b: Array[Transform3D] = []
	var front_low: Array[Transform3D] = []
	var x := x0 + 1.0
	var i := 0
	while x < x1:
		var t := _place(Vector3(x, 0.0, -half - PANEL_OFFSET))
		if i % 2 == 0:
			back_a.append(t)
		else:
			back_b.append(t)
		front_low.append(_place(Vector3(x, 0.0, half + PANEL_OFFSET), 180.0))
		x += 2.0
		i += 1
	_batch("lab_wall_2m_a.glb", back_a, "WallBackA", wall_mat)
	_batch("lab_wall_2m_b.glb", back_b, "WallBackB", wall_mat)
	_batch("lab_wall_low_2m_a.glb", front_low, "WallFrontLow", wall_mat)
	var sides: Array[Transform3D] = []
	var z := -half + 1.0
	while z < half:
		sides.append(_place(Vector3(x0 - PANEL_OFFSET, 0.0, z), 90.0))  # left wall, art faces +X
		sides.append(_place(Vector3(x1 + PANEL_OFFSET, 0.0, z), -90.0))  # end wall, art faces -X
		z += 2.0
	_batch("lab_wall_2m_a.glb", sides, "WallSides", wall_mat)


## Each divider is [x, z_from, z_to]; panels run along Z and are stretched so a run exactly fills the segment.
func _dress_dividers(dividers: Array) -> void:
	var panels: Array[Transform3D] = []
	for d in dividers:
		var length: float = absf(float(d[2]) - float(d[1]))
		var count := maxi(1, int(round(length / PANEL_LENGTH)))
		var step := length / count
		for k in count:
			var z := minf(float(d[1]), float(d[2])) + step * (k + 0.5)
			panels.append(_place(Vector3(float(d[0]), 0.0, z), 90.0, step / PANEL_LENGTH))
	_batch("lab_divider_wall_2m_a.glb", panels, "Dividers", _photo("concrete_panels", Color(0.55, 0.62, 0.68), 8.0))


func _dress_set_pieces(layout: Dictionary) -> void:
	var half: float = layout["half"]
	var consoles: Array[Transform3D] = []
	for c in layout["consoles"]:
		consoles.append(_place(Vector3(float(c[0]), 0.0, float(c[1])), float(c[2])))
	_batch("lab_console_a.glb", consoles, "Consoles")
	var containers: Array[Transform3D] = []
	for c in layout["containers"]:
		containers.append(_place(Vector3(float(c[0]), 0.0, float(c[1])), float(c[2])))
	_batch("lab_container_a.glb", containers, "Containers")
	var lights: Array[Transform3D] = []
	for lx in layout["lights"]:
		lights.append(_place(Vector3(float(lx), 2.5, -half + 0.06)))
	_batch("lab_wall_light_a.glb", lights, "WallLights")


## Visual-only: raises the level's ambient/sun and lowers the fog so the photographic textures read.
func _brighten() -> void:
	var host := get_parent()
	if host == null:
		return
	for node in host.find_children("*", "WorldEnvironment", true, false):
		var env := (node as WorldEnvironment).environment
		if env != null:
			env.ambient_light_energy = maxf(env.ambient_light_energy, AMBIENT_ENERGY)
			env.fog_density = minf(env.fog_density, FOG_DENSITY)
			env.glow_enabled = true
			env.glow_intensity = GLOW_INTENSITY
			env.glow_hdr_threshold = GLOW_THRESHOLD
			env.adjustment_enabled = true
			env.adjustment_contrast = CONTRAST
			env.adjustment_saturation = SATURATION
	for node in host.find_children("*", "DirectionalLight3D", true, false):
		var sun := node as DirectionalLight3D
		sun.light_energy = maxf(sun.light_energy, SUN_ENERGY)


## A soft light under every wall fixture, alternating cold/warm, so the room shows pools of light instead of one flat tone.
## No shadows (cheap on the integrated GPU); the level's own lamps are left as they are.
func _fixture_lights(layout: Dictionary) -> void:
	var half: float = layout["half"]
	var i := 0
	for lx in layout["lights"]:
		var light := OmniLight3D.new()
		light.name = "FixtureLight%d" % i
		light.position = Vector3(float(lx), FIXTURE_HEIGHT, -half + FIXTURE_DEPTH)
		light.light_color = COLD_LIGHT if i % 2 == 0 else WARM_LIGHT
		light.light_energy = FIXTURE_ENERGY
		light.omni_range = FIXTURE_RANGE
		light.shadow_enabled = false
		add_child(light)
		i += 1
