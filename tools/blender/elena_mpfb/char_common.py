"""Shared character-building helpers for the MPFB pipeline (Marcus; Elena's scripts predate it and keep their own copies).

Used from a live Blender session with MPFB enabled. Not run on its own.
"""
import math

import bmesh
import bpy
from mathutils import Vector

import garments

MPFB_TARGETS = bpy.utils.user_resource('EXTENSIONS') + '/blender_org/mpfb/data/targets'


def build_character(prefix, macro, face, target_height):
	"""MPFB base + face targets + game_engine rig (snapped to the mesh), shape keys baked, helpers stripped. Returns (body, rig)."""
	from bl_ext.blender_org.mpfb.services.humanservice import HumanService
	from bl_ext.blender_org.mpfb.services.targetservice import TargetService
	for obj in list(bpy.data.objects):
		if obj.type not in ('CAMERA', 'LIGHT'):
			bpy.data.objects.remove(obj)
	data = TargetService.get_default_macro_info_dict()
	data.update(macro)
	body = HumanService.create_human(mask_helpers=False, detailed_helpers=False, extra_vertex_groups=True, feet_on_ground=True,
		scale=0.1, macro_detail_dict=data)
	body.name = prefix + '_Base'
	bpy.context.view_layer.objects.active = body
	for key, weight in face.items():
		folder, name = key.split('/')
		TargetService.load_target(body, f'{MPFB_TARGETS}/{folder}/{name}.target.gz', weight=weight)
	rig = HumanService.add_builtin_rig(body, 'game_engine', import_weights=True)
	bpy.context.view_layer.update()
	depsgraph = bpy.context.evaluated_depsgraph_get()
	top = max(v.co.z for v in body.evaluated_get(depsgraph).data.vertices)
	dz = top - (rig.matrix_world @ rig.data.bones['head'].tail_local).z
	bpy.ops.object.select_all(action='DESELECT')
	bpy.context.view_layer.objects.active = rig
	rig.select_set(True)
	bpy.ops.object.mode_set(mode='EDIT')
	for bone in rig.data.edit_bones:
		bone.head.z += dz
		bone.tail.z += dz
	bpy.ops.object.mode_set(mode='OBJECT')
	bpy.context.view_layer.objects.active = body
	body.select_set(True)
	bpy.ops.object.shape_key_remove(all=True, apply_mix=True)
	bpy.context.view_layer.objects.active = body
	body.select_set(True)
	bpy.ops.object.mode_set(mode='EDIT')
	bpy.ops.mesh.select_all(action='DESELECT')
	for name in ('HelperGeometry', 'JointCubes'):
		body.vertex_groups.active_index = body.vertex_groups[name].index
		bpy.ops.object.vertex_group_select()
	bpy.ops.mesh.delete(type='VERT')
	bpy.ops.object.mode_set(mode='OBJECT')
	height = max(v.co.z for v in body.data.vertices)
	print('character', prefix, 'height', round(height, 3), 'target', target_height)
	return body, rig


def bone_pos(rig, name, tail=False):
	bone = rig.data.bones[name]
	return rig.matrix_world @ (bone.tail_local if tail else bone.head_local)


def skin_to(obj, rig, group, weight=1.0):
	"""Parent to the rig and bind the whole object to one bone group."""
	vg = obj.vertex_groups.get(group) or obj.vertex_groups.new(name=group)
	vg.add(list(range(len(obj.data.vertices))), weight, 'REPLACE')
	obj.parent = rig
	mod = obj.modifiers.new('Armature', 'ARMATURE')
	mod.object = rig


def make_box(name, size, center, rig, group, bevel=0.004, collection=None):
	"""Rounded box (size = x, y, z full extents) skinned to one bone."""
	bm = bmesh.new()
	bmesh.ops.create_cube(bm, size=1.0)
	for v in bm.verts:
		v.co = Vector((v.co.x * size[0], v.co.y * size[1], v.co.z * size[2])) + Vector(center)
	if bevel:
		bmesh.ops.bevel(bm, geom=list(bm.edges), offset=bevel, segments=2, affect='EDGES')
	mesh = bpy.data.meshes.new(name)
	bm.to_mesh(mesh)
	bm.free()
	for poly in mesh.polygons:
		poly.use_smooth = True
	obj = bpy.data.objects.new(name, mesh)
	(collection or bpy.context.scene.collection).objects.link(obj)
	skin_to(obj, rig, group)
	return obj


def make_tube(name, rig, path, radii, segs=8, group='head', closed_loop=False):
	"""Tube along `path` with per-point radius, skinned to one bone. closed_loop joins the last ring to the first (belts)."""
	mesh = bpy.data.meshes.new(name)
	bm = bmesh.new()
	rings = []
	count = len(path)
	for i, (p, r) in enumerate(zip(path, radii)):
		nxt = path[(i + 1) % count] if closed_loop else path[min(i + 1, count - 1)]
		prv = path[(i - 1) % count] if closed_loop else path[max(i - 1, 0)]
		t = (nxt - prv).normalized()
		side = t.cross(Vector((0, 0, 1))).normalized() if abs(t.z) < 0.9 else Vector((1, 0, 0))
		up = t.cross(side).normalized()
		rings.append([bm.verts.new(p + (side * math.cos(a) + up * math.sin(a)) * r) for a in (2 * math.pi * k / segs for k in range(segs))])
	pairs = list(zip(rings, rings[1:] + ([rings[0]] if closed_loop else [])))
	for ring_a, ring_b in pairs:
		for k in range(segs):
			bm.faces.new((ring_a[k], ring_a[(k + 1) % segs], ring_b[(k + 1) % segs], ring_b[k]))
	if not closed_loop:
		bm.faces.new(rings[0][::-1])
		bm.faces.new(rings[-1])
	bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
	bm.to_mesh(mesh)
	bm.free()
	for poly in mesh.polygons:
		poly.use_smooth = True
	obj = bpy.data.objects.new(name, mesh)
	bpy.context.scene.collection.objects.link(obj)
	skin_to(obj, rig, group)
	return obj


