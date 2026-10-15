"""Elena v2: modelled backpack, coat pockets and shoulder yoke, outfit atlas bake, head materials, GLB export.

    blender -b --python tools/blender/elena_mpfb/bake_elena_v2.py -- --repo D:/Projects/github/final-thaw \
        --src D:/Projects/evidence/final-thaw/elena_v2/elena_v2_assembled.blend \
        --anim D:/Projects/evidence/final-thaw/elena_v2/elena_v2_actions.blend --out D:/Projects/evidence/final-thaw/elena_v2 [--samples 12]

Input: build_elena_v2.py output. --anim is a .blend whose actions (on the same 53-bone rig) are exported with the model; without it
the GLB has no animations. Output: assets/models/characters/elena/elena.glb, its textures in assets/textures/characters/elena and the
Godot materials in assets/materials/characters/elena (resolved by imported material name in elena_controller.gd).

Design (docs/art/ASSET_PRODUCTION_BIBLE.md, "Elena v2"): long dark-teal field coat with lighter grey-teal shoulder yoke, light
reflective piping on the front edges and cuffs, flapped hip pockets; charcoal knit and cargo trousers; dark green-teal rubber boots;
dark-teal daypack with grey-teal lid and side pockets, black webbing, tools in the right pocket and an amber beacon on the left
shoulder (the only warm accent on her, as in the concept). Uniform roughness is avoided: rubber, tape, webbing and fabric differ.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "reference"))
sys.path.insert(0, os.path.join(HERE, ".."))

import bmesh  # noqa: E402
import bpy  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402

from bake_elena import assign_coat_piping, fit_uv_to_rect, limit_influences  # noqa: E402
from lab_blender_common import parse_args  # noqa: E402
from ref_common import bake_atlas, finalize_materials, proc_material, select_only, smart_uv, write_pbr_tres  # noqa: E402

ASSET = "elena_outfit"
ATLAS = 2048
RECTS = {  # (u0, v0, u1, v1) in square-ish cells; the coat and the backpack (always in view from the gameplay camera) get 1024 px
	"Elena_Coat": (0.0, 0.5, 0.5, 1.0),
	"Backpack": (0.5, 0.0, 1.0, 0.5),
	"Elena_Trousers": (0.0, 0.0, 0.25, 0.5),
	"Elena_Boots": (0.25, 0.0, 0.5, 0.5),
	"Elena_Knit": (0.5, 0.75, 0.75, 1.0),
	"Elena_Strap_L": (0.5, 0.5, 0.75, 0.75),
	"Elena_Strap_R": (0.5, 0.5, 0.75, 0.75),
	"Elena_Pockets": (0.75, 0.875, 0.875, 1.0),
	"Elena_Tape": (0.875, 0.75, 1.0, 1.0),
	"Aster": (0.75, 0.75, 0.875, 0.875),
}
HEAD_MATERIALS = {"Elena_Base": "elena_skin", "Elena_Eyes": "elena_eyes", "Elena_Eyebrows": "elena_brows",
	"Elena_Eyelashes": "elena_lashes", "Elena_HairMH": "elena_hair"}
# yoke: lighter panel over the shoulders, front and back, down to these heights (Blender world, -Y = front)
YOKE_FRONT_Z = 1.36
YOKE_BACK_Z = 1.31
YOKE_CAP_X = 0.165
COLLAR_Z = 1.47


def cloth(name, base, **kw):
	args = dict(rough=0.84, rough_var=0.1, dirt=0.5, ao_distance=0.05, stain=0.2, mottle=0.22, scale=9.0, bump=0.45,
		bump_scale=120.0, weave=0.55, grime_height=0.9, grime=0.4, scratch=0.0)
	args.update(kw)
	return proc_material(name, base=base, **args)


def outfit_materials():
	return {
		"coat": cloth("coat", "273F41", edge_color="4C6668", edge_amount=0.35, edge_radius=0.012, grime_height=1.1, grime=0.45),
		"piping": proc_material("piping", base="A2AEAC", rough=0.36, rough_var=0.12, edge_color="C9D3D1", edge_amount=0.3,
			edge_radius=0.004, dirt=0.45, ao_distance=0.03, stain=0.25, mottle=0.2, scale=20.0, bump=0.25, bump_scale=170.0),
		"yoke": cloth("yoke", "5A7072", edge_color="7A9092", edge_amount=0.3, edge_radius=0.01, grime=0.2),
		"knit": cloth("knit", "28292B", rough=0.94, weave=0.88, bump=0.75, bump_scale=200.0, grime=0.1, stain=0.1),
		"trousers": cloth("trousers", "34373A", rough=0.9, weave=0.4, bump_scale=130.0, grime_height=0.6, grime=0.6, stain=0.3),
		"boot": proc_material("boot", base="1E2C2B", rough=0.4, rough_var=0.2, edge_color="56706C", edge_amount=0.45, edge_radius=0.006,
			dirt=0.6, ao_distance=0.04, stain=0.4, mottle=0.3, scale=14.0, bump=0.3, bump_scale=120.0, grime_height=0.3, grime=0.85,
			scratch=0.45, scratch_scale=16.0),
		"strap": cloth("strap", "1A1C1D", rough=0.82, weave=0.75, bump_scale=220.0, grime=0.2),
		"pack": cloth("pack", "2A4345", edge_color="47605F", edge_amount=0.4, edge_radius=0.01, grime_height=1.0, grime=0.25),
		"pack_panel": cloth("pack_panel", "566C6D", edge_color="768C8C", edge_amount=0.35, edge_radius=0.008, grime=0.2),
		"metal": proc_material("metal", base="8B8F91", rough=0.38, rough_var=0.15, metal=1.0, edge_color="B8BBBC", edge_amount=0.4,
			edge_radius=0.003, dirt=0.4, ao_distance=0.02, mottle=0.25, scale=30.0, bump=0.1, bump_scale=200.0, scratch=0.5),
		"plastic": proc_material("plastic", base="1D2123", rough=0.55, rough_var=0.12, edge_color="3A3F42", edge_amount=0.35,
			edge_radius=0.003, dirt=0.3, ao_distance=0.02, mottle=0.15, scale=25.0, bump=0.08, bump_scale=160.0),
	}


# --- modelling helpers ----------------------------------------------------------------------------------------------

def rounded_box(name, size, centre, bevel, segments=3, material_index=0, rotation=(0.0, 0.0, 0.0)):
	mesh = bpy.data.meshes.new(name)
	bm = bmesh.new()
	bmesh.ops.create_cube(bm, size=1.0)
	bmesh.ops.scale(bm, vec=Vector(size), verts=bm.verts)
	bmesh.ops.bevel(bm, geom=list(bm.edges), offset=bevel, segments=segments, profile=0.5, affect="EDGES", clamp_overlap=True)
	for face in bm.faces:
		face.material_index = material_index
		face.smooth = True
	bm.to_mesh(mesh)
	bm.free()
	obj = bpy.data.objects.new(name, mesh)
	bpy.context.scene.collection.objects.link(obj)
	obj.location = centre
	obj.rotation_euler = rotation
	return obj


def cylinder(name, radius, depth, centre, material_index=0, rotation=(0.0, 0.0, 0.0), segments=16):
	mesh = bpy.data.meshes.new(name)
	bm = bmesh.new()
	bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=segments, radius1=radius, radius2=radius, depth=depth)
	for face in bm.faces:
		face.material_index = material_index
		face.smooth = len(face.verts) == 4
	bm.to_mesh(mesh)
	bm.free()
	obj = bpy.data.objects.new(name, mesh)
	bpy.context.scene.collection.objects.link(obj)
	obj.location = centre
	obj.rotation_euler = rotation
	return obj


def dome(name, radius, centre, material_index=0):
	mesh = bpy.data.meshes.new(name)
	bm = bmesh.new()
	bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=8, radius=radius)
	bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < -1e-4], context="VERTS")
	for face in bm.faces:
		face.material_index = material_index
		face.smooth = True
	bm.to_mesh(mesh)
	bm.free()
	obj = bpy.data.objects.new(name, mesh)
	bpy.context.scene.collection.objects.link(obj)
	obj.location = centre
	return obj


def join(objects, name):
	bpy.ops.object.select_all(action="DESELECT")
	for obj in objects:
		obj.select_set(True)
	bpy.context.view_layer.objects.active = objects[0]
	bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
	bpy.ops.object.join()
	result = bpy.context.view_layer.objects.active
	result.name = name
	result.data.name = name
	return result


def build_backpack(rig):
	"""Daypack (Blender world): x = Elena's left, +y = her back. Sits where the v1 pack sat (spine_03), 0.30 x 0.17 x 0.42 m body."""
	parts = []
	body = rounded_box("pack_body", (0.30, 0.17, 0.42), (0.0, 0.158, 1.13), 0.05, 4, 0)
	# a little fuller at the outer face, as a loaded bag is
	for v in body.data.vertices:
		if v.co.y > 0.0:
			k = max(0.0, 1.0 - (abs(v.co.x) / 0.15) ** 2) * max(0.0, 1.0 - (abs(v.co.z) / 0.21) ** 2)
			v.co.y += 0.018 * k
	parts.append(body)
	parts.append(rounded_box("pack_lid", (0.31, 0.19, 0.075), (0.0, 0.166, 1.352), 0.032, 3, 1))
	parts.append(rounded_box("pack_lid_lip", (0.25, 0.03, 0.06), (0.0, 0.262, 1.315), 0.012, 2, 1))
	parts.append(rounded_box("pack_front_pocket", (0.22, 0.055, 0.20), (0.0, 0.262, 1.02), 0.022, 3, 0))
	for side in (-1.0, 1.0):
		parts.append(rounded_box("pack_side_pocket", (0.05, 0.125, 0.17), (side * 0.168, 0.162, 0.995), 0.018, 2, 1))
		# compression strap and buckle across each side
		parts.append(rounded_box("pack_side_strap", (0.012, 0.15, 0.022), (side * 0.153, 0.16, 1.2), 0.004, 1, 2))
	for z in (1.1, 1.24):  # horizontal compression straps over the outer face
		parts.append(rounded_box("pack_strap", (0.305, 0.008, 0.024), (0.0, 0.252, z), 0.003, 1, 2))
		parts.append(rounded_box("pack_buckle", (0.035, 0.012, 0.03), (0.07, 0.258, z), 0.004, 1, 3))
	parts.append(rounded_box("pack_handle", (0.07, 0.02, 0.012), (0.0, 0.12, 1.4), 0.005, 1, 2))
	# tools in the right side pocket: an adjustable wrench and pliers handles (the concept's back view)
	wrench = rounded_box("tool_wrench", (0.012, 0.028, 0.16), (-0.178, 0.135, 1.1), 0.004, 1, 3, rotation=(0.18, 0.0, 0.0))
	jaw = rounded_box("tool_wrench_jaw", (0.012, 0.05, 0.03), (-0.178, 0.122, 1.18), 0.004, 1, 3, rotation=(0.18, 0.0, 0.0))
	parts += [wrench, jaw]
	for dy in (-0.012, 0.012):
		parts.append(cylinder("tool_pliers", 0.0055, 0.13, (-0.18, 0.19 + dy, 1.08), 3, rotation=(-0.12 + dy * 4.0, 0.0, 0.0), segments=8))
	# amber beacon on the left shoulder of the pack
	parts.append(cylinder("beacon_base", 0.024, 0.02, (0.118, 0.098, 1.392), 4, segments=16))
	lens = dome("beacon_lens", 0.021, (0.118, 0.098, 1.402), 5)
	parts.append(lens)
	pack = join(parts, "Backpack")
	materials = ["pack", "pack_panel", "strap", "metal", "plastic", "beacon"]
	return pack, materials


