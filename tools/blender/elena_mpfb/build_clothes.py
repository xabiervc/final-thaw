"""Fitted garments for Elena from the rigged base (run after build_base.py in the same Blender session)."""
import importlib
import math
import os
import sys

import bpy
from mathutils import Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)) if '__file__' in globals() else 'D:/Projects/github/final-thaw/tools/blender/elena_mpfb')
import garments  # noqa: E402

importlib.reload(garments)

body = bpy.data.objects['Elena_Base']
rig = body.parent
for name in ('Elena_Coat', 'Elena_Knit'):
	if name in bpy.data.objects:
		bpy.data.objects.remove(bpy.data.objects[name])

TORSO = ('spine_', 'clavicle_', 'pelvis')
ARM = ('upperarm_', 'lowerarm_')
WRIST_T = 0.93


def wrist_param(co, bone):
	"""0..1 position along the lowerarm bone; >WRIST_T means beyond the cuff."""
	side = bone[-1]
	bn = rig.data.bones['lowerarm_' + side]
	axis = bn.tail_local - bn.head_local
	return (co - bn.head_local).dot(axis) / axis.length_squared


def keep_coat(co, bone, bmv):
	if bone is None:
		return False
	if bone.startswith(TORSO) or bone.startswith('thigh_'):
		if co.z < 0.90 or co.z > 1.50:
			return False
		if abs(co.x) < 0.012 and co.y < 0.0 and co.z < 1.46:
			return False  # open front
		return True
	if bone.startswith(ARM) or bone.startswith('hand_'):
		return True
	if bone.startswith('neck_'):
		return co.z < 1.52
	return False


def coat_thickness(co, _):
	# straighter silhouette than the body: extra ease over the chest and hips
	return 0.022 if abs(co.x) > 0.19 else 0.032


def wrist_cuts():
	cuts = []
	for side in ('l', 'r'):
		bn = rig.data.bones['lowerarm_' + side]
		axis = (bn.tail_local - bn.head_local).normalized()
		cuts.append((bn.head_local + (bn.tail_local - bn.head_local) * WRIST_T, -axis))
	return cuts


coat = garments.region_object(body, 'Elena_Coat', keep_coat, coat_thickness, smooth_iters=4, pre_smooth=2,
	local_smooth=(lambda c: c.y < 0.0 and 1.05 < c.z < 1.48 and abs(c.x) < 0.2, 30),
	cuts=[(Vector((0, 0, 0.93)), Vector((0, 0, 1)))] + wrist_cuts())
print('coat verts', len(coat.data.vertices))


def tint(obj, rgba):
	obj.color = rgba


bpy.context.scene.display.shading.color_type = 'OBJECT'


def flare_hem(obj, z_hem=0.93, steps=6, dz=0.065, sx=1.035, sy=1.02):
	"""Extrude the coat's lower boundary downward into a long skirt with a slight A-line flare."""
	import bmesh
	bm = bmesh.new()
	bm.from_mesh(obj.data)
	loop = [e for e in bm.edges if e.is_boundary and all(v.co.z < z_hem + 0.04 for v in e.verts)]
	for _ in range(steps):
		res = bmesh.ops.extrude_edge_only(bm, edges=loop)
		new_verts = [g for g in res['geom'] if isinstance(g, bmesh.types.BMVert)]
		new_edges = [g for g in res['geom'] if isinstance(g, bmesh.types.BMEdge) and g.is_boundary]
		for v in new_verts:
			v.co.z -= dz
			v.co.x *= sx
			v.co.y *= sy
		loop = new_edges
	bm.normal_update()
	bm.to_mesh(obj.data)
	bm.free()


flare_hem(coat)

for name in ('Elena_Knit', 'Elena_Trousers', 'Elena_Boots'):
	if name in bpy.data.objects:
		bpy.data.objects.remove(bpy.data.objects[name])


def keep_knit(co, bone, bmv):
	if bone is None:
		return False
	if bone.startswith(TORSO) or bone.startswith('neck_'):
		return 0.80 < co.z < 1.53
	return False


knit = garments.region_object(body, 'Elena_Knit', keep_knit, lambda co, _: 0.007 if co.z < 1.46 else 0.016, smooth_iters=3,
	local_smooth=(lambda c: c.y < 0.0 and 1.05 < c.z < 1.48 and abs(c.x) < 0.2, 6))


