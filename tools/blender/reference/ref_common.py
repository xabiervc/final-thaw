"""Biblioteca de la canalizacion de la escena de referencia del laboratorio.

Flujo por asset: geometria con detalle real (biseles, juntas, tornillos, lofts) ->
materiales procedurales (desgaste de bordes, oclusion, suciedad, ruido) -> desenvuelto UV ->
horneado en Cycles (CPU) de albedo, normal tangente, rugosidad, AO y metal -> textura ORM ->
PNG en assets/textures/lab_ref/ + material StandardMaterial3D (.tres) en assets/materials/lab_ref/
-> GLB solo con geometria y UV (los materiales finales los pone Godot por nombre).

Toda la geometria se define en coordenadas de Godot (X derecha, Y arriba, +Z frente, metros) y
se convierte con lab_blender_common (Godot -> Blender). No se usan recursos externos.
"""

import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

import bmesh  # noqa: E402
import bpy  # noqa: E402
import numpy as np  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402
from lab_blender_common import (export_glb, godot_to_blender, parse_args, prim_matrix,  # noqa: E402,F401
	reset_scene, triangle_count, world_bounds_godot)

SHARP_ANGLE = math.radians(32.0)
DEFAULT_MARGIN = 14

# --------------------------------------------------------------------------------------
# Color
# --------------------------------------------------------------------------------------