def build_wrist_unit(coat, rig):
	"""The Aster field scanner as a wrist unit on the back of Elena's LEFT forearm (owner direction 2026-10-15: never stuck
	to her hand). A rugged housing strapped over the coat sleeve, the screen on the dorsal side (it faces her when she
	raises the forearm palm-down, see animate_elena_v2.py "scan"), a short emitter at the wrist end. Placement follows the
	rest pose: along the forearm bone at 72 %, on the sleeve surface found by a ray cast from the lateral side.
	Returns (housing+straps object "Aster", screen object "emit_aster"), both parented to lowerarm_l."""
	bone = rig.data.bones["lowerarm_l"]
	head, tail = rig.matrix_world @ bone.head_local, rig.matrix_world @ bone.tail_local
	axis = (tail - head).normalized()
	lateral = Vector((1.0, 0.0, 0.2))
	n = (lateral - axis * lateral.dot(axis)).normalized()  # dorsal (back of the forearm in the A-pose)
	bvec = axis.cross(n).normalized()
	depsgraph = bpy.context.evaluated_depsgraph_get()
	to_local = coat.matrix_world.inverted()

	def sleeve_radius(t):
		c = head.lerp(tail, t)
		best = 0.045
		hit, loc, _, _ = coat.ray_cast(to_local @ (c + n * 0.3), to_local.to_3x3() @ (-n), depsgraph=depsgraph)
		if hit:
			best = ((coat.matrix_world @ loc) - c).length
		return c, best

	centre, radius = sleeve_radius(0.72)
	frame = Matrix((n, axis, bvec)).transposed().to_4x4()  # local X = dorsal normal, Y = along the forearm, Z = across
	housing_centre = centre + n * (radius + 0.013)
	parts = []
	housing = rounded_box("wrist_housing", (0.026, 0.105, 0.068), (0.0, 0.0, 0.0), 0.007, 2, 0)
	housing.matrix_world = Matrix.Translation(housing_centre) @ frame
	parts.append(housing)
	bezel = rounded_box("wrist_bezel", (0.006, 0.092, 0.058), (0.0, 0.0, 0.0), 0.002, 1, 1)
	bezel.matrix_world = Matrix.Translation(housing_centre + n * 0.0135) @ frame
	parts.append(bezel)
	emitter = cylinder("wrist_emitter", 0.009, 0.022, (0.0, 0.0, 0.0), 2, segments=10)
	emitter.matrix_world = Matrix.Translation(housing_centre + axis * 0.06 + n * 0.004) @ frame @ Matrix.Rotation(1.5708, 4, "X")
	parts.append(emitter)
	for t in (0.6, 0.86):  # straps around the sleeve
		c, r = sleeve_radius(t)
		ring = bpy.data.meshes.new("wrist_strap")
		bm = bmesh.new()
		ring_r = r + 0.004
		segs = 16
		inner = []
		outer = []
		for k in range(segs):
			a = 6.2832 * k / segs
			d = n * math.cos(a) + bvec * math.sin(a)
			for side, lst in ((-0.009, inner), (0.009, outer)):
				lst.append(bm.verts.new(c + axis * side + d * ring_r))
		for k in range(segs):
			j = (k + 1) % segs
			bm.faces.new((inner[k], inner[j], outer[j], outer[k]))
		for f in bm.faces:
			f.material_index = 3
			f.smooth = True
		bm.to_mesh(ring)
		bm.free()
		obj = bpy.data.objects.new("wrist_strap", ring)
		bpy.context.scene.collection.objects.link(obj)
		parts.append(obj)
	unit = join(parts, "Aster")
	# the screen: a quad on the bezel, own emissive material (ref_elena_aster), UVs 0..1 for its interface texture
	mesh = bpy.data.meshes.new("emit_aster")
	bm = bmesh.new()
	sc = housing_centre + n * 0.0168
	corners = [sc - axis * 0.042 - bvec * 0.026, sc + axis * 0.042 - bvec * 0.026, sc + axis * 0.042 + bvec * 0.026, sc - axis * 0.042 + bvec * 0.026]
	vs = [bm.verts.new(c) for c in corners]
	face = bm.faces.new(vs)
	if face.normal.dot(n) < 0.0:
		face.normal_flip()
	uv = bm.loops.layers.uv.new("UVMap")
	for loop, co in zip(face.loops, ((0, 0), (1, 0), (1, 1), (0, 1))):
		loop[uv].uv = co
	bm.to_mesh(mesh)
	bm.free()
	screen = bpy.data.objects.new("emit_aster", mesh)
	bpy.context.scene.collection.objects.link(screen)
	for obj in (unit, screen):
		world = obj.matrix_world.copy()
		obj.parent = rig
		obj.parent_type = "BONE"
		obj.parent_bone = "lowerarm_l"
		obj.matrix_world = world
	return unit, screen