def keep_trousers(co, bone, bmv):
	if bone is None:
		return False
	if bone.startswith(('thigh_', 'calf_', 'spine_01')) or bone == 'pelvis':
		return 0.34 < co.z < 1.02
	return False


trousers = garments.region_object(body, 'Elena_Trousers', keep_trousers, lambda co, _: 0.012 if co.z > 0.5 else 0.016, smooth_iters=3,
	cuts=[(Vector((0, 0, 0.38)), Vector((0, 0, 1)))])


def keep_boots(co, bone, bmv):
	return co.z < 0.5  # geometric: every vertex of the lower leg and foot, toes and heel included


boots = garments.region_object(body, 'Elena_Boots', keep_boots, lambda co, _: 0.016 + (0.006 if co.z < 0.05 else 0.0), smooth_iters=5,
	cuts=[(Vector((0, 0, 0.46)), Vector((0, 0, -1)))],
	local_smooth=(lambda c: c.z < 0.12, 45))

for _obj, _off in ((coat, 0.018), (knit, 0.006), (trousers, 0.006), (boots, 0.010)):
	garments.fit_outside(_obj, body, _off)

tint(coat, (0.16, 0.36, 0.38, 1))
tint(knit, (0.14, 0.15, 0.16, 1))
tint(trousers, (0.20, 0.22, 0.24, 1))
tint(boots, (0.08, 0.16, 0.17, 1))
tint(body, (0.82, 0.62, 0.52, 1))
print({o.name: len(o.data.vertices) for o in (coat, knit, trousers, boots)})


# ---------------------------------------------------------------- hair
for name in ('Elena_Hair', 'Elena_Ponytail', 'Elena_Brows', 'Elena_Eye_L', 'Elena_Eye_R'):
	if name in bpy.data.objects:
		bpy.data.objects.remove(bpy.data.objects[name])


HAIRLINE_NORMAL = Vector((0.0, 0.14, 0.175)).normalized()


def hairline(y):
	if y < -0.06:
		return 1.655
	if y < 0.03:
		return 1.655 - (y + 0.06) / 0.09 * 0.055
	return 1.600 - min((y - 0.03) / 0.06, 1.0) * 0.060


def keep_scalp(co, bone, bmv):
	if bone is None or not bone.startswith(('head', 'neck_')):
		return False
	if abs(co.x) > 0.072 and -0.04 < co.y < 0.05 and co.z < 1.668:
		return False  # leave the ears uncovered
	return co.z > hairline(co.y)


def make_hair_shell():
	"""Scalp region of the body, subdivided once and wrapped 14 mm above the skull."""
	import bmesh
	obj = garments.region_object(body, 'Elena_Hair', lambda co, bone, v: bone is not None and bone.startswith(('head', 'neck_')) and co.z > 1.50,
		0.0, smooth_iters=0)
	bm = bmesh.new()
	bm.from_mesh(obj.data)
	bmesh.ops.subdivide_edges(bm, edges=list(bm.edges), cuts=2, use_grid_fill=True)
	bmesh.ops.delete(bm, geom=[v for v in bm.verts if not keep_scalp(v.co, 'head', v)], context='VERTS')
	bm.to_mesh(obj.data)
	bm.free()
	mod = obj.modifiers.new('Wrap', 'SHRINKWRAP')
	mod.target = body
	mod.wrap_method = 'NEAREST_SURFACEPOINT'
	mod.wrap_mode = 'ABOVE_SURFACE'
	mod.offset = 0.014
	obj.modifiers.move(len(obj.modifiers) - 1, 0)
	garments.apply_modifier_stack_to_mesh(obj)
	for poly in obj.data.polygons:
		poly.use_smooth = True
	return obj


hair = make_hair_shell()
tint(hair, (0.14, 0.09, 0.07, 1))
print('hair verts', len(hair.data.vertices))