def make_eyes(prefix, body, rig, x, z, radius=0.0125):
	eyes = []
	for side, sx in (('L', 1), ('R', -1)):
		hit = body.ray_cast(Vector((sx * x, -1, z)), Vector((0, 1, 0)))
		y = hit[1].y + 0.011 if hit[0] else -0.088
		bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=radius, location=(sx * x, y, z), rotation=(math.pi / 2, 0, 0))
		eye = bpy.context.object
		eye.name = f'{prefix}_Eye_{side}'
		bpy.ops.object.shade_smooth()
		skin_to(eye, rig, 'head')
		eyes.append(eye)
	return eyes


def make_brows(prefix, body, rig, z, xs=(0.010, 0.026, 0.042, 0.056), dz=(0.0, 0.007, 0.006, -0.002), radius=(0.0045, 0.0062, 0.0058, 0.003)):
	brows = []
	for side, sx in (('L', 1), ('R', -1)):
		pts = []
		for x, off in zip(xs, dz):
			hit = body.ray_cast(Vector((sx * x, -1, z + off)), Vector((0, 1, 0)))
			pts.append(Vector((sx * x, (hit[1].y if hit[0] else -0.1) + 0.0015, z + off)))
		brow = make_tube(f'{prefix}_Brow_{side}', rig, pts, list(radius), segs=6)
		brow.scale.y = 0.5
		brows.append(brow)
	return brows


def make_hair_shell(name, body, rig, hairline, keep_ear, offset=0.012, cuts=3):
	"""Scalp region of `body`, subdivided and wrapped `offset` above the skull. hairline(y) -> z; keep_ear(co) -> False near the ears."""
	obj = garments.region_object(body, name, lambda co, bone, v: bone is not None and bone.startswith(('head', 'neck_')) and co.z > hairline(0.0) - 0.2,
		0.0, smooth_iters=0)
	bm = bmesh.new()
	bm.from_mesh(obj.data)
	bmesh.ops.subdivide_edges(bm, edges=list(bm.edges), cuts=cuts, use_grid_fill=True)
	bmesh.ops.delete(bm, geom=[v for v in bm.verts if not (v.co.z > hairline(v.co.y) and keep_ear(v.co))], context='VERTS')
	bm.to_mesh(obj.data)
	bm.free()
	mod = obj.modifiers.new('Wrap', 'SHRINKWRAP')
	mod.target = body
	mod.wrap_method = 'NEAREST_SURFACEPOINT'
	mod.wrap_mode = 'ABOVE_SURFACE'
	mod.offset = offset
	obj.modifiers.move(len(obj.modifiers) - 1, 0)
	garments.apply_modifier_stack_to_mesh(obj)
	for poly in obj.data.polygons:
		poly.use_smooth = True
	return obj


def fit_outside_masked(obj, target, offset, keep_free):
	"""Like garments.fit_outside, but vertices for which keep_free(co) is true are left where they are (e.g. boot toes)."""
	vg = obj.vertex_groups.new(name='fit_mask')
	vg.add([v.index for v in obj.data.vertices if not keep_free(v.co)], 1.0, 'REPLACE')
	mod = obj.modifiers.new('FitOutside', 'SHRINKWRAP')
	mod.target = target
	mod.wrap_method = 'NEAREST_SURFACEPOINT'
	mod.wrap_mode = 'OUTSIDE'
	mod.offset = offset
	mod.vertex_group = 'fit_mask'
	obj.modifiers.move(len(obj.modifiers) - 1, 0)
	garments.apply_modifier_stack_to_mesh(obj)
	obj.vertex_groups.remove(obj.vertex_groups['fit_mask'])


def count_triangles():
	depsgraph = bpy.context.evaluated_depsgraph_get()
	counts = {}
	for obj in bpy.data.objects:
		if obj.type == 'MESH':
			ev = obj.evaluated_get(depsgraph)
			mesh = ev.to_mesh()
			mesh.calc_loop_triangles()
			counts[obj.name] = len(mesh.loop_triangles)
			ev.to_mesh_clear()
	return counts


def make_lashes(prefix, rig, eyes, radius=0.0125, thickness=0.0011):
	"""Upper and lower lash lines as thin dark tubes hugging the front of each eye sphere (gives the eyes definition)."""
	made = []
	for eye in eyes:
		c = eye.location.copy()
		for tag, z_of, span in (('Up', lambda dx: 0.55 * radius * (1.0 - 0.45 * (dx / radius) ** 2) + 0.0008, 1.02),
				('Lo', lambda dx: -0.50 * radius * (1.0 - 0.7 * (dx / radius) ** 2) - 0.0008, 0.85)):
			pts = []
			for k in range(9):
				dx = radius * span * (-1.0 + 2.0 * k / 8.0) * 0.98
				dz = z_of(dx)
				d2 = radius * radius - dx * dx - dz * dz
				if d2 <= 0:
					continue
				pts.append(c + Vector((dx, -math.sqrt(d2) - 0.0007, dz)))
			if len(pts) >= 3:
				radii = [thickness * (0.5 + 0.5 * math.sin(math.pi * i / (len(pts) - 1))) + 0.0002 for i in range(len(pts))]
				made.append(make_tube(f'{eye.name}_Lash{tag}', rig, pts, radii, segs=4))
	return made