def build_pockets(coat, rig):
	"""Flapped hip pockets conformed to the coat front (ray casts), skinned from the coat."""
	depsgraph = bpy.context.evaluated_depsgraph_get()
	to_local = coat.matrix_world.inverted()
	bm = bmesh.new()

	def surface(x, z, offset):
		ok, loc, normal, _ = coat.ray_cast(to_local @ Vector((x, -2.0, z)), to_local.to_3x3() @ Vector((0.0, 1.0, 0.0)), depsgraph=depsgraph)
		if not ok:
			return None
		world = coat.matrix_world @ loc
		n = (coat.matrix_world.to_3x3() @ normal).normalized()
		if n.y > 0.0:
			n = -n
		return world + n * offset

	def patch(cx, x_half, z0, z1, offset, thickness, material_index, nx=6, nz=6):
		grid = []
		for iz in range(nz + 1):
			row = []
			for ix in range(nx + 1):
				p = surface(cx + x_half * (2.0 * ix / nx - 1.0), z0 + (z1 - z0) * iz / nz, offset)
				row.append(p)
			grid.append(row)
		if any(p is None for row in grid for p in row):
			return
		front = [[bm.verts.new(p) for p in row] for row in grid]
		back = [[bm.verts.new(p + Vector((0.0, thickness, 0.0))) for p in row] for row in grid]
		faces = []
		for iz in range(nz):
			for ix in range(nx):
				faces.append(bm.faces.new((front[iz][ix], front[iz][ix + 1], front[iz + 1][ix + 1], front[iz + 1][ix])))
		# closed rim so the patch has thickness at the silhouette
		ring = [front[0][i] for i in range(nx + 1)] + [front[i][nx] for i in range(1, nz + 1)]
		ring += [front[nz][i] for i in range(nx - 1, -1, -1)] + [front[i][0] for i in range(nz - 1, 0, -1)]
		ring_b = [back[0][i] for i in range(nx + 1)] + [back[i][nx] for i in range(1, nz + 1)]
		ring_b += [back[nz][i] for i in range(nx - 1, -1, -1)] + [back[i][0] for i in range(nz - 1, 0, -1)]
		for i in range(len(ring)):
			j = (i + 1) % len(ring)
			faces.append(bm.faces.new((ring[i], ring_b[i], ring_b[j], ring[j])))
		for f in faces:
			f.material_index = material_index
			f.smooth = True

	for side in (-1.0, 1.0):
		patch(side * 0.095, 0.05, 0.80, 0.95, 0.004, 0.004, 0)    # pocket bag (front panel spans |x| 0.04..0.18 at the hips)
		patch(side * 0.095, 0.056, 0.94, 0.985, 0.009, 0.004, 0)  # flap, proud of the bag
	bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
	mesh = bpy.data.meshes.new("Elena_Pockets")
	bm.to_mesh(mesh)
	bm.free()
	pockets = bpy.data.objects.new("Elena_Pockets", mesh)
	bpy.context.scene.collection.objects.link(pockets)
	# skin weights from the coat
	transfer = pockets.modifiers.new("weights", "DATA_TRANSFER")
	transfer.object = coat
	transfer.use_vert_data = True
	transfer.data_types_verts = {"VGROUP_WEIGHTS"}
	transfer.vert_mapping = "POLYINTERP_NEAREST"
	select_only(pockets)
	bpy.ops.object.datalayout_transfer(modifier="weights")
	bpy.ops.object.modifier_apply(modifier="weights")
	pockets.parent = rig
	arm = pockets.modifiers.new("Armature", "ARMATURE")
	arm.object = rig
	return pockets


