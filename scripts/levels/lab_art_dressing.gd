extends Node3D
## Visual-only art dressing for Abandoned Lab rooms 1 and 2 (decision D1, docs/art/LAB_KIT_PLAN.md).
##
## Adds the Batch 1/2 lab art on top of the greybox WITHOUT touching abandoned_lab.tscn/.gd: floor, walls and
## dividers are instanced from the art kit (batched with MultiMesh), plus a few static set pieces. No colliders,
## no scripts, no input. Interactive components keep their greybox visuals until their emissive states are mapped.

const ART_DIR := "res://assets/models/lab/"
const ROOMS_X_MAX := 34.0
const HALF_DEPTH := 6.0
const WALL_HEIGHT := 3.2
const FLOOR_LIFT := 0.006  # lifts art tiles above the greybox floor to avoid z-fighting
const PANEL_OFFSET := 0.03  # art panel front relief sits this far past its pivot
const PHOTO_DIR := "res://assets/textures/lab_photo/"
const USE_PHOTO_TEXTURES := true  # photographic CC0 textures (see docs/art/PROVENANCE.md) instead of the kit's flat colours

var _mesh_cache: Dictionary = {}


func _ready() -> void:
	name = "LabArtDressing"
	_dress_floor()
	_dress_walls()
	_dress_dividers()
	_dress_set_pieces()


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
	var m := StandardMaterial3D.new()
	m.resource_name = texture_name
	m.albedo_texture = load(PHOTO_DIR + texture_name + "_diff.jpg")
	m.albedo_color = tint
	m.normal_enabled = true
	m.normal_texture = load(PHOTO_DIR + texture_name + "_nor.png")
	var arm: Texture2D = load(PHOTO_DIR + texture_name + "_arm.jpg")
	m.ao_enabled = true
	m.ao_texture = arm
	m.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	m.roughness = 1.0
	m.roughness_texture = arm
	m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
	m.metallic = 1.0
	m.metallic_texture = arm
	m.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE / tile_m
	return m


func _place(pos: Vector3, yaw_degrees: float = 0.0, scale_z: float = 1.0) -> Transform3D:
	var basis := Basis(Vector3.UP, deg_to_rad(yaw_degrees)) * Basis.from_scale(Vector3(1.0, 1.0, scale_z))
	return Transform3D(basis, pos)


func _dress_floor() -> void:
	var a: Array[Transform3D] = []
	var b: Array[Transform3D] = []
	var x := 1.0
	while x < ROOMS_X_MAX:
		var zi := 0
		var z := -HALF_DEPTH + 1.0
		while z < HALF_DEPTH:
			var t := _place(Vector3(x, FLOOR_LIFT, z))
			if (int(x) / 2 + zi) % 2 == 0:
				a.append(t)
			else:
				b.append(t)
			zi += 1
			z += 2.0
		x += 2.0
	var floor_mat := _photo("concrete_floor_worn_001", Color(0.85, 0.93, 0.97), 2.0)
	_batch("lab_floor_2x2_a.glb", a, "FloorA", floor_mat)
	_batch("lab_floor_2x2_b.glb", b, "FloorB", floor_mat)
	var edges: Array[Transform3D] = []
	x = 1.0
	while x < ROOMS_X_MAX:
		edges.append(_place(Vector3(x, FLOOR_LIFT, -HALF_DEPTH + 0.08)))
		x += 2.0
	_batch("lab_floor_edge_2m_a.glb", edges, "FloorEdgeBack", _photo("metal_plate_02", Color(0.7, 0.75, 0.78), 1.0))


func _dress_walls() -> void:
	var back_a: Array[Transform3D] = []
	var back_b: Array[Transform3D] = []
	var front_low: Array[Transform3D] = []
	var x := 1.0
	var i := 0
	while x < ROOMS_X_MAX:
		var t := _place(Vector3(x, 0.0, -HALF_DEPTH - PANEL_OFFSET))
		if i % 2 == 0:
			back_a.append(t)
		else:
			back_b.append(t)
		front_low.append(_place(Vector3(x, 0.0, HALF_DEPTH + PANEL_OFFSET), 180.0))
		x += 2.0
		i += 1
	var wall_mat := _photo("painted_plaster_wall", Color(0.9, 1.0, 1.0), 2.0)
	_batch("lab_wall_2m_a.glb", back_a, "WallBackA", wall_mat)
	_batch("lab_wall_2m_b.glb", back_b, "WallBackB", wall_mat)
	_batch("lab_wall_low_2m_a.glb", front_low, "WallFrontLow", wall_mat)
	var left: Array[Transform3D] = []
	var z := -HALF_DEPTH + 1.0
	while z < HALF_DEPTH:
		left.append(_place(Vector3(-PANEL_OFFSET, 0.0, z), 90.0))
		z += 2.0
	_batch("lab_wall_2m_a.glb", left, "WallLeft", wall_mat)


func _dress_dividers() -> void:
	# x = 16 and 34 dividers (z -6..-1.4 and 1.4..6, 0.6 thick); x = 25 inner walls (z -6..-2 and 2..6, 4 long)
	var long_panels: Array[Transform3D] = []
	for dx in [16.0, 34.0]:
		for sign in [-1.0, 1.0]:
			long_panels.append(_place(Vector3(dx, 0.0, sign * 4.85), 90.0, 1.15))
			long_panels.append(_place(Vector3(dx, 0.0, sign * 2.55), 90.0, 1.15))
	for sign in [-1.0, 1.0]:
		long_panels.append(_place(Vector3(25.0, 0.0, sign * 5.0), 90.0))
		long_panels.append(_place(Vector3(25.0, 0.0, sign * 3.0), 90.0))
	_batch("lab_divider_wall_2m_a.glb", long_panels, "Dividers", _photo("concrete_panels", Color(0.8, 0.88, 0.92), 4.0))


func _dress_set_pieces() -> void:
	# static set dressing against the walls, away from every interactive component
	var consoles: Array[Transform3D] = [
		_place(Vector3(8.0, 0.0, -5.55)), _place(Vector3(29.5, 0.0, -5.55)), _place(Vector3(19.5, 0.0, 5.5), 180.0)]
	_batch("lab_console_a.glb", consoles, "Consoles")
	var containers: Array[Transform3D] = [
		_place(Vector3(1.3, 0.0, 5.2), 180.0), _place(Vector3(32.6, 0.0, -5.2)), _place(Vector3(14.6, 0.0, 5.3), 180.0)]
	_batch("lab_container_a.glb", containers, "Containers")
	var lights: Array[Transform3D] = []
	for lx in [4.0, 11.0, 20.0, 29.0]:
		lights.append(_place(Vector3(lx, 2.5, -HALF_DEPTH + 0.06)))
	_batch("lab_wall_light_a.glb", lights, "WallLights")
