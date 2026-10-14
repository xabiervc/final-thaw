"""Close the MPFB Elena: drop the body hidden under clothes and decimate garments to the triangle budget.

Run last, in the same Blender session. Budget approved with the specification: 25-30k triangles for the whole character.
"""
import sys

import bmesh
import bpy

sys.path.insert(0, 'D:/Projects/github/final-thaw/tools/blender/elena_mpfb')
import garments  # noqa: E402

RATIOS = {'Elena_Boots': 0.5, 'Elena_Knit': 0.5, 'Elena_Trousers': 0.6, 'Elena_Coat': 0.5, 'Elena_Hair': 0.1}
BUDGET = 30000
KEEP_BONES = ('head', 'neck_', 'hand_', 'index_', 'middle_', 'pinky_', 'ring_', 'thumb_')


def strip_covered_body(body):
	dom = garments.dominant_bones(body)
	bm = bmesh.new()
	bm.from_mesh(body.data)
	bm.verts.ensure_lookup_table()
	bmesh.ops.delete(bm, geom=[v for v in bm.verts if not (dom[v.index] or '').startswith(KEEP_BONES)], context='VERTS')
	bm.to_mesh(body.data)
	bm.free()


def decimate(obj, ratio):
	mod = obj.modifiers.new('Decimate', 'DECIMATE')
	mod.ratio = ratio
	mod.use_collapse_triangulate = False
	obj.modifiers.move(len(obj.modifiers) - 1, 0)
	garments.apply_modifier_stack_to_mesh(obj)


def triangle_count():
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


body = bpy.data.objects['Elena_Base']
if len(body.data.vertices) > 9000:  # not stripped yet
	strip_covered_body(body)
for name, ratio in RATIOS.items():
	obj = bpy.data.objects.get(name)
	if obj and not obj.get('decimated'):
		decimate(obj, ratio)
		obj['decimated'] = ratio
counts = triangle_count()
print(counts)
print('TOTAL triangles', sum(counts.values()), 'budget', BUDGET)