def add_yoke_mask(material, yoke_hex):
	"""Mix the lighter shoulder yoke into the coat's base colour with a smooth mask in object space (Blender axes, -Y front):
	front panel above YOKE_FRONT_Z, back panel above YOKE_BACK_Z, shoulder caps beyond YOKE_CAP_X; never the collar."""
	from ref_common import hex_lin
	nodes, links = material.node_tree.nodes, material.node_tree.links
	principled = next(n for n in nodes if n.type == "BSDF_PRINCIPLED")
	base_link = principled.inputs["Base Color"].links[0]
	coord = next(n for n in nodes if n.type == "TEX_COORD")
	sep = nodes.new("ShaderNodeSeparateXYZ")
	links.new(coord.outputs["Object"], sep.inputs[0])

	def step(value, edge, width=0.006):
		node = nodes.new("ShaderNodeMapRange")
		node.interpolation_type = "SMOOTHSTEP"
		node.inputs["From Min"].default_value = edge - width
		node.inputs["From Max"].default_value = edge + width
		links.new(value, node.inputs["Value"])
		return node.outputs["Result"]

	def math(op, a, b):
		node = nodes.new("ShaderNodeMath")
		node.operation = op
		for i, v in enumerate((a, b)):
			if isinstance(v, float):
				node.inputs[i].default_value = v
			else:
				links.new(v, node.inputs[i])
		return node.outputs["Value"]

	z, x, y = sep.outputs["Z"], sep.outputs["X"], sep.outputs["Y"]
	front = step(math("MULTIPLY", y, -1.0), 0.0, 0.01)  # 1 at the front, 0 at the back
	panel = math("ADD", math("MULTIPLY", front, step(z, YOKE_FRONT_Z)), math("MULTIPLY", math("SUBTRACT", 1.0, front), step(z, YOKE_BACK_Z)))
	panel = math("MULTIPLY", panel, step(math("ABSOLUTE", x, 0.0), 0.04, 0.004))
	cap = math("MULTIPLY", step(math("ABSOLUTE", x, 0.0), YOKE_CAP_X), step(z, 1.3))
	mask = math("MULTIPLY", math("MAXIMUM", panel, cap), math("SUBTRACT", 1.0, step(z, COLLAR_Z)))
	mix = nodes.new("ShaderNodeMix")
	mix.data_type = "RGBA"
	col_in = [sock for sock in mix.inputs if sock.type == "RGBA"]
	col_out = next(sock for sock in mix.outputs if sock.type == "RGBA")
	links.new(mask, next(sock for sock in mix.inputs if sock.name == "Factor" and sock.type == "VALUE"))
	links.new(base_link.from_socket, col_in[0])
	col_in[1].default_value = hex_lin(yoke_hex)
	links.new(col_out, principled.inputs["Base Color"])


