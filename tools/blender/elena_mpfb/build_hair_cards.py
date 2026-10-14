"""Elena's hair cards: ribbons that follow the skull from the hairline / part to the nape, then down the ponytail.

Run in the live Blender session after build_clothes.py (needs Elena_Base, the rig and the ponytail geometry):  exec(open(path).read())
Deterministic (seeded). The mesh uses the `elena_hair_cards` material (alpha-scissor strand texture, see make_hair_card_texture.py).
"""
import math
import random

import bmesh
import bpy
from mathutils import Vector

body = bpy.data.objects['Elena_Base']
rig = body.parent
if 'Elena_HairCards' in bpy.data.objects:
	bpy.data.objects.remove(bpy.data.objects['Elena_HairCards'])

CENTER = Vector((0.0, 0.01, 1.585))
GROUPS = 'head'
rng = random.Random(11)

# ponytail axis (same construction as build_clothes.py)
_back = body.ray_cast(Vector((0, 1, 1.58)), Vector((0, -1, 0)))
_y0 = (_back[1].y if _back[0] else 0.085) - 0.004
PONY = [Vector((0, _y0 + dy, z)) for dy, z in ((0, 1.575), (0.018, 1.540), (0.030, 1.490), (0.034, 1.440), (0.034, 1.395), (0.030, 1.365))]
PONY_R = [0.018, 0.026, 0.027, 0.023, 0.014, 0.004]
NAPE = Vector((0.0, _y0 - 0.004, 1.585))

depsgraph = bpy.context.evaluated_depsgraph_get()


def skull_point(direction, lift):
	"""Point on the skull along `direction` from the head centre, lifted `lift` along the surface normal; returns (point, normal)."""
	d = direction.normalized()
	ok, loc, normal, _ = body.ray_cast(CENTER + d * 0.4, -d, depsgraph=depsgraph)
	if not ok:
		return CENTER + d * 0.1, d
	return loc + normal * lift, normal


def head_path(root_dir, side, lift, samples=7):
	"""Great-circle-ish sweep from a root direction on the skull to the nape, lifted off the surface."""
	target = NAPE - CENTER
	target.x = side * 0.012
	pts, nrm = [], []
	for i in range(samples):
		t = i / (samples - 1)
		# ease so strands bunch toward the nape
		d = root_dir.lerp(target, t ** 0.9)
		p, n = skull_point(d, lift + 0.004 * t)
		pts.append(p)
		nrm.append(n)
	return pts, nrm


def pony_path(phi, spread):
	pts, nrm = [], []
	for c, r in zip(PONY, PONY_R):
		radial = Vector((math.cos(phi), math.sin(phi) * 0.9, 0.0))
		pts.append(c + radial * (r * spread + 0.004))
		nrm.append(radial.normalized())
	return pts, nrm


def ribbon(bm, pts, nrm, widths, u0, u1):
	"""Quad strip along pts; width direction = tangent x normal."""
	rows = []
	n = len(pts)
	for i, (p, nv, w) in enumerate(zip(pts, nrm, widths)):
		tangent = (pts[min(i + 1, n - 1)] - pts[max(i - 1, 0)]).normalized()
		side = tangent.cross(nv).normalized()
		rows.append((bm.verts.new(p - side * w * 0.5), bm.verts.new(p + side * w * 0.5), i / (n - 1)))
	uv_layer = bm.loops.layers.uv.verify()
	for (a0, b0, v0), (a1, b1, v1) in zip(rows, rows[1:]):
		face = bm.faces.new((a0, b0, b1, a1))
		for loop, (u, v) in zip(face.loops, ((u0, v0), (u1, v0), (u1, v1), (u0, v1))):
			loop[uv_layer].uv = (u, v)
		face.smooth = True


bm = bmesh.new()
bm.loops.layers.uv.new('UVMap')

# layer A: strips rooted along the hairline (front centre -> temple -> above the ear), one set per side
for side in (-1, 1):
	for k in range(12):
		theta = math.radians(6 + k * 8.6)
		dz = 0.058 - 0.020 * (k / 11.0)
		root = Vector((side * math.sin(theta) * 0.10, -math.cos(theta) * 0.12, dz))
		for copy in range(2):
			jitter = Vector((rng.uniform(-0.004, 0.004), rng.uniform(-0.004, 0.004), rng.uniform(-0.003, 0.003)))
			pts, nrm = head_path(root + jitter, side, 0.018 + 0.004 * copy)
			ppts, pnrm = pony_path(rng.uniform(0, math.tau), rng.uniform(0.85, 1.1))
			path, normals = pts + ppts[1:], nrm + pnrm[1:]
			count = len(path)
			widths = [0.030 * (1.0 - 0.55 * (i / (count - 1)) ** 1.5) for i in range(count)]
			u0 = rng.uniform(0.0, 0.7)
			ribbon(bm, path, normals, widths, u0, u0 + 0.28)

# layer B: strips from the centre parting (front to crown), sweeping back over layer A; two copies so the crown is covered
for side in (-1, 1):
	for k in range(8):
		for copy in range(2):
			y = -0.078 + k * 0.014 + copy * 0.006
			root = Vector((side * (0.010 + 0.012 * copy), y - CENTER.y, 0.108))
			pts, nrm = head_path(root, side, 0.025 + 0.004 * copy)
			ppts, pnrm = pony_path(rng.uniform(0, math.tau), rng.uniform(0.9, 1.15))
			path, normals = pts + ppts[1:], nrm + pnrm[1:]
			count = len(path)
			widths = [0.028 * (1.0 - 0.6 * (i / (count - 1)) ** 1.5) for i in range(count)]
			u0 = rng.uniform(0.0, 0.7)
			ribbon(bm, path, normals, widths, u0, u0 + 0.28)

# layer C: extra strips on the ponytail itself so it reads as a bunch, not a tube
for k in range(14):
	ppts, pnrm = pony_path(math.tau * k / 14 + rng.uniform(-0.15, 0.15), rng.uniform(0.9, 1.2))
	widths = [0.022 * (1.0 - 0.7 * (i / (len(ppts) - 1)) ** 1.4) for i in range(len(ppts))]
	u0 = rng.uniform(0.0, 0.7)
	ribbon(bm, ppts, pnrm, widths, u0, u0 + 0.28)

mesh = bpy.data.meshes.new('Elena_HairCards')
bm.to_mesh(mesh)
bm.free()
obj = bpy.data.objects.new('Elena_HairCards', mesh)
bpy.context.scene.collection.objects.link(obj)
vg = obj.vertex_groups.new(name=GROUPS)
vg.add(list(range(len(mesh.vertices))), 1.0, 'REPLACE')
obj.parent = rig
mod = obj.modifiers.new('Armature', 'ARMATURE')
mod.object = rig
print('hair cards: tris', len(mesh.polygons) * 2, 'verts', len(mesh.vertices))
