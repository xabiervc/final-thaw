"""Marcus Reyes from the approved spec (docs/art/MARCUS_MPFB_SPEC.md): body, rig, jacket, sweater, trousers, boots, belt kit, hair.

Run in a live Blender session with MPFB enabled:  exec(open(path).read())
Then build_marcus_finalize.py (decimate / strip) and bake_marcus.py (headless).
"""
import math
import sys

import bmesh
import bpy
from mathutils import Vector

sys.path.insert(0, 'D:/Projects/github/final-thaw/tools/blender/elena_mpfb')
import importlib

import garments
import char_common as cc

importlib.reload(garments)
importlib.reload(cc)

P = 'Marcus'
HEIGHT = 1.82
MACRO = {'gender': 1.0, 'age': 0.6, 'muscle': 0.55, 'weight': 0.55, 'height': 0.5794, 'proportions': 0.5, 'cupsize': 0.5, 'firmness': 0.5,
	'race': {'asian': 0.1, 'caucasian': 0.75, 'african': 0.15}}
FACE = {
	'head/head-rectangular': 0.35, 'head/head-age-incr': 0.2, 'chin/chin-prominent-incr': 0.2, 'chin/chin-width-incr': 0.2,
	'eyebrows/eyebrows-trans-down': 0.3, 'eyes/l-eye-bag-incr': 0.3, 'eyes/r-eye-bag-incr': 0.3,
	'eyes/l-eye-eyefold-down': 0.2, 'eyes/r-eye-eyefold-down': 0.2, 'cheek/l-cheek-volume-decr': 0.2, 'cheek/r-cheek-volume-decr': 0.2,
	'mouth/mouth-angles-down': 0.15, 'nose/nose-compression-compress': 0.1, 'forehead/forehead-scale-vert-decr': 0.1,
}

body, rig = cc.build_character(P, MACRO, FACE, HEIGHT)
top = max(v.co.z for v in body.data.vertices)

# key heights from the rig (works for any build)
pelvis_z = cc.bone_pos(rig, 'pelvis').z
neck_z = cc.bone_pos(rig, 'neck_01').z
head_z = cc.bone_pos(rig, 'head').z
shoulder = cc.bone_pos(rig, 'upperarm_l')
elbow = cc.bone_pos(rig, 'lowerarm_l')
HEM_Z = pelvis_z + 0.02          # jacket hem, just under the belt line
COLLAR_Z = head_z + 0.035        # top of the stand collar (jaw level)
TORSO = ('spine_', 'clavicle_', 'pelvis')
ARM = ('upperarm_', 'lowerarm_')
WRIST_T = 0.96

for name in list(bpy.data.objects.keys()):
	if name.startswith(P + '_') and name not in (P + '_Base', P + '_Base.rig'):
		bpy.data.objects.remove(bpy.data.objects[name])


def wrist_cuts():
	cuts = []
	for side in ('l', 'r'):
		bn = rig.data.bones['lowerarm_' + side]
		axis = (bn.tail_local - bn.head_local).normalized()
		cuts.append((bn.head_local + (bn.tail_local - bn.head_local) * WRIST_T, -axis))
	return cuts


# ------------------------------------------------------------------ jacket (padded work jacket, stand collar, half-open front)
def keep_jacket(co, bone, bmv):
	if bone is None:
		return False
	if bone.startswith(TORSO) or bone.startswith('thigh_'):
		if co.z < HEM_Z - 0.02 or co.z > neck_z:
			return False
		if abs(co.x) < 0.02 and co.y < 0.0 and co.z > pelvis_z + 0.30:
			return False  # zipper left half open at the chest
		return True
	if bone.startswith(ARM) or bone.startswith('hand_'):
		return True
	if bone.startswith('neck_'):
		return co.z < COLLAR_Z
	return False


def jacket_thickness(co, _):
	if co.z > neck_z - 0.02:
		return 0.030  # stand collar
	return 0.042 if abs(co.x) > 0.20 else 0.056


jacket = garments.region_object(body, P + '_Jacket', keep_jacket, jacket_thickness, smooth_iters=6, pre_smooth=3,
	local_smooth=(lambda c: c.y < 0.0 and pelvis_z + 0.2 < c.z < neck_z and abs(c.x) < 0.24, 28),
	cuts=[(Vector((0, 0, HEM_Z)), Vector((0, 0, 1)))] + wrist_cuts())

# ------------------------------------------------------------------ sweater, trousers, boots
knit = garments.region_object(body, P + '_Knit',
	lambda co, bone, v: bone is not None and (bone.startswith(TORSO) or bone.startswith('neck_')) and pelvis_z - 0.05 < co.z < neck_z - 0.01,
	0.008, smooth_iters=3)


def keep_trousers(co, bone, bmv):
	return bone is not None and bone.startswith(('thigh_', 'calf_', 'foot_', 'spine_01')) or bone == 'pelvis' if co.z > 0.12 else False