def assign_cuffs(coat):
	"""Piping material (index 1) only on the cuff bands; the front edges get a real tape strip (build_tape)."""
	assign_coat_piping(coat)
	front = 0
	for poly in coat.data.polygons:
		if poly.material_index == 1 and abs((coat.matrix_world @ poly.center).x) < 0.25:
			poly.material_index = 0
			front += 1
	print("[v2bake] front piping faces handed to the tape strip: %d" % front)


def build_tape(coat, rig):
	"""Reflective tape along both front edges, from the hem to the collar: a ribbon 2.2 cm wide laid on the coat surface just
	inside the opening (ray casts from the front), 2 mm proud, skinned from the coat."""
	import numpy as np
	depsgraph = bpy.context.evaluated_depsgraph_get()
	to_local = coat.matrix_world.inverted()
	bm_src = bmesh.new()
	bm_src.from_mesh(coat.data)
	edge = [coat.matrix_world @ v.co for v in bm_src.verts if any(e.is_boundary for e in v.link_edges)]
	bm_src.free()
	front = [p for p in edge if p.y < 0.02 and abs(p.x) < 0.14 and 0.55 < p.z < 1.47]
	bins = {}
	for p in front:
		bins.setdefault(round(p.z / 0.03), []).append(abs(p.x))
	keys = sorted(bins)
	zs = [k * 0.03 for k in keys]
	xs = [float(np.median(bins[k])) for k in keys]
	# light smoothing of the edge line so the tape runs straight
	xs = [float(np.mean(xs[max(0, i - 1):i + 2])) for i in range(len(xs))]

	def surface(x, z, offset=0.002):
		ok, loc, normal, _ = coat.ray_cast(to_local @ Vector((x, -2.0, z)), to_local.to_3x3() @ Vector((0.0, 1.0, 0.0)), depsgraph=depsgraph)
		if not ok:
			return None
		n = (coat.matrix_world.to_3x3() @ normal).normalized()
		if n.y > 0.0:
			n = -n
		return coat.matrix_world @ loc + n * offset

	bm = bmesh.new()
	for side in (-1.0, 1.0):
		rows = []
		for z, x in zip(zs, xs):
			if z > 1.44:
				continue
			inner = surface(side * (x + 0.003), z)
			outer = surface(side * (x + 0.025), z)
			if inner is not None and outer is not None:
				rows.append((bm.verts.new(inner), bm.verts.new(outer)))
		for (a0, b0), (a1, b1) in zip(rows, rows[1:]):
			face = bm.faces.new((a0, b0, b1, a1) if side > 0 else (a0, a1, b1, b0))
			face.smooth = True
	bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
	for face in bm.faces:
		if face.normal.y > 0.0:
			face.normal_flip()
	mesh = bpy.data.meshes.new("Elena_Tape")
	bm.to_mesh(mesh)
	bm.free()
	tape = bpy.data.objects.new("Elena_Tape", mesh)
	bpy.context.scene.collection.objects.link(tape)
	transfer = tape.modifiers.new("weights", "DATA_TRANSFER")
	transfer.object = coat
	transfer.use_vert_data = True
	transfer.data_types_verts = {"VGROUP_WEIGHTS"}
	transfer.vert_mapping = "POLYINTERP_NEAREST"
	select_only(tape)
	bpy.ops.object.datalayout_transfer(modifier="weights")
	bpy.ops.object.modifier_apply(modifier="weights")
	tape.parent = rig
	tape.modifiers.new("Armature", "ARMATURE").object = rig
	print("[v2bake] tape: %d faces" % len(mesh.polygons))
	return tape