# ---------------------------------------------------------------- ponytail, eyes, brows
def make_tube(name, path, radii, segs=10, group='head'):
	"""Closed-ended tube following `path` (list of Vector) with per-point radius; fully weighted to `group`."""
	import bmesh
	mesh = bpy.data.meshes.new(name)
	bm = bmesh.new()
	rings = []
	for i, (p, r) in enumerate(zip(path, radii)):
		t = (path[min(i + 1, len(path) - 1)] - path[max(i - 1, 0)]).normalized()
		side = t.cross(Vector((1, 0, 0))).normalized() if abs(t.x) < 0.9 else Vector((0, 1, 0))
		up = t.cross(side).normalized()
		rings.append([bm.verts.new(p + (side * math.cos(a) + up * math.sin(a)) * r)
			for a in (2 * math.pi * k / segs for k in range(segs))])
	for ring_a, ring_b in zip(rings, rings[1:]):
		for k in range(segs):
			bm.faces.new((ring_a[k], ring_a[(k + 1) % segs], ring_b[(k + 1) % segs], ring_b[k]))
	bm.faces.new(rings[0][::-1])
	bm.faces.new(rings[-1])
	bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
	bm.to_mesh(mesh)
	bm.free()
	obj = bpy.data.objects.new(name, mesh)
	bpy.context.scene.collection.objects.link(obj)
	vg = obj.vertex_groups.new(name=group)
	vg.add(list(range(len(mesh.vertices))), 1.0, 'REPLACE')
	obj.parent = rig
	mod = obj.modifiers.new('Armature', 'ARMATURE')
	mod.object = rig
	for poly in mesh.polygons:
		poly.use_smooth = True
	return obj


_back = body.ray_cast(Vector((0, 1, 1.58)), Vector((0, -1, 0)))
_y0 = (_back[1].y if _back[0] else 0.085) - 0.004
pony = make_tube('Elena_Ponytail',
	[Vector((0, _y0 + dy, z)) for dy, z in ((0, 1.575), (0.018, 1.540), (0.030, 1.490), (0.034, 1.440), (0.034, 1.395), (0.030, 1.365))],
	[0.018, 0.026, 0.027, 0.023, 0.014, 0.004])
tint(pony, (0.14, 0.09, 0.07, 1))

EYE_X, EYE_Z, EYE_RADIUS = 0.0304, 1.580, 0.0125
for side, sx in (('L', 1), ('R', -1)):
	hit = body.ray_cast(Vector((sx * EYE_X, -1, EYE_Z)), Vector((0, 1, 0)))
	eye_y = hit[1].y + 0.011 if hit[0] else -0.088
	bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=EYE_RADIUS, location=(sx * EYE_X, eye_y, EYE_Z),
		rotation=(math.pi / 2, 0, 0))
	eye = bpy.context.object
	eye.name = 'Elena_Eye_' + side
	bpy.ops.object.shade_smooth()
	vg = eye.vertex_groups.new(name='head')
	vg.add(list(range(len(eye.data.vertices))), 1.0, 'REPLACE')
	eye.parent = rig
	mod = eye.modifiers.new('Armature', 'ARMATURE')
	mod.object = rig
	tint(eye, (0.9, 0.9, 0.9, 1))


# ---------------------------------------------------------------- brows
for side, sx in (('L', 1), ('R', -1)):
	pts = []
	for x, z in ((0.010, 1.606), (0.026, 1.613), (0.042, 1.612), (0.056, 1.604)):
		hit = body.ray_cast(Vector((sx * x, -1, z)), Vector((0, 1, 0)))
		pts.append(Vector((sx * x, (hit[1].y if hit[0] else -0.1) + 0.0015, z)))
	brow = make_tube('Elena_Brow_' + side, pts, [0.0035, 0.0048, 0.0046, 0.0022], segs=6)
	brow.scale.y = 0.5
	tint(brow, (0.12, 0.08, 0.06, 1))


# ---------------------------------------------------------------- strip the body hidden under clothes (keep head, neck, hands)
def strip_covered_body():
	import bmesh
	bm = bmesh.new()
	bm.from_mesh(body.data)
	dom = garments.dominant_bones(body)
	keep_bones = ('head', 'neck_', 'hand_', 'index_', 'middle_', 'pinky_', 'ring_', 'thumb_')
	doomed = [v for v in bm.verts if not (dom[v.index] or '').startswith(keep_bones)]
	bmesh.ops.delete(bm, geom=doomed, context='VERTS')
	bm.to_mesh(body.data)
	bm.free()