trousers = garments.region_object(body, P + '_Trousers',
	lambda co, bone, v: (bone is not None and (bone.startswith(('thigh_', 'calf_', 'spine_01')) or bone == 'pelvis')) and 0.12 < co.z < pelvis_z + 0.20,
	lambda co, _: 0.020 if co.z > 0.6 else (0.020 + (0.6 - co.z) * 0.03), smooth_iters=5)

boots = garments.region_object(body, P + '_Boots', lambda co, bone, v: co.z < 0.22,
	lambda co, _: 0.018 + (0.008 if co.z < 0.04 else 0.0), smooth_iters=5, cuts=[(Vector((0, 0, 0.21)), Vector((0, 0, -1)))])

for obj, off in ((jacket, 0.016), (knit, 0.005), (trousers, 0.006)):
	garments.fit_outside(obj, body, off)
cc.fit_outside_masked(boots, body, 0.010, keep_free=lambda co: co.z < 0.10 and co.y < -0.05)

# ------------------------------------------------------------------ belt kit (belt, buckle, two pouches left, radio right)
depsgraph = bpy.context.evaluated_depsgraph_get()
belt_z = HEM_Z + 0.045
belt_pts = []
for k in range(40):
	a = 2 * math.pi * k / 40
	d = Vector((math.cos(a), math.sin(a), 0))
	origin = Vector((0, 0, belt_z)) + d * 0.6
	ok, loc, normal, _ = jacket.ray_cast(origin, -d, depsgraph=depsgraph)
	belt_pts.append((loc + normal * 0.012) if ok else Vector((0, 0, belt_z)) + d * 0.22)
belt = cc.make_tube(P + '_Belt', rig, belt_pts, [0.022] * 40, segs=6, group='pelvis', closed_loop=True)
belt.scale.z = 1.0
buckle = cc.make_box(P + '_Buckle', (0.07, 0.014, 0.05), (0, belt_pts[30].y if False else min(p.y for p in belt_pts) - 0.004, belt_z), rig, 'pelvis')
pouch_y = min(p.y for p in belt_pts)
side_x = max(abs(p.x) for p in belt_pts)
pouches = [cc.make_box(f'{P}_Pouch_{i}', (0.075, 0.05, 0.085), (-(0.11 + 0.085 * i), pouch_y + 0.012, belt_z - 0.045), rig, 'pelvis', bevel=0.006)
	for i in range(2)]
radio = cc.make_box(P + '_Radio', (0.052, 0.034, 0.115), (0.15, pouch_y + 0.02, belt_z - 0.03), rig, 'pelvis', bevel=0.005)
antenna = cc.make_tube(P + '_Antenna', rig, [Vector((0.168, pouch_y + 0.02, belt_z + 0.03)), Vector((0.168, pouch_y + 0.02, belt_z + 0.19))],
	[0.004, 0.0025], segs=5, group='pelvis')
screen = cc.make_box(P + '_RadioScreen', (0.03, 0.004, 0.022), (0.15, pouch_y + 0.0385, belt_z - 0.0), rig, 'pelvis', bevel=0.0)

# ------------------------------------------------------------------ padded stand collar (ring around the neck, orange outside)
collar_z = top - 0.27
collar_pts = []
for k in range(36):
	a = 2 * math.pi * k / 36
	d = Vector((math.cos(a), math.sin(a), 0))
	ok, loc, normal, _ = body.ray_cast(Vector((0, -0.02, collar_z)) + d * 0.5, -d, depsgraph=depsgraph)
	collar_pts.append((loc + d * 0.022) if ok else Vector((0, -0.02, collar_z)) + d * 0.075)
collar = cc.make_tube(P + '_Collar', rig, collar_pts, [0.024] * 36, segs=8, group='neck_01', closed_loop=True)

# ------------------------------------------------------------------ hair: short, dark, textured top
EAR_X, EAR_Y = 0.074, (-0.035, 0.05)


def hairline(y):
	if y < -0.06:
		return top - 0.050
	if y < 0.03:
		return top - 0.050 - (y + 0.06) / 0.09 * 0.040
	return top - 0.090 - min((y - 0.03) / 0.06, 1.0) * 0.035


hair = cc.make_hair_shell(P + '_Hair', body, rig, hairline,
	lambda co: not (abs(co.x) > EAR_X and EAR_Y[0] < co.y < EAR_Y[1] and co.z < top - 0.03), offset=0.012)
cc.skin_to(hair, rig, 'head')

eye_z = top - 0.115
eyes = cc.make_eyes(P, body, rig, 0.032, eye_z, radius=0.0125)
brows = cc.make_brows(P, body, rig, eye_z + 0.027)
cc.make_lashes(P, rig, eyes)

for obj in (jacket, knit, trousers, boots):
	if 'Armature' not in obj.modifiers:
		pass
print({k: v for k, v in cc.count_triangles().items()})