def set_materials(obj, mats):
	obj.data.materials.clear()
	for mat in mats:
		obj.data.materials.append(mat)


def unwrap(obj, rect):
	while obj.data.uv_layers:
		obj.data.uv_layers.remove(obj.data.uv_layers[0])
	obj.data.uv_layers.new(name="UVMap")
	smart_uv(obj, margin=0.004, angle=66.0)
	select_only(obj)
	bpy.ops.object.mode_set(mode="EDIT")
	bpy.ops.mesh.select_all(action="SELECT")
	bpy.ops.uv.select_all(action="SELECT")
	bpy.ops.uv.pack_islands(rotate=True, margin=0.006)
	bpy.ops.object.mode_set(mode="OBJECT")
	fit_uv_to_rect(obj, rect)


def write_text(path, text):
	os.makedirs(os.path.dirname(path), exist_ok=True)
	with open(path, "w", encoding="utf-8", newline="\n") as handle:
		handle.write(text)


def illustrate_tres(path, albedo, painted):
	"""Illustrated style (ASSET_PRODUCTION_BIBLE.md): toon diffuse/specular and the painted albedo from
	tools/art/stylize_textures.py (run it after this bake)."""
	text = open(path, encoding="utf-8").read().replace(albedo, painted)
	if "diffuse_mode" not in text:
		text = text.replace("[resource]\n", "[resource]\ndiffuse_mode = 3\nspecular_mode = 1\n", 1)
	write_text(path, text)


