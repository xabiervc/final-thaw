extends RefCounted
## Geometry primitives for the Phase 1 building (greybox with facility materials).
##
## Every helper creates real collision that matches what is drawn. Conventions: metres, X east, Z south, Y up.
## - Floors are slabs whose TOP is at the given level.
## - Stairs are solid wedges (no hollow underside to wander into) with a walkable slope.
## - Guard rails sit on collision layer 5 only: bodies that collide with it (Elena, the recovery unit) are stopped,
##   while sight lines, interaction rays and the camera arm (layer 1 only) see through them, as through a real rail.
##   Elena's mantle never lands on layer 5.
## - Sloped rails are sheared prisms: they follow the stair exactly and never stick out over a landing.

const SLAB := 0.25
const WALL := 0.3
const RAIL_HEIGHT := 1.1
const LAYER_WORLD := 1
const LAYER_NO_MANTLE := 16  # physics layer 5

var root: Node3D
var mats = null  # FacilityMaterials
var _flat_cache: Dictionary = {}
## Static batching: geometry that never moves is merged per material, per 8 m cell and per storey band, so the
## building draws in tens of calls instead of hundreds and each merged mesh stays within the Compatibility
## renderer's per-object light limit. Collision is never merged. Call flush() once after building.
const CELL := 12.0
## Storey bands for lighting: geometry of each storey lives on its own render layer (2..5) and each light only lights
## its storey (+ layer 1, where Elena, the unit and the staff live). Lights no longer leak through slabs, and each
## surface pays for 2-4 lights instead of up to 8 (measured cost on the Compatibility renderer, HD 630).
const BAND_TOPS := [-0.8, 2.75, 5.75]  # P-1 | P0 | M | P2


static func band_of(y: float) -> int:
	for i in BAND_TOPS.size():
		if y < float(BAND_TOPS[i]):
			return i
	return BAND_TOPS.size()


## The exterior service yard (Phase 2) is its own band: its lights never reach the interior storeys and the
## interior lights never reach the yard. Set `force_band = YARD_BAND` while building it.
const YARD_BAND := 4
var force_band: int = -1


func _band(y: float) -> int:
	return force_band if force_band >= 0 else band_of(y)


static func band_layer(band: int) -> int:
	return 1 << (band + 1)
var _batches: Dictionary = {}  # key -> {"st": SurfaceTool, "mat": Material, "shadow": bool}


func _init(parent: Node3D, materials) -> void:
	root = parent
	mats = materials


func mat(key: String) -> Material:
	return mats.get_material(key)


func flat(color: Color, roughness: float = 0.7, metallic: float = 0.0, emission: float = 0.0) -> StandardMaterial3D:
	var key := "%s|%s|%s|%s" % [color, roughness, metallic, emission]
	if _flat_cache.has(key):
		return _flat_cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	if emission > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission
	_flat_cache[key] = m
	return m


# --- bodies -----------------------------------------------------------------------------------------------------

func body(label: String, size: Vector3, center: Vector3, material: Material, layer: int = LAYER_WORLD, shadow: bool = true, batch: bool = true) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.name = label
	b.position = center
	b.collision_layer = layer
	b.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	b.add_child(shape)
	if batch:
		add_box_to_batch(size, Transform3D(Basis.IDENTITY, center), material, shadow)
	else:
		var mesh := MeshInstance3D.new()
		mesh.name = label + "Mesh"
		var bm := BoxMesh.new()
		bm.size = size
		mesh.mesh = bm
		mesh.material_override = material
		if not shadow:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.layers = band_layer(_band(center.y))
		b.add_child(mesh)
	root.add_child(b)
	return b


## Unmoving decoration without collision, merged into the static batches.
func static_visual(size: Vector3, center: Vector3, material: Material, shadow: bool = false) -> void:
	add_box_to_batch(size, Transform3D(Basis.IDENTITY, center), material, shadow)


func add_box_to_batch(size: Vector3, xf: Transform3D, material: Material, shadow: bool) -> void:
	var c := xf.origin
	var y0 := c.y - size.y * 0.5
	var y1 := c.y + size.y * 0.5
	# Tall walls are sliced at storey boundaries so each slice is lit by its own storey (visual only).
	for top in ([] if force_band >= 0 else BAND_TOPS):
		var t := float(top)
		if y0 < t - 0.05 and y1 > t + 0.05 and xf.basis.is_equal_approx(Basis.IDENTITY):
			add_box_to_batch(Vector3(size.x, t - y0, size.z), Transform3D(Basis.IDENTITY, Vector3(c.x, (y0 + t) * 0.5, c.z)), material, shadow)
			add_box_to_batch(Vector3(size.x, y1 - t, size.z), Transform3D(Basis.IDENTITY, Vector3(c.x, (t + y1) * 0.5, c.z)), material, shadow)
			return
	var band := _band(c.y)
	var key := "%d|%d|%d|%d|%s" % [material.get_instance_id(), int(floor(c.x / CELL)), int(floor(c.z / CELL)), band, shadow]
	if not _batches.has(key):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		_batches[key] = {"st": st, "mat": material, "shadow": shadow, "band": band}
	var bm := BoxMesh.new()
	bm.size = size
	(_batches[key]["st"] as SurfaceTool).append_from(bm, 0, xf)


