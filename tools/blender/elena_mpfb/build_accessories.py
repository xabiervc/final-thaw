"""Backpack, straps and Aster for the MPFB Elena. Run after build_clothes.py in the same Blender session (shares its namespace).

The backpack comes from the existing lab_ref/ref_elena.glb; its old strap pieces are dropped and replaced by straps that follow the coat.
"""
import math

import bpy
import bmesh
from mathutils import Matrix, Vector

REPO = 'D:/Projects/github/final-thaw'
SRC_GLB = REPO + '/assets/models/lab_ref/ref_elena.glb'
STRAP_X, STRAP_RADIUS, STRAP_OFFSET = 0.105, 0.013, 0.007
PACK_SHIFT_Y = -0.103  # old torso -> this body (-0.045 first fit, -0.058 against the coat back)

for name in ('Backpack', 'Aster', 'emit_aster', 'Elena_Strap_L', 'Elena_Strap_R'):
	if name in bpy.data.objects:
		bpy.data.objects.remove(bpy.data.objects[name])

before = set(bpy.data.objects.keys())
bpy.ops.import_scene.gltf(filepath=SRC_GLB)
imported = [bpy.data.objects[n] for n in bpy.data.objects.keys() if n not in before]
for obj in imported:
	if obj.name not in ('Backpack', 'Aster', 'emit_aster'):
		bpy.data.objects.remove(obj)
pack, aster, aster_emit = (bpy.data.objects[n] for n in ('Backpack', 'Aster', 'emit_aster'))
for obj in (pack, aster, aster_emit):
	world = obj.matrix_world.copy()
	obj.parent = None
	obj.matrix_world = world

# drop the old strap islands (anything reaching forward of the pack body)
bm = bmesh.new()
bm.from_mesh(pack.data)
bm.verts.ensure_lookup_table()
seen, doomed = set(), []
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
	if min((pack.matrix_world @ c.co).y for c in comp) < 0.10:
		doomed += comp
bmesh.ops.delete(bm, geom=doomed, context='VERTS')
bm.to_mesh(pack.data)
bm.free()

world = pack.matrix_world.copy()
world.translation.y += PACK_SHIFT_Y
pack.parent = rig
pack.parent_type = 'BONE'
pack.parent_bone = 'spine_03'
pack.matrix_world = world

aster.parent = rig
aster.parent_type = 'BONE'
aster.parent_bone = 'hand_r'
aster.matrix_world = Matrix.Translation(Vector((-0.468, -0.222, 1.045)))

# straps follow the coat surface: back, over the shoulder, down the chest
depsgraph = bpy.context.evaluated_depsgraph_get()


def coat_hit(origin, direction):
	ok, loc, normal, _ = coat.ray_cast(origin, direction, depsgraph=depsgraph)
	return loc + normal * STRAP_OFFSET


def strap_path(sx):
	pts = [coat_hit(Vector((sx * STRAP_X, 2, z)), Vector((0, -1, 0))) for z in (1.20, 1.26, 1.32, 1.37)]
	pts += [coat_hit(Vector((sx * STRAP_X, y, 2)), Vector((0, 0, -1))) for y in (0.05, 0.02, -0.01, -0.04, -0.07)]
	pts += [coat_hit(Vector((sx * STRAP_X, -2, z)), Vector((0, 1, 0))) for z in (1.40, 1.34, 1.28, 1.22, 1.16, 1.10)]
	return pts


for side, sx in (('L', 1), ('R', -1)):
	path = strap_path(sx)
	strap = make_tube('Elena_Strap_' + side, path, [STRAP_RADIUS] * len(path), segs=6, group='spine_03')
	tint(strap, (0.1, 0.11, 0.12, 1))