def write_head_materials(mat_dir, tex_res):
	"""Godot StandardMaterial3D resources for the MakeHuman head parts (textures from tools/art/prepare_elena_textures.py)."""
	write_text(os.path.join(mat_dir, "elena_skin.tres"), (
		'[gd_resource type="StandardMaterial3D" load_steps=3 format=3]\n\n'
		'[ext_resource type="Texture2D" path="%(r)s/elena_skin_albedo_paint.jpg" id="1"]\n'
		'[ext_resource type="Texture2D" path="%(r)s/elena_skin_normal.png" id="2"]\n\n'
		'[resource]\nresource_name = "elena_skin"\ndiffuse_mode = 3\nspecular_mode = 1\nalbedo_color = Color(0.93, 0.9, 0.88, 1)\nalbedo_texture = ExtResource("1")\n'
		'roughness = 0.6\nmetallic_specular = 0.4\nnormal_enabled = true\nnormal_scale = 0.45\nnormal_texture = ExtResource("2")\n'
		'rim_enabled = true\nrim = 0.05\nrim_tint = 0.3\n') % {"r": tex_res})
	write_text(os.path.join(mat_dir, "elena_eyes.tres"), (
		'[gd_resource type="StandardMaterial3D" load_steps=2 format=3]\n\n'
		'[ext_resource type="Texture2D" path="%(r)s/elena_eyes_albedo.png" id="1"]\n\n'
		'[resource]\nresource_name = "elena_eyes"\nalbedo_texture = ExtResource("1")\nroughness = 0.12\nmetallic_specular = 0.7\n') % {"r": tex_res})
	for name, tex, cull in (("elena_brows", "elena_brows_albedo.png", 2), ("elena_lashes", "elena_lashes_albedo.png", 2)):
		write_text(os.path.join(mat_dir, name + ".tres"), (
			'[gd_resource type="StandardMaterial3D" load_steps=2 format=3]\n\n'
			'[ext_resource type="Texture2D" path="%(r)s/%(t)s" id="1"]\n\n'
			'[resource]\nresource_name = "%(n)s"\ntransparency = 1\ncull_mode = %(c)d\nalbedo_texture = ExtResource("1")\n'
			'roughness = 0.75\n') % {"r": tex_res, "t": tex, "n": name, "c": cull})
	write_text(os.path.join(mat_dir, "elena_hair.tres"), (
		'[gd_resource type="StandardMaterial3D" load_steps=2 format=3]\n\n'
		'[ext_resource type="Texture2D" path="%(r)s/elena_hair_albedo.png" id="1"]\n\n'
		'[resource]\nresource_name = "elena_hair"\ntransparency = 4\nalpha_scissor_threshold = 0.4\ncull_mode = 2\n'
		'albedo_texture = ExtResource("1")\nroughness = 0.52\nmetallic_specular = 0.35\n'
		'rim_enabled = true\nrim = 0.25\nrim_tint = 0.8\n') % {"r": tex_res})
	write_text(os.path.join(mat_dir, "elena_beacon.tres"), (
		'[gd_resource type="StandardMaterial3D" format=3]\n\n'
		'[resource]\nresource_name = "elena_beacon"\nalbedo_color = Color(0.85, 0.42, 0.08, 1)\nroughness = 0.25\n'
		'emission_enabled = true\nemission = Color(1, 0.48, 0.1, 1)\nemission_energy_multiplier = 1.6\n'))