## Builds one MeshInstance3D per batch. Returns how many were created.
func flush() -> int:
	var n := 0
	for key in _batches:
		var entry: Dictionary = _batches[key]
		var mi := MeshInstance3D.new()
		mi.name = "StaticBatch_%02d" % n
		mi.mesh = (entry["st"] as SurfaceTool).commit()
		mi.material_override = entry["mat"]
		mi.layers = band_layer(int(entry["band"]))
		if not bool(entry["shadow"]):
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(mi)
		n += 1
	_batches.clear()
	return n


func visual(label: String, size: Vector3, center: Vector3, material: Material, shadow: bool = false) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.name = label
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	m.position = center
	m.material_override = material
	m.layers = band_layer(_band(center.y))
	if not shadow:
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(m)
	return m


## Slab with its top at `top_y`.
func slab(label: String, rect: Rect2, top_y: float, material: Material = null, thickness: float = SLAB) -> StaticBody3D:
	var chosen: Material = mat("floor") if material == null else material
	return body(label, Vector3(rect.size.x, thickness, rect.size.y), Vector3(rect.position.x + rect.size.x * 0.5, top_y - thickness * 0.5, rect.position.y + rect.size.y * 0.5), chosen)


## A slab with rectangular holes cut out (stair wells, shafts, voids). Returns the pieces.
func slab_with_holes(label: String, rect: Rect2, holes: Array, top_y: float, material: Material = null) -> Array:
	var regions: Array = [rect]
	for hole in holes:
		var next: Array = []
		for r in regions:
			next.append_array(subtract(r, hole))
		regions = next
	var out: Array = []
	for i in regions.size():
		var r: Rect2 = regions[i]
		if r.size.x > 0.01 and r.size.y > 0.01:
			out.append(slab("%s_%02d" % [label, i], r, top_y, material))
	return out


static func subtract(base: Rect2, hole: Rect2) -> Array:
	var ix0: float = maxf(base.position.x, hole.position.x)
	var iz0: float = maxf(base.position.y, hole.position.y)
	var ix1: float = minf(base.end.x, hole.end.x)
	var iz1: float = minf(base.end.y, hole.end.y)
	if ix1 <= ix0 or iz1 <= iz0:
		return [base]
	var pieces: Array = []
	if iz0 > base.position.y:
		pieces.append(Rect2(base.position.x, base.position.y, base.size.x, iz0 - base.position.y))
	if iz1 < base.end.y:
		pieces.append(Rect2(base.position.x, iz1, base.size.x, base.end.y - iz1))
	if ix0 > base.position.x:
		pieces.append(Rect2(base.position.x, iz0, ix0 - base.position.x, iz1 - iz0))
	if ix1 < base.end.x:
		pieces.append(Rect2(ix1, iz0, base.end.x - ix1, iz1 - iz0))
	return pieces


## Wall running along Z at x (centred on x).
func wall_x(label: String, x: float, z0: float, z1: float, y0: float, y1: float, material: Material = null) -> StaticBody3D:
	if z1 <= z0 or y1 <= y0:
		return null
	return body(label, Vector3(WALL, y1 - y0, z1 - z0), Vector3(x, (y0 + y1) * 0.5, (z0 + z1) * 0.5), mat("bulkhead") if material == null else material)


## Wall running along X at z (centred on z).
func wall_z(label: String, z: float, x0: float, x1: float, y0: float, y1: float, material: Material = null) -> StaticBody3D:
	if x1 <= x0 or y1 <= y0:
		return null
	return body(label, Vector3(x1 - x0, y1 - y0, WALL), Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, z), mat("bulkhead") if material == null else material)


# --- guard rails --------------------------------------------------------------------------------------------------

## Straight guard rail on a floor at `y`, along X (from x0 to x1 at z) or along Z. Blocks Elena, never mantle-able.
## The collision is a full-height thin panel (no gap under the bar); the visual is a top bar, a mid bar and posts.
func rail_x(label: String, x0: float, x1: float, z: float, y: float, height: float = RAIL_HEIGHT) -> StaticBody3D:
	return _rail(label, Vector3(x1 - x0, height, 0.1), Vector3((x0 + x1) * 0.5, y, z), true)


