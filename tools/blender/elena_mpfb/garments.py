"""Helpers to derive fitted garments from the rigged MPFB body (Blender, live session or headless).

Garments are body regions (vertex groups carried over, so skinning is inherited) pushed along the normals.
"""
import bmesh
import bpy
from mathutils import Vector

BONE_PREFIXES = ('pelvis', 'spine_', 'clavicle_', 'upperarm_', 'lowerarm_', 'hand_', 'neck_', 'head', 'thigh_', 'calf_', 'foot_', 'ball_',
	'index_', 'middle_', 'pinky_', 'ring_', 'thumb_')


def dominant_bones(body):
	"""Return {vertex index: bone group name with the largest weight}."""
	names = {g.index: g.name for g in body.vertex_groups if g.name.startswith(BONE_PREFIXES)}
	out = {}
	for v in body.data.vertices:
		best, bw = None, 0.0
		for ge in v.groups:
			if ge.group in names and ge.weight > bw:
				best, bw = names[ge.group], ge.weight
		out[v.index] = best
	return out


def region_object(body, name, keep, thickness, smooth_iters=2, collection=None, cuts=(), pre_smooth=0, local_smooth=None):
	"""Copy of `body` keeping vertices where keep(vertex, bone, bm_vertex) is true, offset along the normal.

	`thickness` is a float or a function(vertex_position, bone) -> float.
	"""
	dom = dominant_bones(body)
	mesh = body.data.copy()
	mesh.name = name
	obj = bpy.data.objects.new(name, mesh)
	(collection or bpy.context.scene.collection).objects.link(obj)
	obj.parent = body.parent
	obj.matrix_world = body.matrix_world
	for g in body.vertex_groups:
		obj.vertex_groups.new(name=g.name)
	# vertex groups are stored per vertex in the mesh, so they come across with the copy
	bm = bmesh.new()
	bm.from_mesh(mesh)
	bm.verts.ensure_lookup_table()
	bm.normal_update()
	doomed = [v for v in bm.verts if not keep(v.co, dom[v.index], v)]
	bmesh.ops.delete(bm, geom=doomed, context='VERTS')
	bm.verts.ensure_lookup_table()
	for plane_co, plane_no in cuts:
		geom = list(bm.verts) + list(bm.edges) + list(bm.faces)
		bmesh.ops.bisect_plane(bm, geom=geom, plane_co=plane_co, plane_no=plane_no, clear_inner=True)
	bm.verts.ensure_lookup_table()
	_keep_largest_island(bm)
	bm.normal_update()
	for _ in range(pre_smooth):
		bmesh.ops.smooth_vert(bm, verts=bm.verts, factor=0.5, use_axis_x=True, use_axis_y=True, use_axis_z=True)
	bm.normal_update()
	for v in bm.verts:
		t = thickness(v.co, None) if callable(thickness) else thickness
		v.co += v.normal * t
	for _ in range(smooth_iters):
		bmesh.ops.smooth_vert(bm, verts=bm.verts, factor=0.5, use_axis_x=True, use_axis_y=True, use_axis_z=True)
	if local_smooth:
		pred, iters = local_smooth
		targets = [v for v in bm.verts if pred(v.co)]
		for _ in range(iters):
			bmesh.ops.smooth_vert(bm, verts=targets, factor=0.6, use_axis_x=True, use_axis_y=True, use_axis_z=True)
	bm.to_mesh(mesh)
	bm.free()
	mesh.shape_keys and obj.shape_key_clear()
	mod = obj.modifiers.new('Armature', 'ARMATURE')
	mod.object = body.parent
	return obj


def _keep_largest_island(bm, min_fraction=0.2):
	"""Drop loose fragments left by the region cut."""
	seen, islands = set(), []
	for v in bm.verts:
		if v.index in seen:
			continue
		stack, comp = [v], []
		seen.add(v.index)
		while stack:
			cur = stack.pop()
			comp.append(cur)
			for e in cur.link_edges:
				o = e.other_vert(cur)
				if o.index not in seen:
					seen.add(o.index)
					stack.append(o)
		islands.append(comp)
	if len(islands) > 1:
		islands.sort(key=len, reverse=True)
		floor = len(islands[0]) * min_fraction
		stray = [v for comp in islands[1:] if len(comp) < floor for v in comp]
		bmesh.ops.delete(bm, geom=stray, context='VERTS')
		bm.verts.ensure_lookup_table()


def apply_modifier_stack_to_mesh(obj, skip_types=('ARMATURE',)):
	"""Bake the evaluated mesh of `obj` (ignoring armature) back into its data."""
	for mod in obj.modifiers:
		mod.show_viewport = mod.type not in skip_types
	depsgraph = bpy.context.evaluated_depsgraph_get()
	evaluated = obj.evaluated_get(depsgraph)
	new_mesh = bpy.data.meshes.new_from_object(evaluated)
	old = obj.data
	obj.data = new_mesh
	for mod in list(obj.modifiers):
		if mod.type not in skip_types:
			obj.modifiers.remove(mod)
		else:
			mod.show_viewport = True
	bpy.data.meshes.remove(old)


def fit_outside(obj, target, offset):
	"""Push vertices that sank inside `target` back out to `offset` above its surface (others keep their place)."""
	mod = obj.modifiers.new('FitOutside', 'SHRINKWRAP')
	mod.target = target
	mod.wrap_method = 'NEAREST_SURFACEPOINT'
	mod.wrap_mode = 'OUTSIDE'
	mod.offset = offset
	# modifier order: shrinkwrap must run before the armature
	obj.modifiers.move(len(obj.modifiers) - 1, 0)
	before = [v.co.copy() for v in obj.data.vertices]
	apply_modifier_stack_to_mesh(obj)
	moved = sum(1 for a, v in zip(before, obj.data.vertices) if (a - v.co).length > 1e-5)
	return moved, len(before)