def main():
	options = {"repo": None, "src": None, "anim": "", "out": None, "samples": "12"}
	parse_args(options)
	repo = os.path.abspath(options["repo"])
	tex_dir = os.path.join(repo, "assets", "textures", "characters", "elena")
	mat_dir = os.path.join(repo, "assets", "materials", "characters", "elena")
	tex_res = "res://assets/textures/characters/elena"
	glb_path = os.path.join(repo, "assets", "models", "characters", "elena", "elena.glb")
	bpy.ops.wm.open_mainfile(filepath=options["src"])
	rig = bpy.data.objects["Elena_Base.rig"]
	coat = bpy.data.objects["Elena_Coat"]

	# accessories: the v1 backpack (280 boxes) is replaced; the Aster scanner keeps its shape with a real material
	old_pack = bpy.data.objects["Backpack"]
	pack_parent_bone = old_pack.parent_bone
	bpy.data.objects.remove(old_pack)
	pack, pack_mats = build_backpack(rig)
	world = pack.matrix_world.copy()
	pack.parent = rig
	pack.parent_type = "BONE"
	pack.parent_bone = pack_parent_bone
	pack.matrix_world = world
	pockets = build_pockets(coat, rig)
	tape = build_tape(coat, rig)
	for name in ("Aster", "emit_aster"):  # v1 hand-held scanner, replaced by the wrist unit
		if name in bpy.data.objects:
			bpy.data.objects.remove(bpy.data.objects[name])
	wrist, wrist_screen = build_wrist_unit(coat, rig)

	mats = outfit_materials()
	beacon = proc_material("elena_beacon", base="D9771A", rough=0.25, mottle=0.05)  # baked too (harmless), kept by name
	add_yoke_mask(mats["coat"], "5A7072")
	set_materials(coat, [mats["coat"], mats["piping"]])
	assign_cuffs(coat)
	set_materials(pockets, [mats["coat"]])
	set_materials(tape, [mats["piping"]])
	set_materials(pack, [mats[m] if m in mats else beacon for m in pack_mats])
	for name, key in (("Elena_Knit", "knit"), ("Elena_Trousers", "trousers"), ("Elena_Boots", "boot"), ("Elena_Strap_L", "strap"),
			("Elena_Strap_R", "strap")):
		set_materials(bpy.data.objects[name], [mats[key]])
	set_materials(wrist, [mats["plastic"], mats["metal"], mats["plastic"], mats["strap"]])
	baked = [bpy.data.objects[name] for name in RECTS]
	for obj in baked:
		unwrap(obj, RECTS[obj.name])
	bpy.context.view_layer.update()
	# the beacon lens is not baked (own emissive material); hide its faces from the bake by keeping its material out of the atlas
	bake_atlas(baked, ASSET, ATLAS, tex_dir, samples=int(options["samples"]), margin=8)
	finalize_materials(baked, ASSET, keep=("elena_beacon",))
	write_pbr_tres(os.path.join(mat_dir, ASSET + ".tres"), ASSET, tex_res)
	illustrate_tres(os.path.join(mat_dir, ASSET + ".tres"), "elena_outfit_albedo.png", "elena_outfit_albedo_paint.png")

	for obj_name, mat_name in HEAD_MATERIALS.items():
		obj = bpy.data.objects[obj_name]
		obj.data.materials.clear()
		obj.data.materials.append(bpy.data.materials.new(mat_name))
	wrist_screen.data.materials.clear()
	wrist_screen.data.materials.append(bpy.data.materials.new("ref_elena_aster"))
	write_head_materials(mat_dir, tex_res)

	if options["anim"]:
		with bpy.data.libraries.load(options["anim"], link=False) as (src, dst):
			dst.actions = list(src.actions)
		for action in bpy.data.actions:
			action.use_fake_user = True
		print("[v2bake] actions: %s" % [a.name for a in bpy.data.actions])
	meshes = [o for o in bpy.data.objects if o.type == "MESH"]
	limit_influences([o for o in meshes if o.vertex_groups])
	bpy.ops.object.select_all(action="DESELECT")
	for obj in meshes + [rig]:
		obj.select_set(True)
	os.makedirs(os.path.dirname(glb_path), exist_ok=True)
	bpy.ops.export_scene.gltf(filepath=glb_path, export_format="GLB", use_selection=True, export_yup=True, export_skins=True,
		export_apply=False, export_materials="EXPORT", export_image_format="NONE", export_animations=bool(options["anim"]),
		export_animation_mode="ACTIONS", export_force_sampling=True, export_optimize_animation_size=False)
	print("[v2bake] -> " + glb_path)
	tris = 0
	depsgraph = bpy.context.evaluated_depsgraph_get()
	for obj in meshes:
		m = obj.evaluated_get(depsgraph).to_mesh()
		m.calc_loop_triangles()
		tris += len(m.loop_triangles)
		obj.evaluated_get(depsgraph).to_mesh_clear()
	print("[v2bake] triangles %d" % tris)
	bpy.ops.wm.save_as_mainfile(filepath=os.path.join(os.path.abspath(options["out"]), "elena_v2_baked.blend"))


if __name__ == "__main__":
	main()
