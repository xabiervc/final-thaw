"""Close Marcus: drop the body hidden under clothes, decimate garments to the 30k budget (spec: MARCUS_MPFB_SPEC.md). Run after build_marcus.py."""
import sys

import bmesh
import bpy

sys.path.insert(0, 'D:/Projects/github/final-thaw/tools/blender/elena_mpfb')
import importlib
import garments
import char_common as cc

importlib.reload(garments)
importlib.reload(cc)

RATIOS = {'Marcus_Boots': 0.5, 'Marcus_Knit': 0.45, 'Marcus_Trousers': 0.55, 'Marcus_Jacket': 0.8, 'Marcus_Hair': 0.35}
BUDGET = 30000
KEEP_BONES = ('head', 'neck_', 'hand_', 'index_', 'middle_', 'pinky_', 'ring_', 'thumb_')

body = bpy.data.objects['Marcus_Base']
if len(body.data.vertices) > 9000:
	dom = garments.dominant_bones(body)
	bm = bmesh.new()
	bm.from_mesh(body.data)
	bm.verts.ensure_lookup_table()
	bmesh.ops.delete(bm, geom=[v for v in bm.verts if not (dom[v.index] or '').startswith(KEEP_BONES)], context='VERTS')
	bm.to_mesh(body.data)
	bm.free()
for name, ratio in RATIOS.items():
	obj = bpy.data.objects[name]
	if not obj.get('decimated'):
		mod = obj.modifiers.new('Decimate', 'DECIMATE')
		mod.ratio = ratio
		obj.modifiers.move(len(obj.modifiers) - 1, 0)
		garments.apply_modifier_stack_to_mesh(obj)
		obj['decimated'] = ratio
counts = cc.count_triangles()
print(counts)
print('TOTAL triangles', sum(counts.values()), 'budget', BUDGET)