def _s2l(channel: float) -> float:
	return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def hex_lin(hex_value: str, alpha: float = 1.0) -> tuple:
	r, g, b = (int(hex_value[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
	return (_s2l(r), _s2l(g), _s2l(b), alpha)


# --------------------------------------------------------------------------------------
# Geometria
# --------------------------------------------------------------------------------------


def _catmull(points, radii, subdivisions):
	"""Refina una polilinea con Catmull-Rom uniforme; los radios (rn, rb) se interpolan igual."""
	n = len(points)
	out_p, out_r = [], []
	for i in range(n - 1):
		p0, p1, p2, p3 = points[max(i - 1, 0)], points[i], points[i + 1], points[min(i + 2, n - 1)]
		r0, r1, r2, r3 = (Vector(radii[max(i - 1, 0)]), Vector(radii[i]), Vector(radii[i + 1]), Vector(radii[min(i + 2, n - 1)]))
		for k in range(subdivisions + 1 if i == n - 2 else subdivisions):
			s = k / float(subdivisions)
			out_p.append(0.5 * ((2 * p1) + (-p0 + p2) * s + (2 * p0 - 5 * p1 + 4 * p2 - p3) * s * s + (-p0 + 3 * p1 - 3 * p2 + p3) * s ** 3))
			r = 0.5 * ((2 * r1) + (-r0 + r2) * s + (2 * r0 - 5 * r1 + 4 * r2 - r3) * s * s + (-r0 + 3 * r1 - 3 * r2 + r3) * s ** 3)
			out_r.append((max(r.x, 0.002), max(r.y, 0.002)))
	return out_p, out_r


class RefMesh:
	"""Acumula primitivas en una malla. Los nombres de material son los procedurales (para hornear)."""

	def __init__(self, name: str, pivot=(0.0, 0.0, 0.0)):
		self.name = name
		self.pivot = Vector(pivot)
		self.bm = bmesh.new()
		self.mat_names: list = []

	def _slot(self, mat: str) -> int:
		if mat not in self.mat_names:
			self.mat_names.append(mat)
		return self.mat_names.index(mat)

	def _tag(self, verts, mat: str, bevel: float, segments: int) -> None:
		slot = self._slot(mat)
		for face in {f for v in verts for f in v.link_faces}:
			face.material_index = slot
		if bevel > 0.0:
			edges = list({e for v in verts for e in v.link_edges})
			bmesh.ops.bevel(self.bm, geom=edges, offset=bevel, segments=segments, profile=0.55, affect="EDGES")

	def box(self, size, center, mat, rot=(0.0, 0.0, 0.0), bevel=0.0, segments=2):
		m = prim_matrix(Vector(center) - self.pivot, size, rot)
		self._tag(bmesh.ops.create_cube(self.bm, size=1.0, matrix=m)["verts"], mat, bevel, segments)

	def cyl(self, size, center, mat, top_ratio=1.0, segs=16, rot=(0.0, 0.0, 0.0), bevel=0.0, segments=2):
		"""Cilindro/tronco con eje en Y de Godot. size = (diametro_x, alto, diametro_z)."""
		m = prim_matrix(Vector(center) - self.pivot, size, rot)
		verts = bmesh.ops.create_cone(self.bm, cap_ends=True, cap_tris=False, segments=segs,
			radius1=0.5, radius2=0.5 * top_ratio, depth=1.0, matrix=m)["verts"]
		self._tag(verts, mat, bevel, segments)

	def sphere(self, size, center, mat, u=18, v=10, rot=(0.0, 0.0, 0.0)):
		m = prim_matrix(Vector(center) - self.pivot, size, rot)
		self._tag(bmesh.ops.create_uvsphere(self.bm, u_segments=u, v_segments=v, radius=0.5, matrix=m)["verts"], mat, 0.0, 1)

	def loft(self, rings, mat, cap_start=True, cap_end=True, closed=True, flip=False):
		"""Superficie por anillos (listas de Vector en coordenadas absolutas de Godot).

		Con anillos recorridos en sentido antihorario alrededor de la direccion de avance, la normal
		sale hacia fuera. closed=False deja los anillos abiertos (abrigo con frente abierto);
		flip=True invierte la orientacion (cara interior de un forro)."""
		slot = self._slot(mat)
		grid = [[self.bm.verts.new(godot_to_blender(Vector(p) - self.pivot)) for p in ring] for ring in rings]
		count = len(grid[0])
		last = count if closed else count - 1
		for i in range(len(grid) - 1):
			for j in range(last):
				quad = (grid[i][j], grid[i][(j + 1) % count], grid[i + 1][(j + 1) % count], grid[i + 1][j])
				face = self.bm.faces.new(tuple(reversed(quad)) if flip else quad)
				face.material_index = slot
		if closed and cap_start:
			self.bm.faces.new(list(grid[0]) if flip else list(reversed(grid[0]))).material_index = slot
		if closed and cap_end:
			self.bm.faces.new(list(reversed(grid[-1])) if flip else list(grid[-1])).material_index = slot

	def tube(self, points, radii, mat, segs=10, ref=(0.0, 0.0, 1.0), cap_start=True, cap_end=True, flip=False, smooth=0):
		"""Tubo a lo largo de una polilinea. radii: float o (r_n, r_b) por punto. smooth: subdivisiones Catmull-Rom."""
		pts = [Vector(p) for p in points]
		if smooth > 0:
			rad = [(r, r) if not isinstance(r, (list, tuple)) else tuple(r) for r in (radii if isinstance(radii, (list, tuple)) else [radii] * len(pts))]
			pts, radii = _catmull(pts, rad, smooth)
		rings = []
		reference = Vector(ref)
		for i, p in enumerate(pts):
			a = pts[max(i - 1, 0)]
			b = pts[min(i + 1, len(pts) - 1)]
			t = (b - a).normalized()
			r = reference if abs(t.dot(reference.normalized())) < 0.95 else Vector((1.0, 0.0, 0.0))
			n = r.cross(t).normalized()
			bn = t.cross(n).normalized()
			rad = radii[i] if isinstance(radii, (list, tuple)) else radii
			rn, rb = rad if isinstance(rad, (list, tuple)) else (rad, rad)
			rings.append([p + n * (math.cos(2 * math.pi * k / segs) * rn) + bn * (math.sin(2 * math.pi * k / segs) * rb) for k in range(segs)])
		self.loft(rings, mat, cap_start, cap_end, flip=flip)

	def quad(self, corners, mat, uvs):
		"""Cara plana con UV explicitos (para pantallas con textura). corners en Godot, en sentido antihorario."""
		slot = self._slot(mat)
		verts = [self.bm.verts.new(godot_to_blender(Vector(c) - self.pivot)) for c in corners]
		face = self.bm.faces.new(verts)
		face.material_index = slot
		layer = self.bm.loops.layers.uv.verify()
		for loop, uv in zip(face.loops, uvs):
			loop[layer].uv = uv

	def strip(self, line_a, line_b, mat):
		"""Banda de cuadrilateros entre dos polilineas de igual numero de puntos (Godot)."""
		slot = self._slot(mat)
		va = [self.bm.verts.new(godot_to_blender(Vector(p) - self.pivot)) for p in line_a]
		vb = [self.bm.verts.new(godot_to_blender(Vector(p) - self.pivot)) for p in line_b]
		for i in range(len(va) - 1):
			self.bm.faces.new((va[i], va[i + 1], vb[i + 1], vb[i])).material_index = slot

	def prism(self, profile_yz, x0, x1, mat, bevel=0.0, segments=2):
		"""Extrusion en X de un perfil (z, y) de Godot: sirve para cunas, rampas y cuerpos inclinados."""
		slot = self._slot(mat)
		left = [self.bm.verts.new(godot_to_blender(Vector((x0, y, z)) - self.pivot)) for z, y in profile_yz]
		right = [self.bm.verts.new(godot_to_blender(Vector((x1, y, z)) - self.pivot)) for z, y in profile_yz]
		count = len(left)
		faces = [self.bm.faces.new(left), self.bm.faces.new(list(reversed(right)))]
		for i in range(count):
			faces.append(self.bm.faces.new((left[i], left[(i + 1) % count], right[(i + 1) % count], right[i])))
		for f in faces:
			f.material_index = slot
		verts = left + right
		if bevel > 0.0:
			bmesh.ops.recalc_face_normals(self.bm, faces=self.bm.faces[:])
			self._tag(verts, mat, bevel, segments)

	def finish(self, mats: dict, subsurf: int = 0, sharp=True, uv=True, uv_margin=0.003, cull_down=True, recalc=True) -> bpy.types.Object:
		bm = self.bm
		if recalc:
			bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
		if cull_down: # caras que miran al suelo: nunca se ven y desperdician atlas
			hidden = [f for f in bm.faces if f.normal.z < -0.9]
			bmesh.ops.delete(bm, geom=hidden, context="FACES")
		if sharp:
			for edge in bm.edges:
				if len(edge.link_faces) == 2 and edge.calc_face_angle(0.0) > SHARP_ANGLE:
					edge.smooth = False
		for face in bm.faces:
			face.smooth = True
		mesh = bpy.data.meshes.new(self.name)
		bm.to_mesh(mesh)
		bm.free()
		obj = bpy.data.objects.new(self.name, mesh)
		obj.location = godot_to_blender(self.pivot)
		bpy.context.scene.collection.objects.link(obj)
		for mat_name in self.mat_names:
			mesh.materials.append(mats[mat_name])
		if subsurf > 0:
			modifier = obj.modifiers.new("subsurf", "SUBSURF")
			modifier.levels = subsurf
			modifier.render_levels = subsurf
			select_only(obj)
			bpy.ops.object.modifier_apply(modifier=modifier.name)
		if uv:
			smart_uv(obj, uv_margin)
		return obj


def select_only(obj) -> None:
	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.context.view_layer.objects.active = obj


def smart_uv(obj, margin: float = 0.003, angle: float = 66.0) -> None:
	select_only(obj)
	bpy.ops.object.mode_set(mode="EDIT")
	bpy.ops.mesh.select_all(action="SELECT")
	bpy.ops.uv.smart_project(angle_limit=math.radians(angle), island_margin=margin, area_weight=0.0, correct_aspect=True, scale_to_bounds=False)
	bpy.ops.object.mode_set(mode="OBJECT")


def uv_cell(obj, column: int, row: int, columns: int, rows: int, margin: float = 0.004) -> None:
	"""Reubica los UV de un objeto (ya desenvuelto a 0..1) dentro de una celda del atlas."""
	uv = obj.data.uv_layers.active.data
	xs = [d.uv.x for d in uv]
	ys = [d.uv.y for d in uv]
	span_x = max(max(xs) - min(xs), 1e-6)
	span_y = max(max(ys) - min(ys), 1e-6)
	cell_w = 1.0 / columns
	cell_h = 1.0 / rows
	scale = min((cell_w - 2 * margin) / span_x, (cell_h - 2 * margin) / span_y)
	for d in uv:
		d.uv.x = column * cell_w + margin + (d.uv.x - min(xs)) * scale
		d.uv.y = row * cell_h + margin + (d.uv.y - min(ys)) * scale


# --------------------------------------------------------------------------------------
# Materiales procedurales (solo para hornear)
# --------------------------------------------------------------------------------------


def _mix(nodes, links, fac, a, b, blend="MIX"):
	node = nodes.new("ShaderNodeMix")
	node.data_type = "RGBA"
	node.blend_type = blend
	node.inputs[0].default_value = fac if not hasattr(fac, "node") else 0.0
	if hasattr(fac, "node"):
		links.new(fac, node.inputs[0])
	for index, value in ((6, a), (7, b)):
		if hasattr(value, "node"):
			links.new(value, node.inputs[index])
		else:
			node.inputs[index].default_value = value
	return node.outputs[2]


def _math(nodes, links, op, a, b=None, clamp=False):
	node = nodes.new("ShaderNodeMath")
	node.operation = op
	node.use_clamp = clamp
	for index, value in ((0, a), (1, b)):
		if value is None:
			continue
		if hasattr(value, "node"):
			links.new(value, node.inputs[index])
		else:
			node.inputs[index].default_value = value
	return node.outputs[0]


def _ramp(nodes, links, fac, stops):
	node = nodes.new("ShaderNodeValToRGB")
	ramp = node.color_ramp
	while len(ramp.elements) > len(stops):
		ramp.elements.remove(ramp.elements[-1])
	while len(ramp.elements) < len(stops):
		ramp.elements.new(0.5)
	for element, (position, value) in zip(ramp.elements, stops):
		element.position = position
		element.color = (value, value, value, 1.0)
	links.new(fac, node.inputs[0])
	return node.outputs[0]


def _noise(nodes, links, coords, scale, detail=5.0, rough=0.55):
	node = nodes.new("ShaderNodeTexNoise")
	node.inputs["Scale"].default_value = scale
	node.inputs["Detail"].default_value = detail
	node.inputs["Roughness"].default_value = rough
	links.new(coords, node.inputs["Vector"])
	return node.outputs["Fac"]


def proc_material(name, base="808080", rough=0.6, rough_var=0.15, metal=0.0, edge_color=None, edge_amount=0.0,
		edge_radius=0.01, edge_metal=0.0, dirt_color="14110D", dirt=0.0, ao_distance=0.15, stain=0.0,
		mottle=0.15, scale=6.0, bump=0.08, bump_scale=70.0, weave=0.0, grime_height=0.0, grime=0.0,
		wet_height=0.0, wet=0.0, scratch=0.0, scratch_scale=14.0):
	"""Material PBR procedural. Expone el nodo 'metal_val' (valor de metal) para hornearlo aparte."""
	mat = bpy.data.materials.new(name)
	try:
		mat.use_nodes = True
	except Exception:
		pass
	nt = mat.node_tree
	nodes, links = nt.nodes, nt.links
	nodes.clear()
	tex = nodes.new("ShaderNodeTexCoord")
	obj = tex.outputs["Object"]
	geometry = nodes.new("ShaderNodeNewGeometry")

	mottle_n = _noise(nodes, links, obj, scale, 6.0)
	stain_n = _noise(nodes, links, obj, scale * 1.1, 7.0, 0.62)
	stain_mask = _ramp(nodes, links, stain_n, [(0.50, 0.0), (0.78, 1.0)])
	scratch_lines = None
	if scratch > 0.0: # arañazos finos y direccionales (ruido anisotropo en dos ejes), solo en parches
		layers = []
		for fast in ((1.0, 1.0, 45.0), (45.0, 1.0, 1.0)):
			mapping = nodes.new("ShaderNodeMapping")
			mapping.inputs["Scale"].default_value = fast
			links.new(obj, mapping.inputs["Vector"])
			streak = nodes.new("ShaderNodeTexNoise")
			streak.inputs["Scale"].default_value = scratch_scale * 0.35
			streak.inputs["Detail"].default_value = 2.0
			links.new(mapping.outputs["Vector"], streak.inputs["Vector"])
			layers.append(_ramp(nodes, links, streak.outputs["Fac"], [(0.488, 0.0), (0.5, 1.0), (0.512, 0.0)]))
		patch_mask = _ramp(nodes, links, stain_n, [(0.45, 0.0), (0.62, 1.0)])
		scratch_lines = _math(nodes, links, "MULTIPLY", _math(nodes, links, "MAXIMUM", layers[0], layers[1]), patch_mask)

	fine_n = _noise(nodes, links, obj, bump_scale, 4.0)

	bevel = nodes.new("ShaderNodeBevel")
	bevel.inputs["Radius"].default_value = edge_radius
	bevel.samples = 6
	dot = nodes.new("ShaderNodeVectorMath")
	dot.operation = "DOT_PRODUCT"
	links.new(bevel.outputs["Normal"], dot.inputs[0])
	links.new(geometry.outputs["Normal"], dot.inputs[1])
	edge_raw = _math(nodes, links, "SUBTRACT", 1.0, dot.outputs["Value"])
	edge = _ramp(nodes, links, edge_raw, [(0.015, 0.0), (0.12, 1.0)])

	ao_node = nodes.new("ShaderNodeAmbientOcclusion")
	ao_node.inputs["Distance"].default_value = ao_distance
	ao_node.samples = 10
	ao = ao_node.outputs["AO"]

	sep = nodes.new("ShaderNodeSeparateXYZ")
	links.new(obj, sep.inputs[0])
	height = sep.outputs["Z"]

	color = hex_lin(base)
	mottle_gray = _ramp(nodes, links, mottle_n, [(0.35, 0.78), (0.65, 1.0)])
	shaded = _mix(nodes, links, 1.0, color, mottle_gray, "MULTIPLY")
	# mottle como factor: mezclamos original y multiplicado
	color_node = _mix(nodes, links, mottle, color, shaded)
	# AO oscurece grietas
	dirt_color_lin = hex_lin(dirt_color)
	ao_dark = _math(nodes, links, "SUBTRACT", 1.0, ao)
	if dirt > 0.0:
		dirt_fac = _math(nodes, links, "MULTIPLY", ao_dark, dirt, clamp=True)
		color_node = _mix(nodes, links, dirt_fac, color_node, dirt_color_lin)
	if stain > 0.0:
		stain_fac = _math(nodes, links, "MULTIPLY", stain_mask, stain, clamp=True)
		color_node = _mix(nodes, links, stain_fac, color_node, dirt_color_lin)
	if grime > 0.0 and grime_height > 0.0:
		g = _math(nodes, links, "SUBTRACT", 1.0, _math(nodes, links, "DIVIDE", height, grime_height))
		g = _math(nodes, links, "MULTIPLY", _math(nodes, links, "MAXIMUM", g, 0.0), grime, clamp=True)
		g = _math(nodes, links, "MULTIPLY", g, _ramp(nodes, links, mottle_n, [(0.3, 0.4), (0.7, 1.0)]), clamp=True)
		color_node = _mix(nodes, links, g, color_node, dirt_color_lin)
	if edge_color and edge_amount > 0.0:
		wear = _math(nodes, links, "MULTIPLY", edge, edge_amount, clamp=True)
		wear = _math(nodes, links, "MULTIPLY", wear, _ramp(nodes, links, mottle_n, [(0.25, 0.3), (0.55, 1.0)]), clamp=True)
		color_node = _mix(nodes, links, wear, color_node, hex_lin(edge_color))
	else:
		wear = None
	if scratch > 0.0:
		scuff = _math(nodes, links, "MULTIPLY", scratch_lines, _math(nodes, links, "MULTIPLY", _ramp(nodes, links, fine_n, [(0.35, 0.0), (0.6, 1.0)]), scratch), clamp=True)
		color_node = _mix(nodes, links, scuff, color_node, hex_lin(edge_color or base))
	# rugosidad
	rough_node = _math(nodes, links, "ADD", rough, _math(nodes, links, "MULTIPLY", _math(nodes, links, "SUBTRACT", mottle_n, 0.5), rough_var))
	if wear is not None:
		rough_node = _math(nodes, links, "ADD", _math(nodes, links, "MULTIPLY", rough_node, _math(nodes, links, "SUBTRACT", 1.0, _math(nodes, links, "MULTIPLY", wear, 0.5))), _math(nodes, links, "MULTIPLY", wear, 0.15))
	if wet > 0.0 and wet_height > 0.0:
		w = _math(nodes, links, "SUBTRACT", 1.0, _math(nodes, links, "DIVIDE", height, wet_height))
		w = _math(nodes, links, "MULTIPLY", _math(nodes, links, "MAXIMUM", w, 0.0), _ramp(nodes, links, stain_n, [(0.4, 0.0), (0.6, 1.0)]), clamp=True)
		w = _math(nodes, links, "MULTIPLY", w, wet, clamp=True)
		rough_node = _math(nodes, links, "SUBTRACT", rough_node, _math(nodes, links, "MULTIPLY", w, 0.45))
		color_node = _mix(nodes, links, _math(nodes, links, "MULTIPLY", w, 0.5), color_node, hex_lin("0B0D0F"))
	rough_node = _math(nodes, links, "MAXIMUM", _math(nodes, links, "MINIMUM", rough_node, 0.98), 0.12)
	# metal
	metal_node = metal if wear is None or edge_metal <= 0.0 else _math(nodes, links, "ADD", metal, _math(nodes, links, "MULTIPLY", wear, edge_metal), clamp=True)
	metal_out = _math(nodes, links, "ADD", metal_node, 0.0, clamp=True) if hasattr(metal_node, "node") else _math(nodes, links, "ADD", metal_node, 0.0)
	metal_out.node.name = "metal_val"
	# relieve
	height_in = fine_n
	if scratch > 0.0:
		height_in = _math(nodes, links, "SUBTRACT", fine_n, _math(nodes, links, "MULTIPLY", scratch_lines, 0.6))
	if weave > 0.0:
		checker = nodes.new("ShaderNodeTexChecker")
		checker.inputs["Scale"].default_value = bump_scale * 1.6
		links.new(obj, checker.inputs["Vector"])
		height_in = _math(nodes, links, "ADD", _math(nodes, links, "MULTIPLY", fine_n, 1.0 - weave), _math(nodes, links, "MULTIPLY", checker.outputs["Fac"], weave))
	bump_node = nodes.new("ShaderNodeBump")
	bump_node.inputs["Strength"].default_value = bump
	bump_node.inputs["Distance"].default_value = 0.01
	links.new(height_in, bump_node.inputs["Height"])

	principled = nodes.new("ShaderNodeBsdfPrincipled")
	links.new(color_node, principled.inputs["Base Color"])
	links.new(rough_node, principled.inputs["Roughness"])
	links.new(metal_out, principled.inputs["Metallic"])
	links.new(bump_node.outputs["Normal"], principled.inputs["Normal"])
	output = nodes.new("ShaderNodeOutputMaterial")
	links.new(principled.outputs["BSDF"], output.inputs["Surface"])
	return mat


# --------------------------------------------------------------------------------------
# Horneado
# --------------------------------------------------------------------------------------


def _set_target(mat, image) -> None:
	nodes = mat.node_tree.nodes
	node = nodes.get("bake_target")
	if node is None:
		node = nodes.new("ShaderNodeTexImage")
		node.name = "bake_target"
	node.image = image
	nodes.active = node


def _bake_pass(objects, bake_type, image, margin, **kwargs) -> None:
	scene = bpy.context.scene
	for index, obj in enumerate(objects):
		for mat in obj.data.materials:
			_set_target(mat, image)
		select_only(obj)
		bpy.ops.object.bake(type=bake_type, margin=margin, margin_type="EXTEND", use_clear=(index == 0), **kwargs)


def _swap_metal(materials, restore=False, store={}) -> None:
	for mat in materials:
		nodes, links = mat.node_tree.nodes, mat.node_tree.links
		output = next(n for n in nodes if n.type == "OUTPUT_MATERIAL")
		if not restore:
			original = output.inputs["Surface"].links[0].from_socket
			store[mat.name] = original
			emission = nodes.new("ShaderNodeEmission")
			emission.name = "metal_emit"
			links.new(nodes["metal_val"].outputs[0], emission.inputs["Color"])
			links.new(emission.outputs["Emission"], output.inputs["Surface"])
		else:
			links.new(store[mat.name], output.inputs["Surface"])
			nodes.remove(nodes["metal_emit"])


def bake_atlas(objects, asset: str, size: int, tex_dir: str, samples: int = 24, margin: int = DEFAULT_MARGIN, size_y: int = 0):
	"""Hornea albedo, normal y ORM de `objects` en un atlas comun y escribe los PNG."""
	scene = bpy.context.scene
	scene.render.engine = "CYCLES"
	scene.cycles.device = "CPU"
	scene.cycles.samples = samples
	scene.cycles.use_denoising = False
	height = size_y or size
	images = {}
	for kind in ("albedo", "normal", "rough", "ao", "metal"):
		image = bpy.data.images.new("%s_%s" % (asset, kind), size, height, alpha=False)
		image.colorspace_settings.name = "sRGB" if kind == "albedo" else "Non-Color"
		images[kind] = image
	materials = []
	for obj in objects:
		for mat in obj.data.materials:
			if mat not in materials:
				materials.append(mat)
	_bake_pass(objects, "DIFFUSE", images["albedo"], margin, pass_filter={"COLOR"})
	_bake_pass(objects, "NORMAL", images["normal"], margin, normal_space="TANGENT")
	_bake_pass(objects, "ROUGHNESS", images["rough"], margin)
	_bake_pass(objects, "AO", images["ao"], margin)
	_swap_metal(materials)
	_bake_pass(objects, "EMIT", images["metal"], margin)
	_swap_metal(materials, restore=True)

	os.makedirs(tex_dir, exist_ok=True)
	paths = {}
	count = size * height * 4
	channel = {}
	for kind in ("rough", "ao", "metal"):
		buffer = np.empty(count, dtype=np.float32)
		images[kind].pixels.foreach_get(buffer)
		channel[kind] = buffer.reshape(-1, 4)[:, 0]
	orm = np.ones((size * height, 4), dtype=np.float32)
	orm[:, 0] = channel["ao"]
	orm[:, 1] = channel["rough"]
	orm[:, 2] = channel["metal"]
	orm_image = bpy.data.images.new("%s_orm" % asset, size, height, alpha=False)
	orm_image.colorspace_settings.name = "Non-Color"
	orm_image.pixels.foreach_set(orm.reshape(-1))
	for kind, image in (("albedo", images["albedo"]), ("normal", images["normal"]), ("orm", orm_image)):
		path = os.path.join(tex_dir, "%s_%s.png" % (asset, kind))
		image.filepath_raw = path
		image.file_format = "PNG"
		image.save()
		paths[kind] = path
	return paths


def finalize_materials(objects, final_name: str, keep=()):
	"""Sustituye los materiales procedurales por uno final (por nombre) y reasigna los poligonos.

	keep: nombres de material que se conservan tal cual (p. ej. emisivos con su propio .tres)."""
	dummy_cache = {}

	def dummy(name):
		if name not in dummy_cache:
			material = bpy.data.materials.new(name)
			dummy_cache[name] = material
		return dummy_cache[name]

	for obj in objects:
		mesh = obj.data
		old = [m.name if m else "" for m in mesh.materials]
		targets = [n if n in keep else final_name for n in old]
		unique = []
		for n in targets:
			if n not in unique:
				unique.append(n)
		indices = np.zeros(len(mesh.polygons), dtype=np.int32)
		mesh.polygons.foreach_get("material_index", indices)
		remap = np.array([unique.index(t) for t in targets], dtype=np.int32)
		mesh.polygons.foreach_set("material_index", remap[indices])
		mesh.materials.clear()
		for n in unique:
			mesh.materials.append(dummy(n))


# --------------------------------------------------------------------------------------
# Materiales de Godot (.tres)
# --------------------------------------------------------------------------------------


def write_pbr_tres(path: str, asset: str, tex_res: str, emission_color=None, emission_energy=0.0, cull=True) -> None:
	"""StandardMaterial3D con albedo, normal y ORM (AO=R, rugosidad=G, metal=B)."""
	os.makedirs(os.path.dirname(path), exist_ok=True)
	text = (
		'[gd_resource type="StandardMaterial3D" load_steps=4 format=3]\n\n'
		'[ext_resource type="Texture2D" path="%(r)s/%(a)s_albedo.png" id="1"]\n'
		'[ext_resource type="Texture2D" path="%(r)s/%(a)s_normal.png" id="2"]\n'
		'[ext_resource type="Texture2D" path="%(r)s/%(a)s_orm.png" id="3"]\n\n'
		'[resource]\n'
		'resource_name = "%(a)s"\n'
		'albedo_texture = ExtResource("1")\n'
		'metallic = 1.0\n'
		'metallic_texture = ExtResource("3")\n'
		'metallic_texture_channel = 2\n'
		'roughness = 1.0\n'
		'roughness_texture = ExtResource("3")\n'
		'roughness_texture_channel = 1\n'
		'normal_enabled = true\n'
		'normal_texture = ExtResource("2")\n'
		'ao_enabled = true\n'
		'ao_texture = ExtResource("3")\n'
		'ao_texture_channel = 0\n'
	) % {"r": tex_res, "a": asset}
	with open(path, "w", encoding="utf-8", newline="\n") as handle:
		handle.write(text)


def _color_literal(hex_value: str) -> str:
	r, g, b = (int(hex_value[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
	return "Color(%.4f, %.4f, %.4f, 1)" % (r, g, b)


def write_emissive_tres(path: str, name: str, albedo_hex: str, emission_hex: str, energy: float, emission_texture_res: str = "") -> None:
	os.makedirs(os.path.dirname(path), exist_ok=True)
	lines = ['[gd_resource type="StandardMaterial3D" load_steps=%d format=3]' % (3 if emission_texture_res else 2), ""]
	if emission_texture_res:
		lines += ['[ext_resource type="Texture2D" path="%s" id="1"]' % emission_texture_res, ""]
	lines += ["[resource]", 'resource_name = "%s"' % name, "albedo_color = %s" % _color_literal(albedo_hex), "roughness = 0.3",
		"emission_enabled = true", "emission = %s" % _color_literal(emission_hex), "emission_energy_multiplier = %.3f" % energy]
	if emission_texture_res:
		lines.append('emission_texture = ExtResource("1")')
	with open(path, "w", encoding="utf-8", newline="\n") as handle:
		handle.write("\n".join(lines) + "\n")


# --------------------------------------------------------------------------------------
# Ejecucion comun
# --------------------------------------------------------------------------------------


def repo_paths(options: dict) -> dict:
	root = os.path.abspath(options["repo"])
	return {
		"glb": os.path.join(root, "assets", "models", "lab_ref"),
		"tex": os.path.join(root, "assets", "textures", "lab_ref"),
		"mat": os.path.join(root, "assets", "materials", "lab_ref"),
		"tex_res": "res://assets/textures/lab_ref",
	}


def common_args(extra=None) -> dict:
	options = {"repo": None, "blend-dir": None, "samples": "24"}
	options.update(extra or {})
	parse_args(options)
	if not options["repo"]:
		raise SystemExit("falta --repo")
	return options


def save_blend(options: dict, name: str) -> None:
	if options.get("blend-dir"):
		os.makedirs(options["blend-dir"], exist_ok=True)
		path = os.path.join(os.path.abspath(options["blend-dir"]), name)
		bpy.ops.wm.save_as_mainfile(filepath=path)
		print("[blend] " + path)


def save_rgb_png(array_rgb, path, colorspace="sRGB"):
	"""Guarda una matriz (alto, ancho, 3) con valores 0..1 (fila 0 = arriba) como PNG."""
	height, width, _ = array_rgb.shape
	image = bpy.data.images.new(os.path.basename(path), width, height, alpha=False)
	image.colorspace_settings.name = colorspace
	rgba = np.ones((height, width, 4), dtype=np.float32)
	rgba[:, :, :3] = np.flipud(array_rgb)
	image.pixels.foreach_set(rgba.reshape(-1))
	os.makedirs(os.path.dirname(path), exist_ok=True)
	image.filepath_raw = path
	image.file_format = "PNG"
	image.save()