func rail_z(label: String, z0: float, z1: float, x: float, y: float, height: float = RAIL_HEIGHT) -> StaticBody3D:
	return _rail(label, Vector3(0.1, height, z1 - z0), Vector3(x, y, (z0 + z1) * 0.5), false)


func _rail(label: String, size: Vector3, base: Vector3, along_x: bool) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.name = label
	b.position = base + Vector3(0.0, size.y * 0.5, 0.0)
	_rail_origin = b.position
	b.collision_layer = LAYER_NO_MANTLE
	b.collision_mask = 0
	b.add_to_group("guard_rails")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	b.add_child(shape)
	var length: float = size.x if along_x else size.z
	var bar_size := Vector3(length, 0.07, 0.07) if along_x else Vector3(0.07, 0.07, length)
	_rail_piece(b, bar_size, Vector3(0.0, size.y * 0.5 - 0.035, 0.0), mat("safety_paint"))
	_rail_piece(b, bar_size, Vector3(0.0, 0.0, 0.0), mat("steel_light"))
	_rail_piece(b, Vector3(bar_size.x, 0.12, bar_size.z) if along_x else Vector3(bar_size.x, 0.12, bar_size.z), Vector3(0.0, -size.y * 0.5 + 0.06, 0.0), mat("steel"))
	var posts := maxi(2, int(ceil(length / 1.5)) + 1)
	for i in posts:
		var t := -0.5 + float(i) / float(posts - 1)
		var offset := Vector3(t * length, 0.0, 0.0) if along_x else Vector3(0.0, 0.0, t * length)
		_rail_piece(b, Vector3(0.06, size.y, 0.06), offset, mat("steel_light"))
	root.add_child(b)
	return b


var _rail_origin: Vector3 = Vector3.ZERO


func _rail_piece(_parent: Node3D, size: Vector3, offset: Vector3, material: Material) -> void:
	add_box_to_batch(size, Transform3D(Basis.IDENTITY, _rail_origin + offset), material, false)


## Rail that follows a stair slope from `a` to `b` (both on the walking surface at the rail's line).
## A sheared prism: its ends are vertical, so it never protrudes past the stair's first or last tread.
func sloped_rail(label: String, a: Vector3, b: Vector3, height: float = RAIL_HEIGHT, thickness: float = 0.1) -> StaticBody3D:
	var body_node := StaticBody3D.new()
	body_node.name = label
	body_node.collision_layer = LAYER_NO_MANTLE
	body_node.collision_mask = 0
	body_node.add_to_group("guard_rails")
	var run := b - a
	var flat := Vector3(run.x, 0.0, run.z)
	var side := flat.normalized().cross(Vector3.UP) * thickness * 0.5
	var pts := PackedVector3Array()
	for p in [a, b]:
		for s in [side, -side]:
			pts.append(p + s)
			pts.append(p + s + Vector3(0.0, height, 0.0))
	var shape := CollisionShape3D.new()
	var convex := ConvexPolygonShape3D.new()
	convex.points = pts
	shape.shape = convex
	body_node.add_child(shape)
	# Visual: unit box sheared onto the same prism (top bar + mid bar + panel).
	var center := (a + b) * 0.5
	for spec in [[height - 0.035, 0.07, mat("safety_paint")], [height * 0.5, 0.07, mat("steel_light")], [0.06, 0.12, mat("steel")]]:
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3.ONE
		m.mesh = bm
		var x_axis := Vector3(run.x, run.y, run.z)
		var y_axis := Vector3(0.0, float(spec[1]), 0.0)
		var z_axis := flat.normalized().cross(Vector3.UP) * 0.07
		m.transform = Transform3D(Basis(x_axis, y_axis, z_axis), center + Vector3(0.0, float(spec[0]), 0.0))
		m.material_override = spec[2]
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		body_node.add_child(m)
	root.add_child(body_node)
	return body_node


# --- stairs and ramps -----------------------------------------------------------------------------------------

## Solid stair/ramp wedge. `low` and `high` are the centres of the bottom and top edges on the walking surface;
## `width` is measured across the run. The body is filled down to `base_y` so nothing can get underneath.
func wedge(label: String, low: Vector3, high: Vector3, width: float, base_y: float, material: Material = null, treads: bool = true) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.name = label
	b.collision_layer = LAYER_WORLD
	b.collision_mask = 0
	b.add_to_group("stairs")
	var flat := Vector3(high.x - low.x, 0.0, high.z - low.z)
	var side := flat.normalized().cross(Vector3.UP) * width * 0.5
	var l1 := low + side
	var l2 := low - side
	var h1 := high + side
	var h2 := high - side
	var lb1 := Vector3(l1.x, base_y, l1.z)
	var lb2 := Vector3(l2.x, base_y, l2.z)
	var hb1 := Vector3(h1.x, base_y, h1.z)
	var hb2 := Vector3(h2.x, base_y, h2.z)
	var shape := CollisionShape3D.new()
	var convex := ConvexPolygonShape3D.new()
	convex.points = PackedVector3Array([l1, l2, h1, h2, lb1, lb2, hb1, hb2])
	shape.shape = convex
	b.add_child(shape)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_quad(st, l2, l1, h1, h2)       # walking surface
	_quad(st, hb2, hb1, h1, h2)     # back face (top end)
	_quad(st, lb1, lb2, l2, l1)     # front face (bottom end, may be zero height)
	_quad(st, lb1, hb1, h1, l1)     # side
	_quad(st, hb2, lb2, l2, h2)     # other side
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.name = label + "Mesh"
	mi.mesh = st.commit()
	mi.material_override = mat("grate") if material == null else material
	mi.layers = band_layer(_band((low.y + high.y) * 0.5))
	b.add_child(mi)
	if treads:
		var rise := high.y - low.y
		var count := maxi(2, int(ceil(absf(rise) / 0.18)))
		for i in range(1, count):
			var t := float(i) / float(count)
			var p := low.lerp(high, t)
			var tread := MeshInstance3D.new()
			var tb := BoxMesh.new()
			tb.size = Vector3(1.0, 0.025, 1.0)
			tread.mesh = tb
			var across := side.normalized() * width
			tread.transform = Transform3D(Basis(across, Vector3.UP, flat.normalized() * 0.05), p + Vector3(0.0, 0.015, 0.0))
			tread.material_override = mat("safety_paint")
			tread.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			b.add_child(tread)
	root.add_child(b)
	return b


func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)
	st.add_vertex(a)
	st.add_vertex(c)
	st.add_vertex(d)


# --- signage and light -----------------------------------------------------------------------------------------

## Diegetic sign painted on a surface (depth-tested, shaded). facing: "+x", "-x", "+z", "-z" or "floor".
func paint_sign(label: String, text: String, pos: Vector3, facing: String, size: int = 48, color: Color = Color(0.82, 0.8, 0.7)) -> Label3D:
	var l := Label3D.new()
	l.name = label
	l.text = text
	l.position = pos
	l.font_size = size
	l.pixel_size = 0.004
	l.modulate = color
	l.outline_size = 0
	l.shaded = true
	l.double_sided = false
	l.no_depth_test = false
	l.layers = band_layer(_band(pos.y))
	match facing:
		"+x":
			l.rotation.y = PI * 0.5
		"-x":
			l.rotation.y = -PI * 0.5
		"-z":
			l.rotation.y = PI
		"floor":
			l.rotation.x = -PI * 0.5
	root.add_child(l)
	return l


## Readable status text (unshaded, emissive-looking) for screens and indicators.
func screen_text(label: String, text: String, pos: Vector3, facing: String, size: int = 28, color: Color = Color(0.7, 0.95, 0.95)) -> Label3D:
	var l: Label3D = paint_sign(label, text, pos, facing, size, color)
	l.shaded = false
	l.outline_size = 4
	l.outline_modulate = Color(0, 0, 0, 0.8)
	return l


## Outside-only surface (roofs, upper facade infill): a single-sided quad facing `normal` ("+y", "+z", "-x"...),
## no collision and no shadow, so it closes the building's silhouette from outside (cinematics, the yard) while
## staying invisible from inside and never touching the gameplay camera.
func exterior_skin(label: String, size: Vector2, center: Vector3, normal: String, material: Material) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.name = label
	var q := QuadMesh.new()
	q.size = size
	m.mesh = q
	m.material_override = material
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.position = center
	match normal:
		"+y":
			m.rotation = Vector3(-PI * 0.5, 0.0, 0.0)
		"-x":
			m.rotation = Vector3(0.0, -PI * 0.5, 0.0)
		"+x":
			m.rotation = Vector3(0.0, PI * 0.5, 0.0)
		"-z":
			m.rotation = Vector3(0.0, PI, 0.0)
	m.layers = band_layer(_band(center.y))
	root.add_child(m)
	return m


## A light lights its own storey (by its mounting height, ~1.8 m above the floor, or `band` if given) and layer 1.
func light(label: String, pos: Vector3, color: Color, energy: float, light_range: float, band: int = -1) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.light_cull_mask = 1 | band_layer(band if band >= 0 else (force_band if force_band >= 0 else band_of(pos.y - 1.8)))
	l.name = label
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = light_range
	l.omni_attenuation = 1.3
	l.shadow_enabled = false
	root.add_child(l)
	return l
